# frozen_string_literal: true

get '/?' do
  pagy, books = pagy(Testudo::Model::Book.reverse(:id).limit(4))

  erb :index, locals: {
    desc: 'testudo -- Light read only calibre library',
    pagy: pagy,
    books: books
  }
end
