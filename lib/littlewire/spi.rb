class LittleWire::SPI
  def initialize wire
    @wire = wire
    @wire.control_transfer(function: :setup_spi)
    raise "SPI requires LittleWire firmware 1.1. Yours = #{@wire.version}" unless @wire.version_hex >= 0.11
  end
  
  # send and receive a message of up to four bytes
  def send send, auto_chipselect = false
    mode = auto_chipselect ? 1 : 0
    bytes = send.bytes.to_a
    @wire.control_transfer(
      bRequest: 0xF0 + send.length + (mode << 3),
      wValue: bytes[1].to_i << 8 | bytes[0].to_i,
      wIndex: bytes[3].to_i << 8 | bytes[2].to_i,
      dataIn: bytes.length
    )
  end
  
  # change spi delay setting
  def delay= number
    @wire.control_transfer(function: :spi_update_delay, wValue: number)
  end
  
  # get debug status
  def debug
    @wire.control_transfer(function: :debug_spi, dataIn: 8)
    @wire.control_transfer(function: :read_buffer, dataIn: 8).unpack('c').first
  end
end
