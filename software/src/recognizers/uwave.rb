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
      if temp[i].l > 20 #this, fix it
        temp[i].l
      end
    end
  end
end				