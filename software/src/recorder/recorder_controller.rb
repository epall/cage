require 'gesture_controller'

class RecorderController < ApplicationController
  set_model 'GestureController'
  set_view 'RecorderView'
  set_close_action :exit

  def initialize
    super
    @point_source = Java::CagePort::PointSource.new
    model.point_source = @point_source
  end
  
  button "start_accelerometer" do
    @point_source.connect
    model.start
  end

  button "stop_accelerometer" do
    @point_source.disconnect
    model.stop
  end

  button "new_gesture" do
    model.new_gesture
  end

  button "stop_gesture" do
    model.current_gesture.name = view_model.current_gesture.name
    model.current_gesture.action = view_model.current_gesture.action
    model.finish_gesture
  end

  button "save_all_gestures" do
    model.store_all_gestures
  end

  button "match_gesture" do
    model.new_gesture
    model.matching = true
  end

  button "stop_match" do
    model.test_gesture
  end

  button "show_live_display" do
    controller = LiveDisplayController.instance
    @point_source.clear
    controller.point_source = @point_source
    controller.open
  end

  button "plot_gesture" do
    plotter = Java::CageUi::GesturePlotter.new
    plotter.gesture = model.current_gesture
    plotter.visible = true
  end

  def close
    super
    @point_source.disconnect
    model.store_all_gestures
  end
end
