require 'src/Gesture'

class Gesturecontroller

  def initialize
    @gestures = Array.new
      File.open('src/Gestures/gestures.yml', 'r') do |gesture_file|
        @gestures = Marshal.load(gesture_file) unless (File.size?(gesture_file) == nil)
      end
  end

  def add_gesture(newgesture)

    newgesture.convert_points_to_gesture
    
    @gestures << newgesture
  end

  def store_all_gestures
    File.open('src/Gestures/gestures.yml') { |out| Marshal.dump( @gestures, out) }
  end

end
