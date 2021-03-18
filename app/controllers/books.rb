# frozen_string_literal: true

namespace '/books' do
  get '/?' do
    param :page, Integer, required: false
    param :items, Integer, required: false

    pagy, books = pagy(Testudo::Model::Book.reverse(:id))

    slim :books, locals: {
      title: 'Library',
      description: 'List of all books in the library',
      pagy: pagy,
      books: books
    }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    halt 404 unless book

    desc = "#{book.title} by #{book.authors.map(&:name).join(', ')}"

    slim :"books/id", locals: {
      title: desc,
      description: desc,
      book: book,
      authors: book.authors,
      formats: book.formats
    }
  end

  get '/:id/cover' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    halt 404 unless book

    library = settings.library || {}
    filepath = File.join(library['path'], book.path, 'cover.jpg')

    if library["remote"]
      redirect "http#{'s' if library['secure_remote']}://#{filepath}"
    else
      halt 404 unless File.readable?(filepath)

      etag Digest::SHA1.file(filepath)
      cache_control :public, :must_revalidate, max_age: 2_592_000
      send_file(filepath, type: 'image/jpeg', filename: "#{book.title} - Cover.jpg")
    end
  end

  ['/:id/download/:format', '/:id/download.:format'].each do |path|
    get path do |id, format|
      param :id, Integer, required: true

      book = Testudo::Model::Book[id]
      halt 404 unless book

      format = Testudo::Model::Datum[book: id, format: format.upcase]
      halt 404 unless format

      library = settings.library || {}
      format_string = format.format.downcase
      filepath = File.join(library["path"], book.path, "#{format.name}.#{format_string}")

      if library['remote']
        redirect "http#{'s' if library['secure_remote']}://#{filepath}"
      else
        halt 404 unless File.readable?(filepath)

        etag Digest::SHA1.file(filepath)
        cache_control :public, :must_revalidate, max_age: 2_592_000

        type = settings.mimetypes[format_string] || 'application/octet-stream'
        send_file(filepath, type: type, filename: filepath)
      end
    end
  end

  get '/:id/read' do |id|
    param :id, Integer, required: true

    book = Testudo::Model::Book[id]
    halt 404 unless book

    format = Testudo::Model::Datum[book: id, format: 'EPUB']
    halt 404 unless format

    desc = "Read #{book.title} by #{book.authors.map(&:name).join(', ')}"

    slim :"books/id/read", locals: {
      title: desc,
      description: desc,
      book: book,
      format: format
    }
  end

  get '/:id/read/*' do |id, path|
    param :id, Integer, required: true

    format_string = 'epub'

    book = Testudo::Model::Book[id]
    halt 404 unless book

    format = Testudo::Model::Datum[book: id, format: format_string.upcase]
    halt 404 unless format

    filename = "#{format.name}.#{format_string}"
    filepath = File.join(settings.library['path'], book.path, filename)
    halt 404 unless File.readable?(filepath)

    epub_archive = Zip::File.open(filepath)
    entry = epub_archive.find { |e| e.name == path }
    halt 404 unless entry

    content = entry.get_input_stream.read

    etag Digest::SHA1.hexdigest(content)
    cache_control :public, :must_revalidate, max_age: 2_592_000
    content_type settings.mimetypes[File.extname(path)[1..]]

    content
  end
end
