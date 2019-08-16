namespace '/books' do
  get '/?' do
    param :page, Integer, required: false
    param :items, Integer, required: false

    pagy, books = pagy(Testudo::Model::Book.reverse(:id))

    erb :books, locals: {
      title: 'Library',
      description: 'List of all books in the library',
      pagy: pagy,
      books: books,
    }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    halt 404 unless book

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
    halt 404 unless book

    filepath = File.join(settings.library, book.path, 'cover.jpg')
    halt 404 unless File.readable?(filepath)

    etag Digest::SHA1.file(filepath)
    cache_control :public, :must_revalidate, :max_age => 2592000

    send_file(filepath, type: 'image/jpeg', filename: 'cover.jpg')
  end

  get '/:id/download/:format' do |id, format|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    halt 404 unless book

    format = Testudo::Model::Datum[book: id, format: format.upcase]
    halt 404 unless format

    format_str = format.format.downcase
    type = settings.mimetypes[format_str]
    filename = "#{format.name}.#{format_str}"
    filepath = File.join(settings.library, book.path, filename)

    etag Digest::SHA1.file(filepath)
    cache_control :public, :must_revalidate, :max_age => 2592000

    send_file(filepath, type: type, filename: filename)
  end
end
