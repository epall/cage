class Gesturecontroller

  def initialize
    @gestures = Array.new
      File.open('Gestures/gestures.yml', 'r') do |gesture_file|
        YAML.load_documents(gesture_file) { |gesture| @gestures << gesture }
      end
    @dongle = Usbmodem.new()
    @dongle.connect("COM4")
  end

  def createnewgesture
    newgesture = Gesture.new
    
    @gestures << newgesture
  end

  def storeallgestures
    File.open('Gestures/gestures.yml') { |out| YAML.dump( @gestures, out) }
  end

 end