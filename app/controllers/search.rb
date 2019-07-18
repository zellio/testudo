namespace '/search' do
  get '/?' do
    param :query, String, required: false

    param :page, Integer, required: false
    param :items, Integer, required: false

    query = params["query"]

    if query.nil? or query.empty?
      erb :search
    else
      book_ids = db[:fts_short_index]
                   .select(:book_id)
                   .where(Sequel.lit("\`fts_short_index\` MATCH '#{query}'"))

      pagy, books = pagy(Testudo::Model::Book.where(id: book_ids))

      erb :books, locals: {
            title: 'Search Results',
            description: 'Search Results',
            pagy: pagy,
            books: books,
          }
    end
  end
end
