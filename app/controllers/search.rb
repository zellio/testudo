# frozen_string_literal: true

namespace '/search' do
  get '/?' do
    param :query, String, required: true
    param :page, Integer, required: false
    param :items, Integer, required: false

    pagy, books = pagy(
      Testudo::Model::Book.where(
        id: Sequel::Model.db[:fts_short_index]
          .select(:book_id)
          .where(Sequel.lit('`fts_short_index` MATCH ?', params['query']))
      )
    )

    slim :books, locals: {
      title: 'Search Results',
      description: 'Search Results',
      pagy: pagy,
      books: books
    }
  end
end
