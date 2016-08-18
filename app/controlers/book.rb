module Testudo::Controller::Book
  def self.registered(app)
    app.namespace '/book' do
      get '/?' do
        erb :book, locals: {
          title: 'Library',
          description: 'List of all books in the library',
          books: Testudo::Model::Book.reverse(:id)
        }
      end

      get '/:id' do |id|
        param :id, Integer, required: true

        book = Testudo::Model::Book[id]
        desc = "#{book.title} by #{book.authors.map(&:name).join(', ')}"

        erb :"book/id", locals: {
          title: desc,
          description: desc,
          book: book
        }
      end

      get '/:id/cover' do |id|
        param :id, Integer, required: true

        book = Testudo::Model::Book[id]

        filepath = File.join(settings.library, book.path, 'cover.jpg')

        send_file(filepath, type: 'image/jpeg', filename: 'cover.jpg')
      end

      get '/:id/download/:format' do |id, format|
        param :id, Integer, required: true

        book = Testudo::Model::Book[id]
        format = Testudo::Model::Datum[book: id, format: format.upcase]

        format_str = format.format.downcase

        type = { 'epub' => 'application/epub+zip',
                 'mobi' => 'application/x-mobipocket-ebook' }[format_str]

        filename = "#{format.name}.#{format_str}"

        filepath = File.join(settings.library, book.path, filename)

        send_file(filepath, type: type, filename: filename)
      end
    end
  end
end
