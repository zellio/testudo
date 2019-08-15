namespace '/series' do
  get '/?' do
    series = Testudo::Model::Series.order(:sort)

    erb :series, locals: {
          title: 'Series list',
          description: 'List of all series in the library',
          series: series
        }
  end

  get '/:id' do |id|
    param :id, Integer, required: true

    param :page, Integer, required: false
    param :items, Integer, required: false

    series = Testudo::Model::Series[id]

    halt 404 unless series

    desc = "Books in #{series.name}"

    pagy, books = pagy(series.books_dataset)

    erb :"series/id", locals: {
      title: desc,
      description: desc,
      series: series,
      pagy: pagy,
      books: books
    }
  end
end
