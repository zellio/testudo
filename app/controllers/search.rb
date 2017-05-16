namespace '/search' do
  get '/?' do
    param :query, String, required: false

    param :offset, Integer, required: false
    param :limit, Integer, required: false

    query = params["query"]

    offset = params["offset"] || 0
    limit = params["limit"] || 16

    if query.nil? or query.empty?
      erb :search
    else
      book_ids = db[:fts_short_index]
                   .select(:book_id)
                   .where(Sequel.lit("\`fts_short_index\` MATCH '#{query}'"))

      books = Testudo::Model::Book.where(id: book_ids)

      erb :books, locals: {
            title: 'Search Results',
            description: 'Search Results',
            books: books.reverse(:id).limit(limit, offset),
            num_books: books.count,
            offset: offset,
            limit: limit,
          }
    end
  end
end
