class RecorderView < ApplicationView
  set_java_class 'cage.ui.MainWindow'

  map :view => "startStop.text", :model => :running, :using => [:running_text, nil]
  map :view => "showLiveDisplay.enabled", :model => :running, :using => [:default, nil]
  map :view => "newGesture.enabled", :model => :ready_to_record, :using => [:default, nil]
  map :view => "newGesture.text", :model => :recording, :using => [:recording_text, nil]
  map :view => "matchGesture.enabled", :model => :ready_to_match, :using => [:default, nil]
  map :view => "continuousMatch.enabled", :model => :ready_to_match, :using => [:default, nil]
  map :view => "matchGesture.text", :model => :matching, :using => [:matching_text, nil]
  map :view => "plotGesture.enabled,", :model => :ready_to_plot, :using => [:default, nil]
  map :view => "gestureList.listData", :model => :gestures, :using => [:java_gestures, nil]
  map :view => :editing_gesture, :model => :editing_gesture

  map :view => "gestureName.text", :model => "current_gesture.name", :using => [:edit_gesture_name, :default]
  map :view => "script.text", :model => "current_gesture.action", :using => [:edit_gesture_action, :default]
  map :view => "gestureList.selectedIndex", :model => :selected_gesture_index, :using => [nil, :default]
  map :view => "continuousMatch.selected", :model => :continuous_match, :using => [nil, :default]

  attr_accessor :editing_gesture

  def invert(value)
    return !value
  end

  def edit_gesture_name(name)
    if @editing_gesture
      return name
    else
      return gestureName.text
    end

  end

  def edit_gesture_action(action)
    if @editing_gesture
      return action
    else
      return script.text
    end
  end

  def java_gestures(gestures)
    # to_s should be getting called by toString, but it isn't...
    return gestures.map(&:to_s).to_java
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
