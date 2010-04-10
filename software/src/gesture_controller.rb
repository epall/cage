require 'Gesture'

class GestureController
  attr_accessor :recording, :selected_gesture_index
  attr_reader :running, :matching, :current_gesture, :gestures
  attr_writer :point_source, :matching

  def initialize
    @current_gesture = Gesture.new
    @gestures = []
    File.open('src/Gestures/gestures.dat', 'r') do |gesture_file|
      @gestures = Marshal.load(gesture_file) unless (File.size?(gesture_file) == nil)
    end
    @running = false
    @recording = false
    @matching = false
  end

  def ready_to_record
    return @running && !@matching
  end

  def ready_to_match
    return @running
  end

  def ready_to_plot
    return @running && !@recording && !@matching
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
    @current_gesture.test_gesture(@gestures)
  end

  def delete_gesture(idx)
    @gestures.delete_at(idx)
  end

  def store_all_gestures
    File.open('src/Gestures/gestures.dat', 'w') { |out| Marshal.dump( @gestures, out) }
  end
end
