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
  
  def continuous_match=(val)
    if @matcher && !val
      @matcher.kill
      @matcher = nil
    elsif @matcher.nil? && val
      @matcher = Thread.new do
        window = []
        dead_start = Time.now
        50.times do
          window << @point_source.take
        end
        
        loop do
          # try current set of points
          if Time.now-dead_start > 3 # cooldown between gestures
            magnitude = window.inject(0) do |max, point|
              max = [point.x.abs, point.z.abs, max].max
            end
            
            if magnitude > 50
              $stderr.puts "Trying a gesture with magnitude #{magnitude}"
              g = Gesture.new
              g.points = window.slice(1..-1)
              g.convert_points_to_gesture
            
              # re-set cooldown timer if we got a match
              dead_start = Time.now if g.test_gesture(@gestures, 0.55)
            end
          end
          
          # update sliding window
          window.shift
          window << @point_source.take
        end
      end
    end
  end
  
  def continuous_match
    return !!@matcher
  end

  def store_all_gestures
    File.open('src/Gestures/gestures.dat', 'w') { |out| Marshal.dump( @gestures, out) }
  end
end
