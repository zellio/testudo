# frozen_string_literal: true

namespace '/series' do
  get '/?' do
    param :page, Integer, required: false
    param :items, Integer, required: false

    pagy, series = pagy(Testudo::Model::Series.order(:sort))

    slim :series, locals: {
      title: 'Series list',
      description: 'List of all series in the library',
      pagy: pagy,
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

    slim :"series/id", locals: {
      title: desc,
      description: desc,
      series: series,
      pagy: pagy,
      books: books
    }
  end
end
