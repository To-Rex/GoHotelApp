package gohotels.torex.uz.gohotels

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// local_auth (biometrika) FlutterFragmentActivity talab qiladi.
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val PERMISSION_CHANNEL = "gohotels/incoming_calls/permission"
        private const val REQUEST_CODE = 4711

        /**
         * Kiruvchi raqamni o'qish uchun ikkala ruxsat ham kerak:
         * `READ_PHONE_STATE` qo'ng'iroq holatini beradi, `READ_CALL_LOG`
         * esa raqamning o'zini. Ikkinchisisiz raqam bo'sh keladi.
         */
        private val CALL_PERMISSIONS = arrayOf(
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_CALL_LOG,
        )
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Kiruvchi qo'ng'iroq raqami — faqat qabulxona rolida tinglanadi
        // (Flutter tomonida shunday hal qilinadi).
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CallWatcher.CHANNEL)
            .setStreamHandler(CallWatcher(applicationContext))

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PERMISSION_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "has" -> result.success(hasCallPermissions())
                "request" -> {
                    if (hasCallPermissions()) {
                        result.success(true)
                    } else if (pendingResult != null) {
                        // Oldingi so'rov hali javob kutmoqda — ikkinchisini
                        // ochish tizim oynasini ikkilantirib yuborardi
                        result.success(false)
                    } else {
                        pendingResult = result
                        ActivityCompat.requestPermissions(
                            this,
                            CALL_PERMISSIONS,
                            REQUEST_CODE,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasCallPermissions(): Boolean = CALL_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(this, it) ==
            PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_CODE) return
        val result = pendingResult
        pendingResult = null
        // Ikkala ruxsat ham berilgan bo'lsagina "ha" deymiz: bittasi
        // yetishmasa raqam baribir bo'sh keladi
        result?.success(
            grantResults.isNotEmpty() &&
                grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        )
    }
}
