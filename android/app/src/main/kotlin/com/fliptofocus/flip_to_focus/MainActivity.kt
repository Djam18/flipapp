package com.fliptofocus.flip_to_focus

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), SensorEventListener {

    private val SENSOR_CHANNEL = "com.fliptofocus.app/flip_sensor"
    private val DND_CHANNEL = "com.fliptofocus.app/dnd"

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
