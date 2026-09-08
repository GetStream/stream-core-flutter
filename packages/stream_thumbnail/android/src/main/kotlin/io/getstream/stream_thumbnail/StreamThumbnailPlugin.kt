package io.getstream.stream_thumbnail

import android.content.ContentResolver
import android.content.Context
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.media.ThumbnailUtils
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/** StreamThumbnailPlugin */
class StreamThumbnailPlugin : FlutterPlugin, StreamThumbnailHostApi {
    private val TAG = "ThumbnailPlugin"

    private var context: Context? = null
    private var executor = Executors.newCachedThreadPool()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        if (executor.isShutdown) {
            executor = Executors.newCachedThreadPool()
        }
        StreamThumbnailHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        StreamThumbnailHostApi.setUp(binding.binaryMessenger, null)
        executor.shutdown()
    }

    override fun thumbnailData(request: ThumbnailRequest, callback: (Result<ByteArray>) -> Unit) {
        executeAsync(callback) { buildThumbnailData(request) }
    }

    override fun thumbnailFile(request: ThumbnailRequest, callback: (Result<String>) -> Unit) {
        executeAsync(callback) { buildThumbnailFile(request) }
    }

    /**
     * Runs [block] on the background executor and delivers its outcome back to Flutter on the
     * main thread via [callback], exactly once.
     */
    private fun <T> executeAsync(callback: (Result<T>) -> Unit, block: () -> T) {
        executor.execute {
            val result = try {
                Result.success(block())
            } catch (e: Exception) {
                Result.failure(FlutterError("THUMBNAIL_ERROR", e.message, e.stackTraceToString()))
            }
            Handler(Looper.getMainLooper()).post { callback(result) }
        }
    }

    private fun buildThumbnailData(request: ThumbnailRequest): ByteArray {
        val bitmap = createVideoThumbnail(
            request.video,
            request.headers ?: emptyMap(),
            request.maxHeight.toInt(),
            request.maxWidth.toInt(),
            request.timeMs.toInt()
        ) ?: throw IOException("Failed to generate a thumbnail for the video.")
        val stream = ByteArrayOutputStream()
        bitmap.compress(compressFormat(request.format), request.quality.toInt(), stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    private fun buildThumbnailFile(request: ThumbnailRequest): String {
        val bytes = buildThumbnailData(request)
        val cacheDir = context?.cacheDir ?: throw IOException("Failed to resolve the cache directory.")

        // The file name comes from the video, so a directory per request is what
        // keeps two same-named videos from different folders off each other.
        val outputDir = File(cacheDir, "stream_thumbnail/${UUID.randomUUID()}")
        if (!outputDir.mkdirs()) throw IOException("Failed to create the thumbnail directory.")

        val output = File(outputDir, thumbnailName(request.video, formatExt(request.format)))
        FileOutputStream(output).use { f -> f.write(bytes) }
        Log.d(TAG, String.format("buildThumbnailFile( written:%d )", bytes.size))
        return output.absolutePath
    }

    /** The video's own file name, carrying the thumbnail's `ext` instead. */
    private fun thumbnailName(video: String, ext: String): String {
        // Uri splits the path on `/` before decoding each segment, so a `%2F` comes
        // back as a literal separator: `..%2Fevil.mp4` would otherwise name a file
        // outside the directory created for this request.
        val decoded = Uri.parse(video).lastPathSegment ?: video
        val segment = decoded.substringAfterLast('/').substringAfterLast('\\')
        val stem = segment.substringBeforeLast('.', segment).ifEmpty { "thumbnail" }
        return "$stem.$ext"
    }

    /**
     * Create a video thumbnail for a video. May return null if the video is corrupt
     * or the format is not supported.
     *
     * @param video   the URI of video
     * @param targetH the max height of the thumbnail
     * @param targetW the max width of the thumbnail
     */
    @Throws(IOException::class)
    fun createVideoThumbnail(
        video: String,
        headers: Map<String, String>,
        targetH: Int,
        targetW: Int,
        timeMs: Int
    ): Bitmap? {
        var bitmap: Bitmap?
        var retriever: MediaMetadataRetriever? = null

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && video.startsWith("/") && timeMs == -1) {
                bitmap =
                    ThumbnailUtils.createVideoThumbnail(File(video), Size(targetW, targetH), null)
            } else {
                retriever = MediaMetadataRetriever()
                if (video.startsWith("/")) {
                    setDataSource(video, retriever)
                } else if (video.startsWith("file://")) {
                    setDataSource(video.substring(7), retriever)
                } else if (video.startsWith("content://")) {
                    val contentResolver: ContentResolver = context!!.contentResolver
                    val assetFileDescriptor =
                        contentResolver.openAssetFileDescriptor(Uri.parse(video), "r")
                    if (assetFileDescriptor != null) {
                        val fileDescriptor: FileDescriptor = assetFileDescriptor.fileDescriptor
                        retriever.setDataSource(fileDescriptor)
                        assetFileDescriptor.close()
                    }
                } else {
                    retriever.setDataSource(video, headers)
                }

                if (targetH != 0 || targetW != 0) {
                    if (Build.VERSION.SDK_INT >= 27 && targetH != 0 && targetW != 0) {
                        bitmap = retriever.getScaledFrameAtTime(
                            timeMs * 1000L,
                            MediaMetadataRetriever.OPTION_CLOSEST,
                            targetW,
                            targetH
                        )
                        if (bitmap == null) {
                            bitmap = retriever.getScaledFrameAtTime(
                                timeMs * 1000L,
                                MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                                targetW,
                                targetH
                            )
                        }
                    } else {
                        bitmap = retriever.getFrameAtTime(
                            timeMs * 1000L,
                            MediaMetadataRetriever.OPTION_CLOSEST
                        )
                        if (bitmap == null) {
                            bitmap = retriever.getFrameAtTime(
                                timeMs * 1000L,
                                MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                            )
                        }
                        if (bitmap != null) {
                            val width = bitmap.width
                            val height = bitmap.height
                            val scaledW = targetW.takeIf { it != 0 }
                                ?: ((targetH.toFloat() / height) * width).toInt()
                            val scaledH = targetH.takeIf { it != 0 }
                                ?: ((targetW.toFloat() / width) * height).toInt()
                            bitmap = Bitmap.createScaledBitmap(bitmap, scaledW, scaledH, true)
                        }
                    }
                } else {
                    bitmap = retriever.getFrameAtTime(
                        timeMs * 1000L,
                        MediaMetadataRetriever.OPTION_CLOSEST
                    )
                    if (bitmap == null) {
                        bitmap = retriever.getFrameAtTime(
                            timeMs * 1000L,
                            MediaMetadataRetriever.OPTION_CLOSEST_SYNC
                        )
                    }
                }
            }
        } finally {
            retriever?.release()
        }

        return bitmap
    }

    private fun setDataSource(video: String, retriever: MediaMetadataRetriever) {
        val videoFile = File(video)
        FileInputStream(videoFile.absolutePath).use { inputStream ->
            retriever.setDataSource(inputStream.fd)
        }
    }

    private fun compressFormat(format: ThumbnailFormat): Bitmap.CompressFormat {
        return when (format) {
            ThumbnailFormat.JPEG -> Bitmap.CompressFormat.JPEG
            ThumbnailFormat.PNG -> Bitmap.CompressFormat.PNG
            ThumbnailFormat.WEBP -> Bitmap.CompressFormat.WEBP
        }
    }

    private fun formatExt(format: ThumbnailFormat): String {
        return when (format) {
            ThumbnailFormat.JPEG -> "jpg"
            ThumbnailFormat.PNG -> "png"
            ThumbnailFormat.WEBP -> "webp"
        }
    }
}
