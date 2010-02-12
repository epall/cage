class Gesture
	def initialize
      @points = Array.new
	end

	def addpoint(point)
        @points << point
    end

    def addaction(action)
      @action = action
    end

	def returnallpoints
	  return @points
    end

end
