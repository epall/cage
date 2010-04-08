class RecorderView < ApplicationView
  set_java_class 'cage.ui.MainWindow'

  map :view => "startStop.text", :model => :running, :using => [:running_text, nil]
  map :view => "showLiveDisplay.enabled", :model => :running, :using => [:default, nil]
  map :view => "newGesture.enabled", :model => :ready_to_record, :using => [:default, nil]
  map :view => "newGesture.text", :model => :recording, :using => [:recording_text, nil]
  map :view => "matchGesture.enabled", :model => :ready_to_match, :using => [:default, nil]
  map :view => "matchGesture.text", :model => :matching, :using => [:matching_text, nil]

  map :view => "gestureName.text", :model => "current_gesture.name", :using => [nil, :default]
  map :view => "script.text", :model => "current_gesture.action", :using => [nil, :default]

  def invert(value)
    return !value
  end

  def running_text(is_running)
    if is_running
      return "Stop Accelerometer"
    else
      return "Start Accelerometer"
    end
  end

  def recording_text(is_recording)
    if is_recording
      return "Stop Recording"
    else
      return "Record new gesture"
    end
  end

  def matching_text(is_matching)
    if is_matching
      return "Complete Match"
    else
      return "Record Match"
    end
  end
end
