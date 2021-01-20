# frozen_string_literal: true

namespace '/api' do
  namespace '/v0.1.0' do
    get '/:type', provides: [:json] do |type|
      param :type, String, required: true

      model = noun_to_model(type)

      halt 404 if model.nil?

      respond_with(model.all)
    end

    get '/:type/:id', provides: [:json] do |type, id|
      param :type, String, required: true
      param :id, Integer, required: true

      model = noun_to_model(type)
      object = model[id]

      halt 404 if object.nil?

      respond_with(object)
    end
  end
end
