class ApplicationController < Monkeybars::Controller
  # Add content here that you want to be available to all the controllers
  # in your application

  # utility method for setting up button handlers
  def self.button(name, &blk)
    define_method "#{name}_action_performed" do
      self.instance_eval(&blk)
      self.send(:update_view)
    end
  end
end