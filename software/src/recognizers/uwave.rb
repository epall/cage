QUAN_WIN_SIZE
QUAN_MOV_STEP
DIMENSION

def points_to_gesture(points)

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
      for l in x..z
          temp_point_vals = Array.new
          sum = 0
          for j in i...(window + i)
              sum += points[j].l #note: this line needs some work to figure out a better way to do the .l thing
          end #for j
          temp_point_vals << (sum * 1.0/window)
      end #for l
      temp << Java::AccelerometerPoint.new(temp_point_vals)
      k = k + 1
      i = i + QUAN_MOV_STEP
  end #while

  #nonlinear quantization and copy quantized value to original buffer
  for i in 0...k
    for l in x..z
      acc_data[i].l = case temp[i].l
        when 20...400 then 16
        when 10..20 then 10 + (temp[i].l-10)/10*5
        when -20..-10 then -10 + (temp[i].l + 10)/10*5
        when -400...-20 then -16
      end
    end
  end
  return k
end

def DTWdistance(sample1, length1, sample2, length2, i, j, table)
  if (i < 0 || j < 0)
    return 2**30
  end
  table_width = length2
  local_distance = 0
  for k in x..z
    local_distance = local_distance + ((sample1[i].k-sample2[j].k)*(sample1[i].k-sample2[j].k))
  end
  if ((i == 0) && (j == 0))
    if (table[i*table_width+j] < 0)
      table[i*table_width+j] = local_distance
    end
    return local_distance
  end
end