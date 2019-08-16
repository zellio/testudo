require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/drumkit'
require 'sinatra/namespace'
require 'sinatra/param'
require 'sinatra/sequel_connector'

require 'pagy'
require 'zip'

module Testudo
  class Application < Sinatra::Base
    set :root, -> { File.expand_path(File.join(__dir__, '..', '..')) }
    set :app_dir, -> { File.join(root, 'app') }
    set :config_dir, -> { File.join(root, 'config') }
    set :views, -> { File.join(app_dir, 'views') }
    set :public_folder, -> { File.join(app_dir, 'static') }

    register Sinatra::ConfigFile
    config_file [File.join(config_dir, '*.yml')]

    register Sinatra::SequelConnector
    set :db, "sqlite://#{settings.library}/metadata.db"

    helpers Sinatra::Param

    register Sinatra::Namespace
    register Sinatra::Drumkit

    rhythm namespace: Testudo

    include Pagy::Backend
    helpers Pagy::Frontend

    private

    def pagy_get_vars(collection, vars)
      { count: collection.count,
        page: params["page"],
        items: params["items"] || 24, }
    end
  end
end
