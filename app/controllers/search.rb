# frozen_string_literal: true

namespace '/search' do
  get '/?' do
    param :query, String, required: true
    param :page, Integer, required: false
    param :items, Integer, required: false

    query = params['query']

    book_ids = db[:fts_short_index].select(:book_id).where(Sequel.lit('`fts_short_index` MATCH ?', query))
    pagy, books = pagy(Testudo::Model::Book.where(id: book_ids))

    slim :books, locals: {
      title: 'Search Results',
      description: 'Search Results',
      pagy: pagy,
      books: books
    }
  end
end
