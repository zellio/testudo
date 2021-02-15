# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'grape'
require 'api-pagination'
require 'sequel/model'

module Testudo
  class API < Grape::API
    version 'v1', using: :path, vendor: 'testudo'
    format :json
    prefix :api

    class Model
      def self.parse(value)
        class_name = value.split('_').map(&:capitalize).map(&:singularize).join
        Testudo::Model.const_get(class_name)
      end

      def self.parsed?(value)
        value.ancestors.include?(Sequel::Model)
      end
    end

    helpers do
      def filter_objects(obj, params)
        obj = Array(obj)
        if params[:fields]
          obj.map { |o| o.values.slice(*params[:fields].map(&:to_sym)) }
        else
          obj
        end
      end
    end

    params do
      optional :fields, type: Array[String], coerce_with: ->(s) { s.split(/,/) }
    end

    route_param :model, type: Model do
      paginate per_page: 16, max_per_page: 256
      get do
        paginate filter_objects(params[:model].all, params)
      end

      route_param :id, type: Integer do
        get do
          object = params[:model][params[:id]]
          error!('Not Found', 404) unless object
          filter_objects(object, params).first
        end
      end
    end
  end
end
