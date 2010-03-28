class LiveDisplayView < ApplicationView
  set_java_class 'cage.ui.LiveDisplay'

  map :model => 'point.x', :view => 'sliderX.value'
  map :model => 'point.y', :view => 'sliderY.value'
  map :model => 'point.z', :view => 'sliderZ.value'
end
