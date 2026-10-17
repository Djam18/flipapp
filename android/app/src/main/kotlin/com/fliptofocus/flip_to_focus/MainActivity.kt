package com.fliptofocus.flip_to_focus

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), SensorEventListener {

    private val SENSOR_CHANNEL = "com.fliptofocus.app/flip_sensor"
    private val DND_CHANNEL = "com.fliptofocus.app/dnd"
    private val VIBRATION_CHANNEL = "com.fliptofocus.app/vibration"
    private val NOTIFICATION_CHANNEL = "com.fliptofocus.app/notifications"
    private val PAUSE_CHANNEL_ID = "focus_pause_channel"
    private val PAUSE_NOTIFICATION_ID = 2001
    private val REMINDER_NOTIFICATION_ID = 2002
    private val EXPIRE_NOTIFICATION_ID = 2003

    private val handler = Handler(Looper.getMainLooper())
    private val pendingRunnables = mutableListOf<Runnable>()

    private lateinit var sensorManager: SensorManager
    private var gravitySensor: Sensor? = null
    private var proximitySensor: Sensor? = null

    private var eventSink: EventChannel.EventSink? = null
    private var isFacingDown = false
    private var isCovered = false
    private var isFlipped = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        gravitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY)
            ?: sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)

        // EventChannel for continuous physical flip hardware events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startSensorListening()
                }

                override fun onCancel(arguments: Any?) {
                    stopSensorListening()
                    eventSink = null
                }
            }
        )

        // MethodChannel for Do Not Disturb (DND) policy management
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DND_CHANNEL).setMethodCallHandler { call, result ->
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            when (call.method) {
                "isDndGranted" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(notificationManager.isNotificationPolicyAccessGranted)
                    } else {
                        result.success(true)
                    }
                }
                "requestDndPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "setDndEnabled" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        if (notificationManager.isNotificationPolicyAccessGranted) {
                            if (enable) {
                                notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_PRIORITY)
                            } else {
                                notificationManager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
                            }
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // MethodChannel for 100% functional native hardware vibration
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIBRATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val type = call.argument<String>("type") ?: "light"
                    triggerHardwareVibration(type)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // MethodChannel for Emergency Pause out-of-app background notifications
        createNotificationChannel()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showPauseNotification" -> {
                    val title = call.argument<String>("title") ?: "Emergency Pause (2 min)"
                    val message = call.argument<String>("message") ?: "Flip phone face-down to resume session"
                    showNotification(PAUSE_NOTIFICATION_ID, title, message)
                    result.success(true)
                }
                "schedulePauseReminder" -> {
                    val firstReminderSeconds = call.argument<Int>("firstReminderSeconds") ?: 60
                    val reminderTitle = call.argument<String>("reminderTitle") ?: "1 minute remaining!"
                    val reminderMessage = call.argument<String>("reminderMessage") ?: "Resume your Deep Work before time expires."
                    val expireSeconds = call.argument<Int>("expireSeconds") ?: 120
                    val expireTitle = call.argument<String>("expireTitle") ?: "Pause Expired"
                    val expireMessage = call.argument<String>("expireMessage") ?: "Session was interrupted and preserved."

                    cancelAllNotifications()

                    // Schedule intermediate 60s reminder
                    val reminderRunnable = Runnable {
                        showNotification(REMINDER_NOTIFICATION_ID, reminderTitle, reminderMessage)
                        triggerHardwareVibration("alert")
                    }
                    pendingRunnables.add(reminderRunnable)
                    handler.postDelayed(reminderRunnable, firstReminderSeconds * 1000L)

                    // Schedule 120s final expiration notice
                    val expireRunnable = Runnable {
                        showNotification(EXPIRE_NOTIFICATION_ID, expireTitle, expireMessage)
                        triggerHardwareVibration("alert")
                    }
                    pendingRunnables.add(expireRunnable)
                    handler.postDelayed(expireRunnable, expireSeconds * 1000L)

                    result.success(true)
                }
                "cancelNotifications" -> {
                    cancelAllNotifications()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Focus Pause & Reminders"
            val descriptionText = "Notifications for deep work pause timeouts and reminders"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(PAUSE_CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableVibration(true)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun buildPendingIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(this, 0, intent, flags)
    }

    private fun showNotification(id: Int, title: String, message: String) {
        try {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val pendingIntent = buildPendingIntent()

            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, PAUSE_CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }

            builder.setContentTitle(title)
                .setContentText(message)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                builder.setCategory(Notification.CATEGORY_REMINDER)
                builder.setPriority(Notification.PRIORITY_HIGH)
            }

            notificationManager.notify(id, builder.build())
        } catch (_: Exception) {}
    }

    private fun cancelAllNotifications() {
        pendingRunnables.forEach { handler.removeCallbacks(it) }
        pendingRunnables.clear()
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(PAUSE_NOTIFICATION_ID)
        notificationManager.cancel(REMINDER_NOTIFICATION_ID)
        notificationManager.cancel(EXPIRE_NOTIFICATION_ID)
    }

    private fun triggerHardwareVibration(type: String) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vibratorManager?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }

            if (vibrator == null || !vibrator.hasVibrator()) return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val effect = when (type) {
                    "light" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
                        } else {
                            VibrationEffect.createOneShot(25, 100)
                        }
                    }
                    "success" -> {
                        val timings = longArrayOf(0, 50, 75, 100)
                        val amplitudes = intArrayOf(0, 160, 0, 240)
                        VibrationEffect.createWaveform(timings, amplitudes, -1)
                    }
                    "alert" -> {
                        val timings = longArrayOf(0, 120, 80, 150)
                        val amplitudes = intArrayOf(0, 255, 0, 255)
                        VibrationEffect.createWaveform(timings, amplitudes, -1)
                    }
                    else -> VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE)
                }
                vibrator.vibrate(effect)
            } else {
                @Suppress("DEPRECATION")
                when (type) {
                    "light" -> vibrator.vibrate(25)
                    "success" -> vibrator.vibrate(longArrayOf(0, 50, 75, 100), -1)
                    "alert" -> vibrator.vibrate(longArrayOf(0, 120, 80, 150), -1)
                    else -> vibrator.vibrate(50)
                }
            }
        } catch (_: Exception) {
        }
    }

    private fun startSensorListening() {
        gravitySensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
        proximitySensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI)
        }
    }

    private fun stopSensorListening() {
        sensorManager.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        event ?: return

        when (event.sensor.type) {
            Sensor.TYPE_GRAVITY, Sensor.TYPE_ACCELEROMETER -> {
                val x = event.values[0]
                val y = event.values[1]
                val z = event.values[2]
                val horizontalTilt = sqrt((x * x + y * y).toDouble())

                // Phone oriented face-down and horizontal (Z < -8.8 and horizontal tilt < 2.0)
                isFacingDown = (z < -8.8f) && (horizontalTilt < 2.0)
                checkFlipState()
            }
            Sensor.TYPE_PROXIMITY -> {
                val distance = event.values[0]
                val maxRange = event.sensor.maximumRange
                // Sensor physically occluded by desk surface
                isCovered = (distance < 1.0f) || (distance == 0f)
                checkFlipState()
            }
        }
    }

    private fun checkFlipState() {
        val newFlippedState = isFacingDown && isCovered
        if (newFlippedState != isFlipped) {
            isFlipped = newFlippedState
            if (isFlipped) {
                eventSink?.success("FLIP_DOWN")
            } else {
                eventSink?.success("FLIP_UP")
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
