# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/drumkit'
require 'sinatra/namespace'
require 'sinatra/param'
require 'sinatra/sequel_connector'
require 'sinatra/remote_uri'
require 'sinatra/respond_with'
require 'sinatra/testudo_book_helpers'
require 'sinatra/testudo_database_cache'

require 'active_support'
require 'active_support/core_ext/string/inflections'

require 'pagy'
require 'zip'

module Testudo
  class NilObject
    def method_missing(*args, &block)
      self
    end

    def nil?
      true
    end
  end

  class Application < Sinatra::Base
    set :root, -> { File.expand_path(File.join(__dir__, '..', '..')) }
    set :app_dir, -> { File.join(root, 'app') }
    set :config_dir, -> { File.join(root, 'config') }
    set :views, -> { File.join(app_dir, 'views') }
    set :public_folder, -> { File.join(app_dir, 'static') }

    register Sinatra::ConfigFile
    config_file [File.join(config_dir, '*.yml')]

    register Sinatra::TestudoDatabaseCache
    tmpdir = cache_database

    register Sinatra::SequelConnector
    set :db, "sqlite://#{tmpdir}/metadata.db"
    Sequel::Model.plugin :json_serializer

    helpers Sinatra::Param
    helpers Sinatra::TestudoBookHelpers

    register Sinatra::RemoteUri
    register Sinatra::Namespace
    register Sinatra::RespondWith
    register Sinatra::Drumkit

    rhythm namespace: Testudo

    include Pagy::Backend
    helpers Pagy::Frontend

    private

    def pagy_get_vars(collection, _vars)
      { count: collection.count,
        page: params['page'],
        items: params['items'] || 24 }
    end

    def noun_to_model(noun)
      module_name = noun.split('_').map(&:capitalize).map(&:singularize).join()
      Testudo::Model.const_get(module_name)
    rescue
      Testudo::NilObject.new
    end
  end
end
