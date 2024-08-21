# i2c-buffers

This adds some buffer functions. In the first instance just a register read into buffer.

`static func readIntoBuffer<T:BinaryInteger>(buffer: UnsafeMutableBufferPointer<T>,
    fromAddress address: UInt8,
    startRegister: UInt8,
    timeout: UInt16) -> Bool`

The number of registers to read and the register type are inferred by the generic type parameter.

You specify the slave address of the device to read, and the startin register to read from.

Timeout is as in the standard i2c library.

Returns: true if all expected data was read.
