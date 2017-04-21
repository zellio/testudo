require 'sinatra/base'

module Sinatra
  module Drumkit
    def self.registered(app)
      @@app_dir = app.app_dir || File.join(app.root, 'app')
      parent_class = Kernel.const_get(app.to_s.split('::').first)

      model_module = Module.new
      def model_module.const_missing(const)
        @searched ||= {}
        raise "Class not found: #{const}" if @searched[const]
        @searched[const] = true
        require File.join(@@app_dir, 'models', "#{const.to_s.downcase}.rb")
        klass = const_get(const)
        raise "Class not found: #{const}" unless klass
        klass
      end
      parent_class.const_set(:Model, model_module)

      controller_module = Module.new
      parent_class.const_set(:Controller, controller_module)

      Dir[::File.join(@@app_dir, 'controllers', '*.rb')].each do |file|
        require file
      end

      controller_module.constants.each do |const|
        nodule = controller_module.const_get const
        app.register(nodule) if nodule.class == Module
      end
    end
  end
end
