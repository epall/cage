require 'src/recognizers/dollar2d'

class Gesture
  include Java::Gesture
  include Dollar2D

  def initialize
    @points = Array.new
  end

  def add_point (point)
    @points << point
  end

  def convert_points_to_gesture
    $stderr.puts @points.length
    @resampled_points = points_to_gesture(@points)
    $stderr.puts @resampled_points.length
  end

  def num_points
    return @points.count
  end

  def get_point (index)
    return @points[index]
  end

  def do_action
    #doesn't do anything until rb-appscript can be installed
  end

  def test_gesture(test_gestures)
    t_prime, score = recognize(@resampled_points, test_gestures)
    #t_prime is the gesture from test_gestures that is the best match, score is the score of that match
    $stderr.puts "#{t_prime.action} is the best recognized gesture, with a score of #{score}"
  end

  attr_reader :points, :resampled_points
  attr_accessor :action
end
