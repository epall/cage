require 'Gesture'
require 'continuous_matcher'

#This class holds all of the gestures made in the program, and controls communication with the PointSource connected to the watch.
#It also does all of the creation, editing and deleting of gestures.
class GestureController
  attr_accessor :recording, :selected_gesture_index, :editing_gesture
  attr_reader :running, :matching, :current_gesture, :gestures 
  attr_writer :matching

  #reads in the already created gestures from gestures.dat and initializes several variables
  def initialize
    @current_gesture = Gesture.new
    @gestures = []
    File.open('Gestures/gestures.dat', 'r') do |gesture_file|
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

  #Starts recording a new gesture. NOTE: Name and Action data are added at this point.
  def new_gesture
    @editing_gesture = false
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

  #This stops recording a gesture from the watch, and resamples the points through the gesture recognizer.
  def finish_gesture
    @point_poller.kill
    @current_gesture.convert_points_to_gesture
    @gestures << @current_gesture
    @recording = false
    @editing_gesture = false
  end

  #This turns the just-recorded gesture into a "test gesture," which will be matched against the various gestures in the recognizer.
  def test_gesture
    @point_poller.kill
    @current_gesture.name = "match gesture"
    @current_gesture.action = "none"
    @current_gesture.convert_points_to_gesture
    @recording = false
    @matching = false
    @current_gesture.test_gesture(@gestures)
  end

  def delete_gesture
    $stderr.puts("Selected gesture index = #{selected_gesture_index}")
    @gestures.delete_at(selected_gesture_index)
  end

  #This copies the gesture at selected_gesture_index into @current_gesture, and then deletes it from the gesture list, so it can be edited in the GUI.
  def edit_gesture
    @editing_gesture = true
    @current_gesture = @gestures[selected_gesture_index]
    @gestures.delete_at(selected_gesture_index)
  end

  def continuous_match=(val)
    @continuous_match = val
    @continuous_matcher.running = !!val if @continuous_matcher
  end
  
  def continuous_match
    return @continuous_match
  end

  #This dumps all the gestures to a Marshal file.
  def store_all_gestures
    File.open('Gestures/gestures.dat', 'w') { |out| Marshal.dump( @gestures, out) }
  end

  #This sets the current source of points for the gestures, as well as initializing a new ContinuousMatcher
  def point_source=(source)
    @point_source = source
    @continuous_matcher = ContinuousMatcher.new(source, self)
  end
end
