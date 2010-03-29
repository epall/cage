require 'recognizers/dollar2d'
require 'point'

class Gesture
  include Java::Cage::Gesture
  include Dollar2D
  
  MIN_SCORE = 0.5

  def initialize
    @points = []
  end

  def add_point (java_point)
    @points << java_point
  end

  def convert_points_to_gesture
    $stderr.puts @points.length
    @resampled_points = points_to_gesture(@points)
    $stderr.puts @resampled_points.length
    $stderr.puts "Gesture name is #{@name}, action is #{@action}"
  end

  def num_points
    return @resampled_points.count
  end

  def get_point (index)
    p = @resampled_points[index]
    return Java::Cage::AccelerometerPoint.new(p.x, p.y, p.z)
  end

  def do_action
    begin
      javax.script.ScriptEngineManager.new.get_engine_by_name("AppleScript").eval(@action)
    rescue => e
      $stderr.puts "Your AppleScript-fu sucks:"
      $stderr.puts e.cause.message
    end
  end

  # Looks through test_gestures to find the best match against self
  def test_gesture(test_gestures)
    t_prime, score = recognize(@resampled_points, test_gestures)
    #t_prime is the gesture from test_gestures that is the best match, score is the score of that match

    t_prime.do_action if score > MIN_SCORE
    $stderr.puts "#{t_prime.name} is the best recognized gesture, with a score of #{score}"
  end

  attr_reader :points, :resampled_points
  attr_accessor :action, :name

  def marshal_dump
    return [@name, @action, @resampled_points]
  end

  def marshal_load(variables)
    @name, @action, @resampled_points = variables
  end
end
