# MPL31155A2

Simple example library for reading from a pressure/temperature sensor.

Example...

```
func readTemperature() -> Float {
    print("Starting pressure and temperature monitor...")
    
    ATmega328P.Twi.setup() // speed: 0x47, premultiplier: 0
    
    // enable the MPL31155A2 sensor for reading oversampled 128x
    guard ATmega328P.Twi.blockingCheckSensor() else {
        print("sensor check failed")
        return -1
    }
    
    guard ATmega328P.Twi.blockingSetupSensorFlags() else {
        print("sensor setup failed")
        return -1
    }

    print("\n setup sensor seems fine, checking temperature")

    let l = ATmega328P.Twi.blockingGetTemperature()

    print("got temperature from sensor")
    return l
}

readTemperature()
```
