class Gesture
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
    end

	def returnallpoints
	  return @points
    end

end
