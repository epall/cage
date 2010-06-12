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
  
  button "start_stop" do
    if !model.running
      @point_source.connect
      model.start
    else
      @point_source.disconnect
      model.stop
    end
  end

  button "new_gesture" do
    if  !model.recording
      model.new_gesture
    else
      model.current_gesture.name = view_model.current_gesture.name
      model.current_gesture.action = view_model.current_gesture.action
      model.finish_gesture
    end
  end

  button "match_gesture" do
    if !model.matching
      model.new_gesture
      model.matching = true
    else
       model.test_gesture
    end
  end

  button "save_all_gestures" do
    model.store_all_gestures
  end

  button "delete_gesture" do
    model.selected_gesture_index = view_model.selected_gesture_index
    model.delete_gesture
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

  button "test_script" do
    begin
      javax.script.ScriptEngineManager.new.get_engine_by_name("AppleScript").eval(view_model.current_gesture.action)
    rescue => e
      javax.swing.JOptionPane.showMessageDialog(nil, e.cause.message, "Script error", javax.swing.JOptionPane::WARNING_MESSAGE)
    end
  end
  
  button "continuous_match" do
    model.continuous_match = view_model.continuous_match
  end

  def gesture_list_key_pressed(evt)
    if [8, 127].include? evt.key_code
      model.delete_gesture(view_model.selected_gesture_index)
    end
    update_view
  end

  def close
    super
    @point_source.disconnect
    model.store_all_gestures
  end
end
