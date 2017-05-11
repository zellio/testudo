namespace '/books' do
  get '/?' do
    param :offset, Integer, required: false
    param :limit, Integer, required: false

    offset = params["offset"] || 0
    limit = params["limit"] || 24

    erb :books, locals: {
          title: 'Library',
          description: 'List of all books in the library',
          books: Testudo::Model::Book.reverse(:id).limit(limit, offset),
          num_books: Testudo::Model::Book.count,
          offset: offset,
          limit: limit,
        }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    desc = "#{book.title} by #{book.authors.map(&:name).join(', ')}"

    erb :"books/id", locals: {
      title: desc,
      description: desc,
      book: book
    }
  end

  get '/:id/cover' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]

    filepath = File.join(settings.library, book.path, 'cover.jpg')

    etag Digest::SHA1.file(filepath)

    cache_control :public, :must_revalidate, :max_age => 2592000

    send_file(filepath, type: 'image/jpeg', filename: 'cover.jpg')
  end

  get '/:id/download/:format' do |id, format|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    format = Testudo::Model::Datum[book: id, format: format.upcase]

    format_str = format.format.downcase

    type = settings.mimetypes[format_str]

    filename = "#{format.name}.#{format_str}"

    filepath = File.join(settings.library, book.path, filename)

    etag Digest::SHA1.file(filepath)

    cache_control :public, :must_revalidate, :max_age => 2592000

    send_file(filepath, type: type, filename: filename)
  end
end
