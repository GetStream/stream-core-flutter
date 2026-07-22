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
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.util.concurrent.Executors

/** StreamThumbnailPlugin */
class StreamThumbnailPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private val TAG = "ThumbnailPlugin"

    private var context: Context? = null
    private var executor = Executors.newCachedThreadPool()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        if (executor.isShutdown) {
            executor = Executors.newCachedThreadPool()
        }
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "plugins.getstream.io/stream_thumbnail"
        )
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<Map<String, Any>>()

        when (call.method) {
            "file" -> executeAsync(result) { processFile(args!!) }
            "data" -> executeAsync(result) { processData(args!!) }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = null
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    /**
     * Runs [block] on the background executor and delivers its outcome back to Flutter on the
     * main thread via [result] — either `result.success` or `result.error`, exactly once.
     */
    private fun executeAsync(result: Result, block: () -> Any) {
        executor.execute {
            try {
                val value = block()
                runOnUiThread { result.success(value) }
            } catch (e: Exception) {
                runOnUiThread { result.error("THUMBNAIL_ERROR", e.message, e.stackTraceToString()) }
            }
        }
    }

    private fun processFile(args: Map<String, Any>): String {
        val video = args["video"] as String
        val headers = parseHeaders(args)
        val format = args["format"] as Int
        val maxh = args["maxh"] as Int
        val maxw = args["maxw"] as Int
        val timeMs = args["timeMs"] as Int
        val quality = args["quality"] as Int
        val path = args["path"] as String?

        return buildThumbnailFile(video, headers, path, format, maxh, maxw, timeMs, quality)
    }

    private fun processData(args: Map<String, Any>): ByteArray {
        val video = args["video"] as String
        val headers = parseHeaders(args)
        val format = args["format"] as Int
        val maxh = args["maxh"] as Int
        val maxw = args["maxw"] as Int
        val timeMs = args["timeMs"] as Int
        val quality = args["quality"] as Int

        return buildThumbnailData(video, headers, format, maxh, maxw, timeMs, quality)
    }

    private fun parseHeaders(args: Map<String, Any>): HashMap<String, String> {
        return (args["headers"] as? HashMap<*, *>)
            ?.filter { (key, value) -> key is String && value is String }
            ?.map { (key, value) -> key as String to value as String }
            ?.toMap(HashMap())
            ?: HashMap()
    }

    private fun buildThumbnailData(
        vidPath: String,
        headers: HashMap<String, String>,
        format: Int,
        maxh: Int,
        maxw: Int,
        timeMs: Int,
        quality: Int
    ): ByteArray {
        val bitmap = createVideoThumbnail(vidPath, headers, maxh, maxw, timeMs)
            ?: throw NullPointerException()
        val stream = ByteArrayOutputStream()
        bitmap.compress(intToFormat(format), quality, stream)
        bitmap.recycle()
        return stream.toByteArray()
    }

    private fun buildThumbnailFile(
        vidPath: String,
        headers: HashMap<String, String>,
        path: String?,
        format: Int,
        maxh: Int,
        maxw: Int,
        timeMs: Int,
        quality: Int
    ): String {
        val bytes = buildThumbnailData(vidPath, headers, format, maxh, maxw, timeMs, quality)
        val ext = formatExt(format)
        val i = vidPath.lastIndexOf(".")
        var fullpath = vidPath.substring(0, i + 1) + ext
        val isLocalFile = vidPath.startsWith("/") || vidPath.startsWith("file://")

        var savePath = path
        if (path == null && !isLocalFile) {
            savePath = context?.cacheDir?.absolutePath
        }

        if (savePath != null) {
            if (savePath.endsWith(ext)) {
                fullpath = savePath
            } else {
                val j = fullpath.lastIndexOf("/")
                fullpath = if (savePath.endsWith("/")) {
                    savePath + fullpath.substring(j + 1)
                } else {
                    savePath + fullpath.substring(j)
                }
            }
        }

        FileOutputStream(fullpath).use { f ->
            f.write(bytes)
            f.close()
            Log.d(TAG, String.format("buildThumbnailFile( written:%d )", bytes.size))
        }
        return fullpath
    }

    private fun runOnUiThread(runnable: Runnable) {
        Handler(Looper.getMainLooper()).post(runnable)
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
        headers: HashMap<String, String>,
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

    private fun intToFormat(format: Int): Bitmap.CompressFormat {
        return when (format) {
            0 -> Bitmap.CompressFormat.JPEG
            1 -> Bitmap.CompressFormat.PNG
            2 -> Bitmap.CompressFormat.WEBP
            else -> Bitmap.CompressFormat.JPEG
        }
    }

    private fun formatExt(format: Int): String {
        return when (format) {
            0 -> "jpg"
            1 -> "png"
            2 -> "webp"
            else -> "jpg"
        }
    }

}
