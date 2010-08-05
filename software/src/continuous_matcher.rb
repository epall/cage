#This class enables "continuous" matching of gestures against the watch's motion: it looks for periods of activity followed by periods of stillness.
#It assumes the activity is a gesture, and sends it to the recognizer and tests it against the gesture library. This way, you don't need to hit the
#"Match gesture" button every time you want to match a gesture.
#Author:: Eric Allen
class ContinuousMatcher
  attr_writer :point_source

  STILLNESS_WINDOW_SIZE = 10
  STILLNESS_THRESHOLD = 15
  MINIMUM_GESTURE_LENGTH = 10

  def initialize(source, controller)
    @point_source = source
    @controller = controller
  end

  def running=(val)
    if val
      start
    else
      stop
    end
  end

  def running
    !!@thread
  end

  def start
    $stderr.puts "Starting continuous mode"
    @thread = Thread.new { threadloop }
  end

  def stop
    $stderr.puts "Stopping continuous mode"
    @thread.kill unless @thread.nil?
    @thread = nil
  end

  private

  #The loop that the continuous matcher goes through when it's turned on.
  def threadloop
    window = []
    gesture = nil

    # start with some data
    STILLNESS_WINDOW_SIZE.times do
      window << @point_source.take
    end

    # continuously try to match
    loop do
      if still?(window)
        if gesture && gesture.length > MINIMUM_GESTURE_LENGTH+STILLNESS_WINDOW_SIZE
          # we just finished a gesture
          g = Gesture.new
          g.points = gesture[0..-(STILLNESS_WINDOW_SIZE)] # chop off the stillness at the end
          g.convert_points_to_gesture
          g.test_gesture(@controller.gestures)
        end
        gesture = nil
      else
        gesture ||= [] # make sure we've started a gesture
        gesture << window.last
      end

      # update sliding window
      window.shift
      window << @point_source.take
    end
  end
 #Figures out if the average movement over the window passed to the function is less than the STILLNESS_THRESHOLD set in the class.
  def still?(window)
    x_avg = window[0..-2].inject(0.0){|sum, p| sum + p.x}.to_f / window.size-1
    y_avg = window[0..-2].inject(0.0){|sum, p| sum + p.y}.to_f / window.size-1
    z_avg = window[0..-2].inject(0.0){|sum, p| sum + p.z}.to_f / window.size-1

    #$stderr.puts "(#{(window.last.x-x_avg).abs}, #{(window.last.y-y_avg)}, #{(window.last.z-z_avg).abs})"

    return (window.last.x-x_avg).abs < STILLNESS_THRESHOLD &&
            (window.last.y-y_avg).abs < STILLNESS_THRESHOLD &&
            (window.last.z-z_avg).abs < STILLNESS_THRESHOLD
  end
end
