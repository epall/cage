require 'src/Gesture'
require 'yaml'

class Gesturecontroller

  def initialize
    @gestures = Array.new
      #File.open('src/Gestures/gestures.yml', 'r') do |gesture_file|
       # @gestures = YAML.load(gesture_file)
      #end
  end

  def add_gesture(newgesture)

    newgesture.convert_points_to_gesture
    
    @gestures << newgesture
  end

  def store_all_gestures
    File.open('src/Gestures/gestures.yml') { |out| YAML.dump( @gestures, out) }
  end

 end
