require 'src/gesturecontroller'

$events = $win.events
$point_source = $win.pointSource

$gesturecontroller = Gesturecontroller.new
$newgesture = Gesture.new

# Booted up, go enable things
$win.StartAccelerometer.enabled = true

$running = false
$recording = false

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

event_handlers['new_gesture'] = Proc.new do
  $stderr.puts "Recording new gesture"
  $newgesture = Gesture.new
  $recording = true
end

event_handlers['stop_gesture'] = Proc.new do
  $stderr.puts "Stopping gesture"
  $recording = false
  $gesturecontroller.add_gesture($newgesture)
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
  if ($running & $recording)
    point = $point_source.poll
    if point
      $newgesture.add_point(point)
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
