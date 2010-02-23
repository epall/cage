module Dollar2D
  NUMSAMPLES = 64
  SIZE = 250
  INFINITY = 2**30

  def points_to_gesture(points)
    new_points = resample(points, NUMSAMPLES)
    new_points = rotate_to_zero(new_points)
    new_points = scale_to_square(new_points)
    new_points = translate_to_origin(new_points)
    return new_points
  end

  def distance(point1, point2)
    d = (point2.x - point1.x)**2 + (point2.y - point1.y)**2
    d = Math.sqrt(d)
    return d
  end

  def resample(points, numsamples)
    bigi = path_length(points) / (numsamples - 1)
    bigd = 0
    new_points = Array.new
    new_points << points[0]
    points.each_index do |i|
      if (i < 1)
      else
        d = distance(points[i-1], points[i])
        if (bigd + d) >= bigi
          x = points[i-1].x + ((bigi - bigd)/ d) * (points[i].x - points[i-1].x)
          y = points[i-1].y + ((bigi - bigd)/ d) * (points[i].y - points[i-1].y)
          temp_point = Point.new(x, y, 0)
          new_points << temp_point
          points[i] = temp_point
          bigd = 0
        else
          bigd = bigd + d
        end
      end
    end
  end

  def path_length(points)
    d = 0
    points.each_index do |i|
      d = d + distance(points[i-1], points[i]) unless i < 1
    end
    return d
  end

  def centroid(points)
    points.each do |p|
      x = p.x + x
      y = p.y + y
    end
    x = x / points.size
    y = y / points.size
    return x, y
  end

  def rotate_by(points, theta)
    x, y = centroid(points)
    c = Point.new(x, y, 0)
    new_points = Array.new
    points.each do |point|
      x = (point.x - c.x)*Math.cos(theta) - (point.y - c.y)*Math.sin(theta) + c.x
      y = (point.x - c.x)*Math.sin(theta) - (point.y - c.y)*Math.cos(theta) + c.y
      new_point = Point.new(x, y, 0)
      new_points << new_point
    end
    return new_points
  end

  def rotate_to_zero(points)
    x, y = centroid(points)
    c = Point.new(x, y, 0)
    theta = Math.atan2((c.y - points[0].y),(c.x - points[0].x))
    new_points = rotate_by(points, -(theta))
    return new_points
  end

  def bounding_box(points)
    min_x = 0
    min_y = 0
    max_x = 0
    max_y = 0
    points.each do |point|
      max_x = point.x if max_x < point.x
      max_y = point.y if max_y < point.y
      min_x = point.x if min_x > point.x
      min_y = point.y if min_y > point.y
    end
    min_point = Point.new(min_x, min_y, 0)
    max_point = Point.new(max_x, max_y, 0)
    return min_point, max_point
  end

  def scale_to_square(points)
    min_point, max_point = bounding_box(points)
    b_width = max_point.x - min_point.x
    b_height = max_point.y - min_point.y
    new_points = Array.new
    points.each do |point|
      x = point.x*SIZE/b_width
      y = point.y*SIZE/b_height
      new_point = Point.new(x, y, 0)
      new_points << new_point
    end
    return new_points
  end

  def translate_to(points, k)
    x, y = centroid(points)
    c = Point.new(x, y, 0)
    new_points = Array.new
    points.each do |point|
      x = point.x - c.x
      y = point.y - c.y
      new_point = Point.new(x, y, 0)
      new_points << new_point
    end
    return new_points
  end

  def path_distance(points1, points2)
    d = 0
    points.each_index do |i|
      d = d + distance(points1[i], points2[i])
    end
    return d / points1.size
  end

  def distance_at_angle(points, t, theta)
    new_points = rotate_by(points, theta)
    d = path_distance(points, t)
    return d
  end

  def minimum(x, y)
    return x if x < y
    return y if y < x
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
    return minimum(f1, f2)
  end

  def recognize(points, templates)
    b = INFINITY
    sizesqrt = Math.sqrt(size**2 + size**2)
    templates.each do |t|
      d = distance_at_best_angle(points, t, -45, 45, 2)
      if d < b
        b = d
        t_prime = t
        score = 1 - b / ((1/2)*(sizesqrt))
      end
    end
    return t_prime, score
  end
end