require 'java'

START_ACCESS_POINT = [0xFF, 0x07, 0x03].to_java :byte
DATA_REQUEST = [0xFF, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00].to_java :byte

# ugly procedural stuff
portList = Java::Gnu::io::CommPortIdentifier.getPortIdentifiers
port = nil
while portList.hasMoreElements
  portId = portList.nextElement
  if portId.name =~ /tty.usbmodem/
    port = portId.open("AccelerometerDump", 2000)
    puts "Port opened!"
    break
  end
end

if port != nil
  # main loop
  output = port.outputStream
  input = port.inputStream

  output.write START_ACCESS_POINT
  output.flush
  loop do
    output.write DATA_REQUEST
    output.flush
    data = []
    7.times { data << input.read }
    accelerometer = data[0..2]
    if accelerometer.max != 0
      puts accelerometer.join(" ")
    end
  end
  output.close
  input.close
  port.close
else
  puts "Port not found"
end
