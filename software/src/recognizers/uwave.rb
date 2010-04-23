QUAN_WIN_SIZE = 8
QUAN_MOV_STEP = 4

def recognize(points, templates)
  distances = Array.new
  templates.each_index do |i|
    table = Array.new(templates[i].resampled_points.length * points.length)
    distances[i] = 1.0 * DTW_distance(points, points.length, templates[i].resampled_points, templates[i].resampled_points.length, points.length-1, templates[i].resampled_points.length-1, table)
    distances << (distances[i]/ (length + templates[i].length))
  end
  ret = 0.0
  distances.each_index do [i]
    if (distances[i] < distances[ret])
      ret = i
    end
  end
  
  return templates[ret]
end

def points_to_gesture(points)
  points = quantize_acc(points, points.length)
end

def quantize_acc(points, length)
  i = 0
  k = 0
  window = QUAN_WIN_SIZE
  temp = Array.new
  acc_data = Array.new
  while i < length
      if i + window
          window = length - i
      end #if
      for l in 0..2
          temp_point_vals = Array.new
          sum = 0
          for j in i...(window + i)
              sum += points[j].intArray[l] #note: this line needs some work to figure out a better way to do the .l thing
          end #for j
          temp_point_vals << (sum * 1.0/window)
      end #for l
      temp << Java::AccelerometerPoint.new(temp_point_vals)
      k = k + 1
      i = i + QUAN_MOV_STEP
  end #while

  #nonlinear quantization and copy quantized value to original buffer
  for i in 0...k
    temp_array = Array.new
    for l in 0..2
      temp_array[l] = case temp[i].intArray[l]
        when 20...400 then 16
        when 10..20 then 10 + (temp[i].intArray[l]-10)/10*5
        when -20..-10 then -10 + (temp[i].intArray[l] + 10)/10*5
        when -400...-20 then -16
      end
      acc_data[i] = Java::AccelerometerPoint.new(temp_array)
    end
  end
  return points
end

#input: int[], int, int[], int, int, int, int[]
def DTW_distance(sample1, length1, sample2, length2, i, j, table)
  s_distance = 0.0
  if (i < 0 || j < 0)
    return 2**30
  end
  table_width = length2
  local_distance = 0
  for k in 0..2
    local_distance = local_distance + ((sample1[i].intArray[k]-sample2[j].intArray[k])*(sample1[i].intArray[k]-sample2[j].intArray[k]))
  end
  if ((i == 0) && (j == 0))
    if (table[i*table_width+j] < 0)
      table[i*table_width+j] = local_distance
    end
    return local_distance
  elsif (i == 0)
    if (table[i*table_width+j] < 0)
      s_distance = DTW_distance(sample1, length1, sample2, length2, i-1, j, table)
    else
      s_distance = table[table[i*table_width+j-1]]
    end
  elsif (j == 0)
    if (table[(i-1)*table_width+j] < 0)
      s_distance = DTW_distance(sample1, length1, sample2, length2, i, j-1, table)
    else
      s_distance = table[i*table_width+j-1]
    end
  else
    if (table[i*table_width+j-1] < 0)
      s1 = DTW_distance(sample1, length1, sample2, length2, i, j-1, table)
    else
      s1 = table[i*table_width+j-1]
    end
    if (table[(i-1)*table_width+j] < 0)
      s2 = DTW_distance(sample1, length1, sample2, length2, i-1, j, table)
    else
      s2 = table[(i-1)*table_width+j]
    end
    if (table[(i-1)*table_width+j-1] < 0)
      s3 = DTW_distance(sample1, length1, sample2, length2, i-1, j-1, table)
    else
      s3 = table[(i-1)*table_width+j-1]
    end
    s_distance = s1 < s2 ? s1 : s2
    s_distance = s_distance < s3 ? s_distance : s3
  end

  table[i*table_width+j] = (local_distance + s_distance)
  return table[i*table_width+j], table
end

