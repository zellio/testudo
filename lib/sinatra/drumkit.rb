require 'sinatra/base'

#
module Sinatra
  #
  module Drumkit
    def rhythm(app_dir: nil, model_dir: nil, controller_dir: nil,
               namespace: Sinatra::Drumkit)

      app_dir ||= File.join(root, 'app')
      model_dir ||= File.join(app_dir, 'models')
      controller_dir ||= File.join(app_dir, 'controllers')

      model_module = Module.new
      model_module.define_singleton_method(
        :const_missing, lambda { |const|
          @searched ||= {}
          raise "Class not found: #{const}" if @searched[const]
          @searched[const] = true
          require File.join(model_dir, "#{const.to_s.downcase}.rb")
          klass = const_get(const)
          raise "Class not found: #{const}" unless klass
          klass
        }
      )
      namespace.const_set(:Model, model_module)

      Dir[::File.join(controller_dir, '*.rb')].each do |file|
        instance_eval(File.read(file), file)
      end
    end
  end

  register Drumkit
end
