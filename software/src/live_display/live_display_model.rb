class LiveDisplayModel
  attr_accessor :point

  def initialize
    @point = Java::Cage::AccelerometerPoint.new(0,0,0)
  end
end
