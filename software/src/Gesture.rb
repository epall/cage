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

  def addaction(action)
    @action = action
  end

  def convert_points_to_gesture
    $stderr.puts @points.length
    @resampled_points = points_to_gesture(@points)
  end

  def return_all_points
    return @points
  end

  def numPoints
    return @points.count
  end

  def getPoint(index)
    return @points[index]
  end

  def test_gesture(test_gestures)
    t_prime, score = recognize(@resampled_points, test_gestures)
    #t_prime is the gesture from test_gestures that is the best match, score is the score (0-1) of that match
  end
end
