# frozen_string_literal: true

get '/?' do
  slim :index, locals: {
    desc: 'testudo -- Light read only calibre library',
    books: Testudo::Model::Book.reverse(:id).limit(4)
  }
end
