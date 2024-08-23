import ATmega328P
import serial
import MPL31155A2

ATmega328P.Usart0.setupSerial()

func print(_ msg: StaticString) {
    ATmega328P.Usart0.write(msg)
}

// print the number value of the lower 4 bits
func print(nybble: UInt8) {
    let nybble = nybble & 0x0f
    if nybble > 9 {
        ATmega328P.Usart0.write(nybble+55)
    } else {
        ATmega328P.Usart0.write(nybble+48)
    }
}

func print(_ byte: UInt8) {
    print(nybble: byte>>4)
    print(nybble: byte)
}

func print(_ i: Int) {
    print(nybble: UInt8(i>>12))
    print(nybble: UInt8(i>>8))
    print(nybble: UInt8(i>>4))
    print(nybble: UInt8(i))
}

func print(_ f: Float) {
    let i = Int(f)
    print(i)
    print(".")
    let remainder = f - Float(i)
    print(Int(remainder*10.0))
}

func print(rawF f: Float) {
    print(Int(f*10.0))
}

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

    let iTemp = ATmega328P.Twi.blockingGetTemperature()

    print("\ngot temperature from sensor\n")
    
    print("\ntemp: ")
    print(iTemp)
    print("\nraw temp:")
    print(rawF: iTemp)
    
    let alt = ATmega328P.Twi.blockingGetAltitude()
    
    print("\nalt: ")
    print(alt)
    print("\nraw alt:")
    print(rawF: alt)
    
    return iTemp
}


readTemperature()

