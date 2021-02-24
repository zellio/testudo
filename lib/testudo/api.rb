# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'api-pagination'
require 'grape'
require 'sequel/model'

require 'yaml'

module ApiPagination
  # Monkey patch ApiPagination to work with sequel and pagy
  class << self
    def pagy_from(collection, options)
      count = options[:count] || collection.count
      Pagy.new(count: count, items: options[:per_page], page: options[:page])
    end
  end
end

module Testudo
  class API < Grape::API
    version 'v1', using: :path, vendor: 'testudo'
    prefix :api

    content_type :xml, 'application/xml'
    content_type :json, 'application/json'
    content_type :txt, 'text/plain'
    content_type :yaml, 'application/x-yaml'
    formatter :yaml, lambda { |object, _env|
      (object.is_a?(Sequel::Dataset) && object.all || object).to_yaml
    }

    default_format :json

    class ModelType
      def self.parse(value)
        class_name = value.classify
        Testudo::Model.const_get(class_name)
      end

      def self.parsed?(value)
        value.ancestors.include?(Sequel::Model)
      end
    end

    params do
      optional :fields, type: Array[Symbol], coerce_with: lambda { |string|
        string.split(/,/).map(&:to_sym)
      }
    end

    route_param :model, type: ModelType do
      helpers do
        def model
          params[:model]
        end

        def model_select
          dataset = model.dataset
          dataset = dataset.select(*params[:fields]) if params[:fields]
          dataset = dataset.where(id: params[:id]) if params[:id]
          dataset
        end
      end

      paginate per_page: 16, max_per_page: 256

      get do
        paginate present model_select
      end

      route_param :id, type: Integer do
        get do
          present model_select.first
        end
      end
    end
  end
end
