require 'point'

#The first recognizer module written for CAGE, the $1 Recognizer was developed by the University of Washington.
#More information about the theory behind the recognizer is available at: http://depts.washington.edu/aimgroup/proj/dollar
#The module currently only uses 2 dimensions for matching (x and z), due to the limitations of the $1 Recognizer's design.
#Also, it doesn't work terribly well with the Chronos watch.
#
#Author:: Michael O'Keefe

module Dollar2D

  NUMSAMPLES = 40 #number of points to convert the raw points to
  SIZE = 127 #size of the box in bounding_box that all of the points get scaled to
  INFINITY = 2**30 #a reasonable analogue of infinity

  def points_to_gesture(points) #INPUT: an Array of Java::AccelerometerPoint objects
    new_points = resample(points, NUMSAMPLES)
    new_points = rotate_to_zero(new_points)
    new_points = scale_to_square(new_points)
    new_points = translate_to_origin(new_points)
    return new_points
  end #OUTPUT: a resampled, scaled, and rotated Array of Ruby Point objects

  def distance(point1, point2) #INPUT: two points
    d = (point2.x - point1.x)**2 + (point2.z - point1.z)**2
    d = Math.sqrt(d)
    return d
  end #OUTPUT: the distance in the xz plane between the two points

  def resample(points, numsamples) #INPUT: an Array of point objects
    bigi = path_length(points) / (numsamples - 1)
    bigd = 0
    new_points = [points[0]]
    i = 1
    while i < points.length do
      d = distance(points[i-1], points[i])
      if (bigd + d) >= bigi
        x = points[i-1].x + ((bigi - bigd)/ d) * (points[i].x - points[i-1].x)
        z = points[i-1].z + ((bigi - bigd)/ d) * (points[i].z - points[i-1].z)
        temp_point = Point.new(x, 0, z)
        new_points << temp_point
        points.insert(i+1, temp_point)
        bigd = 0
      else
        bigd = bigd + d
      end
      i += 1
    end
    return new_points
  end #OUTPUT: an Array of Ruby Point objects, which have been resampled to be approximately numsamples objects

  def path_length(points) #INPUT: an Array of Points
    d = 0
    points.each_index do |i|
      d = d + distance(points[i-1], points[i]) unless i < 1
    end
    return d
  end #OUTPUT: the total length of the path defined by the input points in the xy plane

  def centroid(points) #INPUT: an Array of Points
    x = 0
    z = 0
    points.each do |p|
      x = p.x + x
      z = p.z + z
    end
    x = x / points.size
    z = z / points.size
    return x, z
  end #OUTPUT: the x & z points of the centroid of the points

  def rotate_by(points, theta) #INPUT: an Array of Points, and an angle theta between -PI and PI
    x, z = centroid(points)
    c = Point.new(x, 0, z)
    new_points = Array.new
    points.each do |point|
      x = (point.x - c.x)*Math.cos(theta) - (point.z - c.z)*Math.sin(theta) + c.x
      z = (point.x - c.x)*Math.sin(theta) - (point.z - c.z)*Math.cos(theta) + c.z
      new_point = Point.new(x, 0, z)
      new_points << new_point
    end
    return new_points
  end #OUTPUT: an Array of Points, rotated in the xz plane around the centroid by theta

  def rotate_to_zero(points) #INPUT: an Array of Points
    x, z = centroid(points)
    c = Point.new(x, 0, z)
    theta = Math.atan2((c.z - points[0].z),(c.x - points[0].x))
    new_points = rotate_by(points, -(theta))
    return new_points
  end #OUTPUT: an Array of Points, rotated about the centroid so the x and z points of points[0] are at 0

  def bounding_box(points) #INPUT: an Array of Points
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
    min_point = Point.new(min_x, 0, min_z)
    max_point = Point.new(max_x, 0, max_z)
    return min_point, max_point
  end #OUTPUT: the Points at the lower left and upper right of a box that bounds all of the points.

  def scale_to_square(points) #INPUT: an Array of Points
    min_point, max_point = bounding_box(points)
    b_width = max_point.x - min_point.x
    b_height = max_point.z - min_point.z
    new_points = Array.new
    points.each do |point|
      x = point.x*SIZE/b_width
      z = point.z*SIZE/b_height
      new_point = Point.new(x, 0, z)
      new_points << new_point
    end
    return new_points
  end #OUTPUT: an Array of Points scaled to a square of size SIZE.

  def path_distance(points1, points2) #INPUT: 2 Arrays of Points
    d = 0
    min = minimum(points1.size, points2.size)
    points1.each_index do |i|
      d = d + distance(points1[i], points2[i]) unless i >= min
    end
    return d / min
  end #OUTPUT: the average distance between each pair of points in points1 and points2

  def distance_at_angle(points, t, theta)#INPUT: 2 Arrays of Points "points" and "t", and an angle "theta"
    new_points = rotate_by(points, theta)
    d = path_distance(points, t)
    return d
  end #OUTPUT: the distance between points and t after points has been rotated by theta

  def minimum(x, z) #INPUT: two numbers
    return x if x < z
    return z if z < x
    return x if x == z
  end #OUTPUT: the smaller of the two numbers, or x if x & z are equal

  def translate_to_origin(points) #INPUT: an Array of Points
    c_x, c_z = centroid(points)
    newPoints = Array.new
    points.each do |p|
      x = p.x - c_x
      z = p.z - c_z
      q = Point.new(x,0,z)
      newPoints << q
    end
    return newPoints
  end #OUTPUT: an Array of Points, shifted in the xz plane by the centroid

  def distance_at_best_angle(points, t, theta_a, theta_b, theta_delta) #INPUT: 2 Arrays of Points "points" and "t", and 3 angles "theta a", "theta b", and "theta delta"
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
  end #OUTPUT: the minimum path distance between points and t, after rotating between theta a and theta b by steps of theta delta

  def recognize(points, templates) #INPUT: an Array of Points, and an Array of Gestures
    b = INFINITY
    t_prime = 0
    score = 0
    sizesqrt = Math.sqrt(SIZE**2 + SIZE**2)
    templates.each do |t|
      d = distance_at_best_angle(points, t.resampled_points, -45, 45, 2)
      if d < b
        b = d
        t_prime = t
        score = 1 - b / ((1/2.0)*(sizesqrt))
      end
    end
    return t_prime, score
  end
end #OUTPUT: the Gesture object that's the closest match to the Array of Points, and the score between 0 and 1 of the match