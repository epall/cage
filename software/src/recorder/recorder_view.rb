class RecorderView < ApplicationView
  set_java_class 'cage.ui.MainWindow'

  map :view => "startAccelerometer.enabled", :model => :running, :using => [:invert, nil]
  map :view => "stopAccelerometer.enabled", :model => :running, :using => [:default, nil]
  map :view => "showLiveDisplay.enabled", :model => :running, :using => [:default, nil]
  map :view => "newGesture.enabled", :model => :ready_to_record, :using => [:default, nil]
  map :view => "matchGesture.enabled", :model => :ready_to_match, :using => [:default, nil]
  map :view => "stopGesture.enabled", :model => :recording, :using => [:default, nil]
  map :view => "stopMatch.enabled", :model => :matching, :using => [:default, nil]

  map :view => "gestureName.text", :model => "current_gesture.name", :using => [nil, :default]
  map :view => "script.text", :model => "current_gesture.action", :using => [nil, :default]

  def invert(value)
    return !value
  end
end
