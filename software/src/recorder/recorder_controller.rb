require 'gesture_controller'
#This class uses the "button" function defined in application_controller.rb to define actions for Java buttons.
#Buttons are defined in Ruby using underlines ("foo_bar") and in Java using camelCase ("fooBar").
#Author:: Eric Allen
#Author:: Michael O'Keefe

class RecorderController < ApplicationController
  set_model 'GestureController'
  set_view 'RecorderView'
  set_close_action :exit

  def initialize
    super
    @point_source = Java::CagePort::PointSource.new
    model.point_source = @point_source
  end

  #starts and stops the accelerometer
  button "start_stop" do
    if !model.running
      @point_source.connect
      model.start
    else
      @point_source.disconnect
      model.stop
    end
  end

  #starts recording a new gesture
  button "new_gesture" do
    if  !model.recording
      model.new_gesture
    else
      model.current_gesture.name = view_model.current_gesture.name
      model.current_gesture.action = view_model.current_gesture.action
      model.finish_gesture
    end
  end

  #starts recording a new gesture to match with existing gestures
  button "match_gesture" do
    if !model.matching
      model.new_gesture
      model.matching = true
    else
       model.test_gesture
    end
  end

  #dumps all the gestures to the Gestures/gestures.dat file
  button "save_all_gestures" do
    model.store_all_gestures
  end

  #sends the selected gesture index to the model, then tells the model we want to edit the selected gesture
  button "edit_gesture" do
    model.selected_gesture_index = view_model.selected_gesture_index
    model.edit_gesture
  end

  #sends the selected gesture index to the model, then tells the model we want to delete the selected gesture
  button "delete_gesture" do
    model.selected_gesture_index = view_model.selected_gesture_index
    model.delete_gesture
    update_view
  end

  #brings up the live display window
  button "show_live_display" do
    controller = LiveDisplayController.instance
    @point_source.clear
    controller.point_source = @point_source
    controller.open
  end

  #brings up the point plotter for the current gesture
  button "plot_gesture" do
    plotter = Java::CageUi::GesturePlotter.new
    plotter.gesture = model.current_gesture
    plotter.visible = true
  end

  #runs the script in the current gesture's action
  button "test_script" do
    if $os_type == "OSX"
      begin
        #javax.script.ScriptEngineManager.new.get_engine_by_name("AppleScript").eval(view_model.current_gesture.action)
        `osascript -e '#{view_model.current_gesture.action}'`
      rescue => e
        javax.swing.JOptionPane.showMessageDialog(nil, e.cause.message, "Script error", javax.swing.JOptionPane::WARNING_MESSAGE)
      end
    elsif $os_type == "WIN"
      
    end
  end

  #starts continuous matching
  button "continuous_match" do
    model.continuous_match = view_model.continuous_match
  end

  #deletes gestures when the "delete" or "backspace" keys are pressed
  def gesture_list_key_pressed(evt)
    if [8, 127].include? evt.key_code
      model.selected_gesture_index = view_model.selected_gesture_index
      model.delete_gesture
    end
    update_view
  end

  #closes the program, disconnecting from the watch and storing all the current gestures
  def close
    super
    @point_source.disconnect
    model.store_all_gestures
  end
end
