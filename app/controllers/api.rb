# frozen_string_literal: true

namespace '/api' do
  namespace '/v0.1.0' do
    respond_to :json, :xml

    get '/:type' do |type|
      param :type, String, required: true

      model = noun_to_model(type)

      halt 404 if model.nil?

      if params['fields']
        respond_with(
          model.all.map(&:values).map { |h| h.slice(*params['fields'].split(',').map(&:to_sym)) }
        )
      else
        respond_with(model.all)
      end
    end

    get '/:type/:id' do |type, id|
      param :type, String, required: true
      param :id, Integer, required: true

      model = noun_to_model(type)
      object = model[id]

      halt 404 if object.nil?

      if params['fields']
        respond_with(
          object.values.slice(*params['fields'].split(',').map(&:to_sym))
        )
      else
        respond_with(object)
      end
    end
  end
end
