# frozen_string_literal: true

require 'rack/sequel_connector'

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/namespace'
require 'sinatra/param'
require 'sinatra/remote_uri'
require 'sinatra/respond_with'
require 'sinatra/testudo_book_helpers'
require 'sinatra/testudo_database_cache'

require 'active_support/core_ext/string/inflections'

require 'pagy'
require 'pagy/extras/bootstrap'
require 'zip'
require 'json'
require 'slim'
require 'slim/include'

module Testudo
  class Application < Sinatra::Base
    set :root, -> { File.expand_path(File.join(__dir__, '..', '..')) }
    set :app_dir, -> { File.join(root, 'app') }
    set :config_dir, -> { File.join(root, 'config') }
    set :views, -> { File.join(app_dir, 'views') }
    set :public_folder, -> { File.join(app_dir, 'static') }

    Slim::Include.options[:include_dirs] = [
      views,
      File.join(views, '_partials')
    ]

    register Sinatra::ConfigFile
    config_file [File.join(config_dir, '*.yml')]

    register Sinatra::TestudoDatabaseCache
    tmpdir = cache_database

    use Rack::SequelConnector, {
      uri: "sqlite://#{tmpdir}/metadata.db",
      load_dir: ::File.join(app_dir, 'models'),
      namespace: Testudo
    }

    Sequel::Model.plugin :json_serializer
    Sequel::Model.plugin :xml_serializer

    helpers Sinatra::Param
    helpers Sinatra::TestudoBookHelpers

    register Sinatra::RemoteUri
    register Sinatra::Namespace
    register Sinatra::RespondWith

    include Pagy::Backend
    helpers Pagy::Frontend

    Dir[::File.join(app_dir, 'controllers', '**/*.rb')].each do |file|
      instance_eval(File.read(file), file)
    end

    private

    def pagy_get_vars(collection, _vars)
      { count: collection.count,
        page: params['page'],
        items: params['items'] || 24 }
    end
  end
end
