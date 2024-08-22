import HAL
import i2c
import i2cBuffers
import delay

// MPL31155A2 low level helper functions
private func readAltitudeBuffer(_ buffer: UnsafeMutableBufferPointer<UInt8>) -> Float {
  let byte1 = buffer[0]
  let byte2 = buffer[1]
  let byte3 = buffer[2]

  let combined: UInt32 = UInt32(byte1)<<16 | UInt32(byte2)<<8 | UInt32(byte3)

  if (combined & 0x80000) > 0 {
    // altitude is negative
    return Float((combined | 0xFFF00000)>>4)/16.0
  } else {
    return Float(combined>>4)/16.0
  }
}

private func readPressureBuffer(_ buffer: UnsafeMutableBufferPointer<UInt8>) -> Float {
  let byte1 = buffer[0]
  let byte2 = buffer[1]
  let byte3 = buffer[2]

  let combined: Int32 = Int32(byte1)<<16 | Int32(byte2)<<8 | Int32(byte3)

  return Float(combined>>4)/4.0
}

private func readTemperatureBuffer(_ buffer: UnsafeMutableBufferPointer<UInt8>) -> Float {
  let byte1 = buffer[0]
  let byte2 = buffer[1]

  let combined: Int32 = Int32(byte1)<<8 | Int32(byte2)

  return Float(combined>>4)/16.0
}

public extension Twi where Twsr.RegisterType == UInt8 {
    static func blockingWriteControlReg1(value: UInt8) -> Bool {
      let slaveAddress: UInt8 = 0x60
    
      return writeDeviceRegister(address: slaveAddress, register: 0x26, value: value, timeout: 50_000)
    }
    
    static func blockingWaitForStatusFlag(flag: UInt8) -> Bool {
      let slaveAddress: UInt8 = 0x60

      guard var status = readDeviceRegister(address: slaveAddress, register: 0, timeout: 50_000) else { return false }
      while status & flag == 0 {
        delay_ms(10)
        guard let newstatus = readDeviceRegister(address: slaveAddress, register: 0, timeout: 50_000) else { return false }
        status = newstatus
      }

      return true
    }

    // MPL31155A2 high level functions
    /// Get the current altitude from a running sensor.
    static func blockingGetAltitude() -> Float {
      let slaveAddress: UInt8 = 0x60
      let pressureDataReadyFlag: UInt8 = 0x04
    
      // start the altimeter, turn on the analog systems, ADC, and set oversampling rate to 128x, read as altitude
      guard blockingWriteControlReg1(value: 0xB9) else { return 0.0 }
      guard blockingWaitForStatusFlag(flag: pressureDataReadyFlag) else { return 0.0 }
      
      guard let altitudeBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 3) else { return 0.0 }

      guard readIntoBuffer(buffer: altitudeBuffer,
       fromAddress: slaveAddress,
        startRegister: 0x01,
         timeout: 50_000) else {
             return 0.1
      }
    
      return readAltitudeBuffer(altitudeBuffer)
    }

    /// Get the current pressure from a running sensor.
    static func blockingGetPressure() -> Float {
      let slaveAddress: UInt8 = 0x60
      let pressureDataReadyFlag: UInt8 = 0x04
    
      // start the altimeter, turn on the analog systems, ADC, and set oversampling rate to 128x, read as pressure
      guard blockingWriteControlReg1(value: 0x39) else { return 0.0 }
      guard blockingWaitForStatusFlag(flag: pressureDataReadyFlag) else { return 0.0 }

      guard let pressureBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 3) else { return 0.0 }

      guard readIntoBuffer(buffer: pressureBuffer,
       fromAddress: slaveAddress,
        startRegister: 0x01,
         timeout: 50_000) else {
             return 0.1
      }
    
      return readPressureBuffer(pressureBuffer)
    }

    /// Get the current temperature from a running sensor.
    static func blockingGetTemperature() -> Float {
      let slaveAddress: UInt8 = 0x60
      let temperatureDataReadyFlag: UInt8 = 0x02
    
      // start the altimeter, turn on the analog systems, ADC, and set oversampling rate to 128x
    
      guard blockingWriteControlReg1(value: 0x39) else { return 0.0 }
      guard blockingWaitForStatusFlag(flag: temperatureDataReadyFlag) else { return 0.0 }

      guard let temperatureBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 2) else { return 0.0 }

      guard readIntoBuffer(buffer: temperatureBuffer,
       fromAddress: slaveAddress,
        startRegister: 0x04,
         timeout: 50_000) else {
             return 0.1
      }
     
      return readTemperatureBuffer(temperatureBuffer)
    }

    /// Once I2C has been set up, check that the sensor is available and connected.
    static func blockingCheckSensor() -> Bool where Twsr.RegisterType == UInt8 {
      let slaveAddress: UInt8 = 0x60
    
      guard let whoami = readDeviceRegister(address: slaveAddress, register: 0x0C, timeout: 50_000) else {
          let status: UInt8 = twsr.registerValue
          print(status)
          return false
      }
      return whoami == 0xC4
    }

    /// When I2C is running and we are sure the sensor is present, setup standard flags.
    static func blockingSetupSensorFlags() -> Bool {
      let slaveAddress: UInt8 = 0x60
    
      return writeDeviceRegister(address: slaveAddress, register: 0x13, value: 0x07, timeout: 50_000) // set all flags enabled for data retrieval
    }
}
