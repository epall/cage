require 'recognizers/Uwave'
require 'point'

#This class holds all of the various data associated with a gesture:
#
# [points] the raw points from the watch
# [resampled_points] the result of running the raw points through the included recognizer
# [action] the AppleScript example associated with the gesture
# [name] the human-readable name of the gesture
# points, name, and action all have attribute accessors, resampled_points only has a reader
# Author:: Michael O'Keefe

class Gesture
  attr_reader :resampled_points
  attr_accessor :action, :name, :points

  include Java::Cage::Gesture
  include Uwave

  #The minimum match score that must be reported by the recognizer for the action to be executed
  MIN_SCORE = 0.5

  #constructor
  def initialize
    @points = []
  end

  #appends a Java::AccelerometerPoint to the array @points
  def add_point (java_point)
    @points << java_point
  end

  def to_s
    return name
  end

  #runs @points through the gesture recognizer and saves the result to @resampled_points
  def convert_points_to_gesture
    $stderr.puts @points.length
    @resampled_points = points_to_gesture(@points)
    $stderr.puts @resampled_points.length
    $stderr.puts "Gesture name is #{@name}, action is #{@action}"
  end

  def num_points
    return @resampled_points.count
  end

  def length
    return @points
  end

  #creates a new Java::Cage::AccelerometerPoint object containing the same acceleration values as point p
  def get_point (index)
    p = @resampled_points[index]
    return Java::Cage::AccelerometerPoint.new(p.x, p.y, p.z)
  end

  #executes the action specified in @action. At the moment, only supports AppleScript, but has provisions for windows.
  def do_action
    if $os_type == "OSX"
      begin
        `osascript -e '#{@action}'`
      rescue => e
        javax.swing.JOptionPane.showMessageDialog(nil, "Your AppleScript didn't work", "Script error", javax.swing.JOptionPane::WARNING_MESSAGE)
      end
    elsif $os_type == "WIN"
      
    end
  end

  # Looks through test_gestures to find the best match against self
  def test_gesture(test_gestures, min_score=MIN_SCORE)
    t_prime, score = recognize(@resampled_points, test_gestures)
    #t_prime is the gesture from test_gestures that is the best match, score is the score of that match
    t_prime.do_action if score > min_score
    $stderr.puts "#{t_prime.name} is the best recognized gesture, with a score of #{score}"
    return (score > min_score)
  end

  def marshal_dump
    return [@name, @action, @resampled_points]
  end

  def marshal_load(variables)
    @name, @action, @resampled_points = variables
  end
end
