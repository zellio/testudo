# frozen_string_literal: true

namespace '/authors' do
  get '/?' do
    param :page, Integer, required: false
    param :items, Integer, required: false

    pagy, authors = pagy(Testudo::Model::Author.order(:sort))

    slim :authors, locals: {
      title: 'Author List',
      description: 'List of all authors in the library',
      pagy: pagy,
      authors: authors
    }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    param :page, Integer, required: false
    param :items, Integer, required: false

    author = Testudo::Model::Author[id]
    halt 404 unless author

    desc = "Books by #{author.name}"

    pagy, books = pagy(author.books_dataset)

    slim :"authors/id", locals: {
      title: desc,
      description: desc,
      author: author,
      pagy: pagy,
      books: books
    }
  end
end
