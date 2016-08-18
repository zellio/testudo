module Testudo::Controller::Author
  def self.registered(app)
    app.namespace '/author' do
      get '/?' do
        erb :author, locals: {
          title: 'Author List',
          description: 'List of all authors in the library',
          authors: Testudo::Model::Author.order(:sort)
        }
      end

      get '/:id' do |id|
        param :id, Integer, required: true

        author = Testudo::Model::Author[id]
        desc = "Books by #{author.name}"

        erb :"author/id", locals: {
          title: desc,
          description: desc,
          author: author
        }
      end
    end
  end
end
