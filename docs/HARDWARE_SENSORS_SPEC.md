# 📡 HARDWARE SENSORS & NATIVE ANDROID SPECIFICATION
## Module: Native Sensor Bridge & Power Management
**Status:** Approved Technical Specification  
**Parent Document:** `SPECIFICATIONS_FLIP_TO_FOCUS.md`  

---

## 1. TECHNICAL OBJECTIVE

Detect with **surgical precision** when the smartphone is placed face-down on a desk, eliminating false positives (e.g., walking with phone in pocket, resting in a bag), while maintaining negligible battery consumption (< 1% daily battery impact).

---

## 2. DETECTION PIPELINE (NATIVE KOTLIN)

Rather than streaming hundreds of raw coordinate frames across the Flutter `MethodChannel`, all mathematical calculations and noise filtering are encapsulated on the Android side in **Kotlin**.

```
[ Proximity Sensor ] ----------\
                                +--> [ Fusion & Noise Filter ] ---> Unique Event to Flutter:
[ Gravity / Accelerometer ] ---/          (Kotlin)                  - FLIP_DOWN
                                                                    - FLIP_UP
```

### 2.1. Sensor Fusion Algorithm

To validate `IS_FLIPPED = TRUE`, **three cumulative conditions** must be satisfied simultaneously:

#### Condition 1: Inverted Planarity (Gravity Z Axis)
The gravity vector $g = (g_x, g_y, g_z)$ must point downward (screen towards floor):
$$g_z < -8.8\ \text{m/s}^2 \quad \text{and} \quad \sqrt{g_x^2 + g_y^2} < 2.0\ \text{m/s}^2$$
*Meaning: The phone is resting flat and not tilted on its edge or held in hand.*

#### Condition 2: Optical Occlusion (Proximity Sensor)
$$d_{\text{proximity}} < 1.0\ \text{cm} \quad (\text{typically } 0.0\ \text{cm})$$
*Meaning: The display is physically flush against an opaque surface.*

#### Condition 3: Inertial Stillness (Pocket Anti-Trigger)
Linear acceleration variance across a 500ms sliding window:
$$\sigma^2(a) < 0.15\ \text{m/s}^2$$
*Meaning: If the user is walking or moving, the session DOES NOT START.*

---

## 3. KOTLIN REFERENCE IMPLEMENTATION

```kotlin
class FlipDetector(
    private val context: Context,
    private val onFlipChanged: (Boolean) -> Unit
) : SensorEventListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val gravitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY)
        ?: sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
    private val proximitySensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)

    private var isFacingDown = false
    private var isCovered = false
    private var currentlyFlipped = false

    fun startListening() {
        gravitySensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI) }
        proximitySensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_UI) }
    }

    fun stopListening() {
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

                // Phone oriented face-down and horizontal
                isFacingDown = (z < -8.8f) && (horizontalTilt < 2.0)
                evaluateFlipState()
            }
            Sensor.TYPE_PROXIMITY -> {
                val distance = event.values[0]
                val maxRange = event.sensor.maximumRange
                isCovered = (distance < 1.0f) || (distance == 0f)
                evaluateFlipState()
            }
        }
    }

    private fun evaluateFlipState() {
        val newFlipState = isFacingDown && isCovered
        if (newFlipState != currentlyFlipped) {
            currentlyFlipped = newFlipState
            onFlipChanged(currentlyFlipped)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
```

---

## 4. ANDROID DOZE MODE & LIFECYCLE MANAGEMENT

### 4.1. The Doze Mode Risk
When the phone is placed face-down on a desk, Android enters **Deep Doze**:
* Sensors are turned off or throttled.
* Dart/Flutter timers are suspended.

### 4.2. Engineering Countermeasure: `ForegroundService` + `PartialWakeLock`
1. **Triggered on Initial Flip:** An Android Foreground Service is launched with a silent persistent notification:  
   `"Deep Focus in progress • Place phone face-down to continue"`.
2. **Foreground Service Type (Android 14+):**
   ```xml
   <service
       android:name=".services.FocusForegroundService"
       android:foregroundServiceType="specialUse"
       android:exported="false">
       <property
           android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
           android:value="focus_session_timer_tracking" />
   </service>
   ```
3. **Battery Optimization:** Once the session completes or is aborted, the `WakeLock` is released immediately and the foreground service stops.
