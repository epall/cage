class Gesturecontroller

  def initialize
    @gestures = Array.new
      File.open('Gestures/gestures.yml', 'r') do |gesture_file|
        @gestures = YAML.load(gesture_file)
      end
  end

  def createnewgesture
    newgesture = Gesture.new
    
    @gestures << newgesture
  end

  def storeallgestures
    File.open('Gestures/gestures.yml') { |out| YAML.dump( @gestures, out) }
  end

 end