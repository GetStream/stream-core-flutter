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
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.UUID
import java.util.concurrent.Executors

/** A video the request's source kind doesn't allow this plugin to open. */
private class UnsupportedSourceException(message: String) : IllegalArgumentException(message)

/** StreamThumbnailPlugin */
class StreamThumbnailPlugin : FlutterPlugin, StreamThumbnailHostApi {
    private val TAG = "ThumbnailPlugin"

    private companion object {
        const val MAX_SOURCE_SIZE = 8192
        const val MAX_OUTPUT_SIZE = 4096

        /** Makes the media stack fail a redirect to another host instead of sending it the headers. */
        const val CROSS_DOMAIN_REDIRECTS = "android-allow-cross-domain-redirect"
    }

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
            } catch (e: UnsupportedSourceException) {
                Result.failure(FlutterError("UNSUPPORTED_SOURCE", e.message, null))
            } catch (e: Throwable) {
                Result.failure(FlutterError("THUMBNAIL_ERROR", e.message, e.stackTraceToString()))
            }
            Handler(Looper.getMainLooper()).post { callback(result) }
        }
    }

    private fun buildThumbnailData(request: ThumbnailRequest): ByteArray {
        val bitmap = createVideoThumbnail(
            request.video,
            request.sourceKind,
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

        val outputDir = File(cacheDir, "stream_thumbnail")
        if (!outputDir.mkdirs() && !outputDir.isDirectory) {
            throw IOException("Failed to create the thumbnail directory.")
        }

        val output = File(outputDir, "${UUID.randomUUID()}.${formatExt(request.format)}")
        FileOutputStream(output).use { f -> f.write(bytes) }
        Log.d(TAG, String.format("buildThumbnailFile( written:%d )", bytes.size))
        return output.absolutePath
    }

    /**
     * Create a video thumbnail for a video. May return null if the video is corrupt
     * or the format is not supported.
     *
     * @param video      the URL, path or content URI of the video
     * @param sourceKind how [video] may be opened
     * @param targetH    the max height of the thumbnail
     * @param targetW    the max width of the thumbnail
     */
    @Throws(IOException::class)
    private fun createVideoThumbnail(
        video: String,
        sourceKind: ThumbnailSourceKind,
        headers: Map<String, String>,
        targetH: Int,
        targetW: Int,
        timeMs: Int
    ): Bitmap? {
        val retriever = MediaMetadataRetriever()
        try {
            val filePath = if (sourceKind == ThumbnailSourceKind.FILE) video.removePrefix("file://") else null
            when (sourceKind) {
                ThumbnailSourceKind.FILE -> setDataSource(filePath!!, retriever)
                ThumbnailSourceKind.CONTENT_URI -> {
                    val uri = Uri.parse(video)
                    if (uri.scheme != ContentResolver.SCHEME_CONTENT) {
                        throw UnsupportedSourceException("A content video must be a content URI.")
                    }
                    val contentResolver: ContentResolver = context!!.contentResolver
                    val assetFileDescriptor = contentResolver.openAssetFileDescriptor(uri, "r")
                        ?: throw IOException("Failed to open the content URI.")
                    assetFileDescriptor.use { retriever.setDataSource(it.fileDescriptor) }
                }
                ThumbnailSourceKind.NETWORK -> {
                    val uri = Uri.parse(video)
                    val scheme = uri.scheme?.lowercase()
                    if ((scheme != "http" && scheme != "https") || uri.host.isNullOrEmpty()) {
                        throw UnsupportedSourceException("A network video must be an http or https URL.")
                    }
                    val requestHeaders = if (headers.isEmpty()) headers else headers + (CROSS_DOMAIN_REDIRECTS to "false")
                    retriever.setDataSource(video, requestHeaders)
                }
            }

            val sourceW = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)?.toIntOrNull() ?: 0
            val sourceH = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)?.toIntOrNull() ?: 0
            if (maxOf(sourceW, sourceH) > MAX_SOURCE_SIZE) {
                throw IOException("The video is larger than $MAX_SOURCE_SIZE pixels on a side.")
            }

            val (boundW, boundH) = if (targetW == 0 && targetH == 0 && maxOf(sourceW, sourceH) > MAX_OUTPUT_SIZE) {
                MAX_OUTPUT_SIZE to MAX_OUTPUT_SIZE
            } else {
                minOf(targetW, MAX_OUTPUT_SIZE) to minOf(targetH, MAX_OUTPUT_SIZE)
            }

            val fitsBothBounds = boundW > 0 && boundH > 0
            val bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && filePath != null && timeMs == -1 && fitsBothBounds) {
                ThumbnailUtils.createVideoThumbnail(File(filePath), Size(boundW, boundH), null)
            } else {
                frameAt(retriever, timeMs, boundW, boundH)
            }
            return bitmap?.let { capToMaxOutputSize(it) }
        } finally {
            retriever.release()
        }
    }

    private fun frameAt(retriever: MediaMetadataRetriever, timeMs: Int, targetW: Int, targetH: Int): Bitmap? {
        val timeUs = timeMs * 1000L
        if (Build.VERSION.SDK_INT >= 27 && targetH != 0 && targetW != 0) {
            return retriever.getScaledFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST, targetW, targetH)
                ?: retriever.getScaledFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, targetW, targetH)
        }

        val frame = retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST)
            ?: retriever.getFrameAtTime(timeUs, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            ?: return null
        if (targetH == 0 && targetW == 0) return frame

        val scaledW = targetW.takeIf { it != 0 } ?: ((targetH.toFloat() / frame.height) * frame.width).toInt()
        val scaledH = targetH.takeIf { it != 0 } ?: ((targetW.toFloat() / frame.width) * frame.height).toInt()
        val scaled = Bitmap.createScaledBitmap(frame, scaledW, scaledH, true)
        if (scaled !== frame) frame.recycle()
        return scaled
    }

    private fun capToMaxOutputSize(bitmap: Bitmap): Bitmap {
        val longest = maxOf(bitmap.width, bitmap.height)
        if (longest <= MAX_OUTPUT_SIZE) return bitmap

        val scale = MAX_OUTPUT_SIZE.toFloat() / longest
        val width = maxOf(1, (bitmap.width * scale).toInt())
        val height = maxOf(1, (bitmap.height * scale).toInt())
        val scaled = Bitmap.createScaledBitmap(bitmap, width, height, true)
        if (scaled !== bitmap) bitmap.recycle()
        return scaled
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
