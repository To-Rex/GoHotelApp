package gohotels.torex.uz.gohotels

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.telephony.TelephonyManager
import io.flutter.plugin.common.EventChannel

/**
 * Kiruvchi qo'ng'iroq raqamini Flutter tomoniga uzatadi.
 *
 * Qabulxona qurilmasiga mehmon qo'ng'iroq qilganda raqam serverga
 * yuboriladi va u yerda mehmon bazadan topiladi. Xodim go'shakni
 * ko'targanda kim gapirayotganini biladi.
 *
 * Nima uchun tayyor paket emas: ilovaga yangi bog'liqlik qo'shish
 * o'rniga bu yerda o'ttiz qatorlik `BroadcastReceiver` yetarli — u
 * faqat bitta narsani qiladi va nima qilayotgani ko'rinib turadi.
 *
 * Faqat ANDROID. iOS'da tizim kiruvchi raqamni ilovaga bermaydi —
 * bu platformaning qat'iy cheklovi, aylanib o'tish yo'li yo'q.
 */
class CallWatcher(private val context: Context) : EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "gohotels/incoming_calls"

        /** Shu vaqt ichida takrorlangan raqam bitta jiringlash sanaladi. */
        private const val REPEAT_WINDOW_MS = 20_000L
    }

    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return

        val handler = object : BroadcastReceiver() {
            /* Bitta qo'ng'iroq uchun tizim `RINGING` ni bir necha marta
               yuboradi — o'sha raqamni qayta yubormaymiz.

               Ilgari bu belgi FAQAT `IDLE` da tozalanardi va shu sabab
               ikkinchi qo'ng'iroq yo'qolib qolardi: qurilma `IDLE` ni
               o'tkazib yuborsa (ekran o'chgan, qabul qiluvchi qayta
               ro'yxatdan o'tgan) raqam abadiy "takror" bo'lib qolardi.

               Endi ikki himoya bor: RINGING dan boshqa har qanday holat
               belgini tozalaydi, va vaqt bo'yicha chegara — undan keyin
               o'sha raqam ham yangi qo'ng'iroq hisoblanadi. */
            private var lastNumber: String? = null
            private var lastAt = 0L

            override fun onReceive(ctx: Context?, intent: Intent?) {
                if (intent?.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
                    return
                }
                val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
                if (state != TelephonyManager.EXTRA_STATE_RINGING) {
                    // Qo'ng'iroq javob berildi yoki tugadi — keyingisi
                    // yangi hisoblanadi
                    lastNumber = null
                    return
                }

                val number = intent.getStringExtra(
                    TelephonyManager.EXTRA_INCOMING_NUMBER
                )
                // Raqam berilmasligi mumkin: yashirin raqam yoki
                // READ_CALL_LOG ruxsati yo'q. Bunday holatda yuboradigan
                // narsa ham yo'q.
                if (number.isNullOrBlank()) return

                val now = System.currentTimeMillis()
                if (number == lastNumber && now - lastAt < REPEAT_WINDOW_MS) {
                    // Oyna SURILADI: uzoq jiringlash davomida kelgan har
                    // bir takror uni cho'zadi. Aks holda 25 soniya
                    // jiringlagan bitta qo'ng'iroq ikki marta yuborilardi.
                    lastAt = now
                    return
                }

                lastNumber = number
                lastAt = now
                events.success(number)
            }
        }

        val filter = IntentFilter(TelephonyManager.ACTION_PHONE_STATE_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            context.registerReceiver(handler, filter, Context.RECEIVER_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            context.registerReceiver(handler, filter)
        }
        receiver = handler
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let {
            // Ro'yxatdan o'tmagan qabul qiluvchini o'chirish xato beradi —
            // ilova fonga o'tib qaytganda bu yo'l ikki marta chaqirilishi
            // mumkin
            runCatching { context.unregisterReceiver(it) }
        }
        receiver = null
    }
}
