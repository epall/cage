require "yaml"

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
    %%what am I going to do about recognizing the start & end of gestures?%
    %%also a question: how do I connect a ruby class like this to a GUI form?%
    %%ignore me for now, I'm working on getting this less angry%
    @gestures << newgesture
  end

  def storeallgestures
    gesturefile = File.open('Gestures/gestures.yml', 'w')
    @gestures.each do |gesture|
      YAML.dump(gesture, gesturefile)
    end
    gesturefile.close
  end

 end