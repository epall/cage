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
  SU.invokeLater do
    $win.liveDisplayButton.enabled = true
  end
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
  $newgesture.name = $win.gestureName.getText
  $newgesture.action = $win.AppScriptPane.getText
  $recording = true
end

event_handlers['stop_gesture'] = Proc.new do
  $stderr.puts "Stopping gesture"
  $recording = false
  $gesturecontroller.add_gesture($newgesture)
end

event_handlers['exit'] = Proc.new do
  $stderr.puts "Dumping gestures to disk"
  $gesturecontroller.store_all_gestures
end

event_handlers['save'] = Proc.new do
  $stderr.puts "Saving gestures to disk"
  $gesturecontroller.store_all_gestures
end

event_handlers['start_live_display'] = Proc.new do
  $livedisplay = true
end

event_handlers['stop_live_display'] = Proc.new do
  $stderr.puts "Stopping live display"
  $livedisplay = false
end

event_handlers['plot_gesture'] = Proc.new do
  if $newgesture
    plotter = Java::GesturePlotter.new
    plotter.gesture = $newgesture
    plotter.setBounds(600, 100, 500, 500)
    
    SU.invokeLater do
      plotter.visible = true
    end
  end
end

event_handlers['match_gesture'] = Proc.new do
  $gesturecontroller.test_gesture($newgesture)
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
  if ($running)
    point = $point_source.poll
    if point
      $newgesture.add_point(point) if $recording
      if $livedisplay
        $win.liveDisplay.sliderX.value = point.x
        $win.liveDisplay.sliderY.value = point.y
        $win.liveDisplay.sliderZ.value = point.z
      end
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
