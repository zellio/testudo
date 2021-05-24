# frozen_string_literal: true

get '/?' do
  slim :index, locals: {
    desc: 'testudo -- Light read only calibre library',
    books: Testudo::Model::Book.where(
      id: Testudo::Model::Book.select(:id).order { random.function }.limit(12)
    )
  }
end
