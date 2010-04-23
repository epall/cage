class Point
  
  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  attr_accessor :x, :y, :z

  def int_array
    an_array = Array.new(3)
    an_array[0] = @x
    an_array[1] = @y
    an_array[2] = @z
    return an_array
  end

  def[](num)
    if num == 0
      return @x
    elsif num == 1
      return @y
    elsif num == 2
      return @z
    else
      return nil
    end
  end
  
end