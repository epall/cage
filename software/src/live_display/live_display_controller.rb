class LiveDisplayController < ApplicationController
  set_model 'LiveDisplayModel'
  set_view 'LiveDisplayView'
  set_close_action :close

  def open
    @timer = javax.swing.Timer.new(50) {|evt| update_view }
    @timer.start
    super
  end

  def button_close_action_performed
    self.close
  end

  def close
    super
    @poller.kill
    @timer.stop
  end

  def point_source=(source)
    @poller = Thread.new do
      loop do
        model.point = source.take
      end
    end
  end
end
