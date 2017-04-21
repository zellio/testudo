require 'sinatra/base'

module Sinatra
  module Drumkit
    def self.registered(app)
      @@app_dir = app.app_dir || File.join(app.root, 'app')

      @@model_dir =
        if app.respond_to?(:model_dir)
          app.model_dir
        else
          File.join(@@app_dir, 'models')
        end

      @@controller_dir =
        if app.respond_to?(:controller_dir)
          app.controller_dir
        else
          File.join(@@app_dir, 'controllers')
        end

      parent_class = Kernel.const_get(app.to_s.split('::').first)

      model_module = Module.new
      def model_module.const_missing(const)
        @searched ||= {}
        raise "Class not found: #{const}" if @searched[const]
        @searched[const] = true
        require File.join(@@model_dir, "#{const.to_s.downcase}.rb")
        klass = const_get(const)
        raise "Class not found: #{const}" unless klass
        klass
      end
      parent_class.const_set(:Model, model_module)

      controller_module = Module.new
      parent_class.const_set(:Controller, controller_module)

      Dir[::File.join(@@controller_dir, '*.rb')].each do |file|
        app.instance_eval(File.read(file), file)
      end
    end
  end
end
