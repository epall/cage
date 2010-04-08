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
    if :running
      $stderr.puts "Running = #{:running}"
      @point_source.disconnect
      model.stop
    else
      $stderr.puts "Not running"
      @point_source.connect
      model.start
    end
  end

  button "new_gesture" do
    if  !:recording
      model.new_gesture
    else
      model.current_gesture.name = view_model.current_gesture.name
    model.current_gesture.action = view_model.current_gesture.action
    model.finish_gesture
    end
  end

  button "save_all_gestures" do
    model.store_all_gestures
  end

  button "match_gesture" do
    if !:matching
      model.new_gesture
      model.matching = true
    else
       model.test_gesture
    end
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

  def close
    super
    @point_source.disconnect
    model.store_all_gestures
  end
end
