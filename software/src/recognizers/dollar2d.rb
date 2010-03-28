require 'point'

module Dollar2D

  NUMSAMPLES = 40 #number of points to convert the raw points to
  SIZE = 127 #size of the box in bounding_box that all of the points get scaled to
  INFINITY = 2**30 #a reasonable analogue of infinity

  def points_to_gesture(points)
    new_points = resample(points, NUMSAMPLES)
    new_points = rotate_to_zero(new_points)
    new_points = scale_to_square(new_points)
    new_points = translate_to_origin(new_points)
    return new_points
  end

  def distance(point1, point2)
    #$stderr.puts "Point1 class = #{point1.class}, Point2 class = #{point2.class}"
    d = (point2.x - point1.x)**2 + (point2.z - point1.z)**2
    d = Math.sqrt(d)
    return d
  end

  def resample(points, numsamples)
    bigi = path_length(points) / (numsamples - 1)
    bigd = 0
    #$stderr.puts "bigi = #{bigi}"
    new_points = Array.new
    new_points << points[0]
    points.each_index do |i|
      if (i < 1)
      else
        d = distance(points[i-1], points[i])
        #$stderr.puts "i = #{i}, d = #{d}"
        if (bigd + d) >= bigi
          x = points[i-1].x + ((bigi - bigd)/ d) * (points[i].x - points[i-1].x)
          z = points[i-1].z + ((bigi - bigd)/ d) * (points[i].z - points[i-1].z)
          temp_point = Java::Cage::AccelerometerPoint.new(x, 0, z)
          new_points << temp_point
          points[i] = temp_point
          bigd = 0
        else
          bigd = bigd + d
        end
      end
    end
    return new_points
  end

  def path_length(points)
    d = 0
    points.each_index do |i|
      d = d + distance(points[i-1], points[i]) unless i < 1
    end
    #$stderr.puts "path_length = #{d}"
    return d
  end

  def centroid(points)
    x = 0
    z = 0
    points.each do |p|
      x = p.x + x
      z = p.z + z
    end
    x = x / points.size
    z = z / points.size
    return x, z
  end

  def rotate_by(points, theta)
    x, z = centroid(points)
    c = Java::Cage::AccelerometerPoint.new(x, 0, z)
    new_points = Array.new
    points.each do |point|
      x = (point.x - c.x)*Math.cos(theta) - (point.z - c.z)*Math.sin(theta) + c.x
      z = (point.x - c.x)*Math.sin(theta) - (point.z - c.z)*Math.cos(theta) + c.z
      new_point = Java::Cage::AccelerometerPoint.new(x, 0, z)
      new_points << new_point
    end
    return new_points
  end

  def rotate_to_zero(points)
    x, z = centroid(points)
    c = Java::Cage::AccelerometerPoint.new(x, 0, z)
    theta = Math.atan2((c.z - points[0].z),(c.x - points[0].x))
    new_points = rotate_by(points, -(theta))
    return new_points
  end

  def bounding_box(points)
    min_x = 0
    min_z = 0
    max_x = 0
    max_z = 0
    points.each do |point|
      max_x = point.x if max_x < point.x
      max_z = point.z if max_z < point.z
      min_x = point.x if min_x > point.x
      min_z = point.z if min_z > point.z
    end
    min_point = Java::Cage::AccelerometerPoint.new(min_x, 0, min_z)
    max_point = Java::Cage::AccelerometerPoint.new(max_x, 0, max_z)
    return min_point, max_point
  end

  def scale_to_square(points)
    min_point, max_point = bounding_box(points)
    b_width = max_point.x - min_point.x
    b_height = max_point.z - min_point.z
    new_points = Array.new
    points.each do |point|
      x = point.x*SIZE/b_width
      z = point.z*SIZE/b_height
      new_point = Java::Cage::AccelerometerPoint.new(x, 0, z)
      new_points << new_point
    end
    return new_points
  end

  def translate_to(points, k)
    x, z = centroid(points)
    c = Java::Cage::AccelerometerPoint.new(x, 0, z)
    new_points = Array.new
    points.each do |point|
      x = point.x - c.x
      z = point.z - c.z
      new_point = Java::Cage::AccelerometerPoint.new(x, 0, z)
      new_points << new_point
    end
    return new_points
  end

  def path_distance(points1, points2)
    d = 0
    min = minimum(points1.size, points2.size)
    points1.each_index do |i|
      d = d + distance(points1[i], points2[i]) unless i >= min
    end
    return d / min
  end

  def distance_at_angle(points, t, theta)
    new_points = rotate_by(points, theta)
    d = path_distance(points, t)
    return d
  end

  def minimum(x, z)
    return x if x < z
    return z if z < x
    return x if x == z
  end

  def translate_to_origin(points)
    c_x, c_z = centroid(points)
    newPoints = Array.new
    points.each do |p|
      x = p.x - c_x
      z = p.z - c_z
      q = Java::Cage::AccelerometerPoint.new(x,0,z)
      newPoints << q
    end
    return newPoints
  end

  def distance_at_best_angle(points, t, theta_a, theta_b, theta_delta)
    psi = (1/2)*(-1 + Math.sqrt(5))
    x1 = psi*theta_a + (1 - psi)*theta_b
    f1 = distance_at_angle(points, t, x1)
    x2 = (1 - psi)*theta_a + psi*theta_b
    f2 = distance_at_angle(points, t, x2)
    while ((theta_b - theta_a).abs > theta_delta)
      if (f1 < f2)
        theta_b = x2
        x2 = x1
        f2 = f1
        x1 = psi*theta_a + (1 - psi)*theta_b
        f1 = distance_at_angle(points, t, x1)
      else
        theta_a = x1
        x1 = x2
        f1 = f2
        x2 = (1 - psi)*theta_a + psi*theta_b
        f2 = distance_at_angle(points, t, x2)
      end
    end
    #$stderr.puts "f1 = #{f1}, f2 = #{f2}, minimum = #{minimum(f1, f2)}"
    return minimum(f1, f2)
  end

  def recognize(points, templates)
    b = INFINITY
    t_prime = 0
    score = 0
    sizesqrt = Math.sqrt(SIZE**2 + SIZE**2)
    templates.each do |t|
      d = distance_at_best_angle(points, t.resampled_points, -45, 45, 2)
      #$stderr.puts "d = #{d}"
      if d < b
        b = d
        t_prime = t
        score = 1 - b / ((1/2.0)*(sizesqrt))
        #$stderr.puts "Score = #{score}"
      end
    end
    return t_prime, score
  end
end