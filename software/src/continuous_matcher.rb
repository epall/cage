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
