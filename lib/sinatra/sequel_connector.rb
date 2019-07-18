require 'sinatra/base'
require 'sequel'

module Sinatra
  module SequelConnector
    module Helpers
      def db
        settings.db
      end
    end

    def db=(url)
      @db = nil
      set :database_url, url
      db
    end

    def db
      @db ||= Sequel.connect(database_url, encoding: 'utf-8')
    end

    def self.registered(app)
      app.helpers SequelConnector::Helpers
    end
  end
end
