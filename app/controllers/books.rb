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

    filepath = File.join(settings.library['path'], book.path, 'cover.jpg')
    halt 404 unless File.readable?(filepath)

    etag Digest::SHA1.file(filepath)
    cache_control :public, :must_revalidate, max_age: 2592000

    send_file(filepath, type: 'image/jpeg', filename: 'cover.jpg')
  end

  ['/:id/download/:format', '/:id/download.:format'].each do |path|
    get path do |id, format|
      param :id, Integer, required: true

      book = Testudo::Model::Book[id]
      halt 404 unless book

      format = Testudo::Model::Datum[book: id, format: format.upcase]
      halt 404 unless format

      library = { 'remote' => true, 'path' => 'google.com' }
      library.merge!(settings.respond_to?(:library) ? settings.library : {})

      format_str = format.format.downcase
      filename = "#{format.name}.#{format_str}"

      if library['remote']
        remote_path = File.join(book.path, filename)
        redirect path_uri(library['path'], remote_path, library['secure_remote'], true)
      else
        type = settings.mimetypes[format_str]
        filepath = File.join(settings.library['path'], book.path, filename)

        etag Digest::SHA1.file(filepath)
        cache_control :public, :must_revalidate, max_age: 2592000

        send_file(filepath, type: type, filename: filename)
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

    format_str = 'epub'

    book = Testudo::Model::Book[id]
    halt 404 unless book

    format = Testudo::Model::Datum[book: id, format: format_str.upcase]
    halt 404 unless format

    filename = "#{format.name}.#{format_str}"
    filepath = File.join(settings.library['path'], book.path, filename)
    halt 404 unless File.readable?(filepath)

    epub_archive = Zip::File.open(filepath)
    entry = epub_archive.find { |e| e.name == path }
    halt 404 unless entry

    content = entry.get_input_stream.read

    etag Digest::SHA1.hexdigest(content)
    cache_control :public, :must_revalidate, max_age: 2592000
    content_type settings.mimetypes[File.extname(path)[1..]]

    content
  end
end
