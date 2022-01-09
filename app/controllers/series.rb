# frozen_string_literal: true

namespace '/series' do
  get '/?' do
    param :page, String, required: false

    series = Testudo::Model::Series.order{sort}
    buckets = generate_buckets(series).keys
    params[:page] = buckets.first unless params[:page]

    pagy, series = pagy_bucket(series, buckets: buckets)

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
