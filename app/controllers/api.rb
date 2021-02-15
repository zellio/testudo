# frozen_string_literal: true

namespace '/api' do
  namespace '/v0.1.0' do
    respond_to :json, :xml

    get '/:type' do |type|
      redirect "/api/v1/#{type}", 301
    end

    get '/:type/:id' do |type, id|
      redirect "/api/v1/#{type}/#{id}", 301
    end
  end
end
