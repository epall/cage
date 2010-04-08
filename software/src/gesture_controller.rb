require 'Gesture'

class GestureController
  attr_reader :running, :recording, :matching, :current_gesture
  attr_writer :point_source, :matching, :recording

  def initialize
    @current_gesture = Gesture.new
    @gestures = []
    File.open('src/Gestures/gestures.dat', 'r') do |gesture_file|
      @gestures = Marshal.load(gesture_file) unless (File.size?(gesture_file) == nil)
    end
    @running = false
  end

  def ready_to_record
    return @running && !@matching
  end

  def ready_to_match
    return @running && !@recording
  end

  def start
    @running = true
  end

  def stop
    @running = false
  end

  def new_gesture
    @point_source.clear
    @point_poller = Thread.new do
      loop do
        begin
          @current_gesture.add_point(@point_source.take)
        rescue => e
          $stderr.puts "Error when polling for points: #{e}"
        end
      end
    end
    @current_gesture = Gesture.new
    @recording = true
  end

  def finish_gesture
    @point_poller.kill
    @current_gesture.convert_points_to_gesture
    @gestures << @current_gesture
    @recording = false
  end

  def test_gesture
    @point_poller.kill
    @current_gesture.convert_points_to_gesture
    @recording = false
    @matching = false
    current_gesture.test_gesture(@gestures)
  end

  def store_all_gestures
    File.open('src/Gestures/gestures.dat', 'w') { |out| Marshal.dump( @gestures, out) }
  end
end
