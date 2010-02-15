$events = $win.events
$point_source = $win.pointSource

# Booted up, go enable things
$win.StartAccelerometer.enabled = true

$running = false

JOP = Java::Javax::swing::JOptionPane
SU = Java::Javax::swing::SwingUtilities

event_handlers = {nil => Proc.new{}}
event_handlers['start_accelerometer'] = Proc.new do
  $stderr.puts "Connecting to accelerometer"
  $point_source.connect
  $running = true
end

event_handlers['stop_accelerometer'] = Proc.new do
  $stderr.puts "Stopping accelerometer"
  $point_source.disconnect
  $running = false
end

def handle_errors
  err = $point_source.pollErrors
  if err
    SU.invokeLater do
      $win.StartAccelerometer.enabled = false
      $win.StopAccelerometerButton.enabled = false
    end
    JOP.showMessageDialog(nil, err.class.name.split(/:/).last,
            "Port Error", JOP::ERROR_MESSAGE);
  end
end

def poll_accelerometer
  if $running
    point = $point_source.poll
    if point
      $stdout.puts point.x
    end
  end
end

# main loop for polling
loop do
  event_handlers[$events.poll].call
  handle_errors
  poll_accelerometer
  sleep(1/50)
end
