namespace '/authors' do
  get '/?' do
    erb :authors, locals: {
          title: 'Author List',
          description: 'List of all authors in the library',
          authors: Testudo::Model::Author.order(:sort)
        }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    author = Testudo::Model::Author[id]
    desc = "Books by #{author.name}"

    erb :"authors/id", locals: {
      title: desc,
      description: desc,
      author: author
    }
  end
end
