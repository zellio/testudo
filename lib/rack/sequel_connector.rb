# frozen_string_literal: true

require 'sequel'
require 'active_support/core_ext/string/inflections'

module Rack
  # Model container namesapce
  module SequelContainer; end

  AutoloadNameError = Class.new(NameError)

  # Provides naive access to sequel database connections for rack application
  class SequelConnector
    def initialize(app, options = {})
      @app = app
      @uri = options[:uri]
      @load_dir = options[:load_dir]
      @namespace = options[:namespace] || Rack::SequelContainer

      autoload_module = Module.new
      create_model_autoloader(autoload_module, @load_dir)
      @namespace.const_set(:Model, autoload_module)
    end

    def db
      @db ||= Sequel.connect(@uri, encoding: 'utf-8')
    end

    def call(env)
      db.synchronize do
        @app.call(env)
      end
    rescue Sequel::DatabaseConnectionError, Sequel::PoolTimeout
      ::Rack::Response.new('Database Connection Error', 500)
    end

    private

    def create_model_autoloader(model_autoloader, load_dir)
      model_autoloader.define_singleton_method(
        :const_missing,
        lambda { |const|
          @searched ||= {}
          raise AutoloadNameError, "Already failed to find #{const}" if @searched[const]

          @searched[const] = true
          filename = "#{const.to_s.underscore}.rb"
          filepath = ::File.join(load_dir, filename)
          raise AutoloadNameError, "Cannot load: #{filepath}" unless ::File.readable?(filepath)

          require filepath
          const_get(const) || raise(NameError, "Failed to load: #{const}")
        }
      )
    end
  end
end
