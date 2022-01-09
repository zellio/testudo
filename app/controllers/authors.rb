# frozen_string_literal: true

namespace '/authors' do # rubocop:disable Metrics/BlockLength
  get '/?' do
    param :page, String, required: false

    authors = Testudo::Model::Author.order{sort}
    buckets = generate_buckets(authors).keys
    params[:page] = buckets.first unless params[:page]

    pagy, authors = pagy_bucket(authors, buckets: buckets)

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
