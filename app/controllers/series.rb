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

    param :offset, Integer, required: false
    param :limit, Integer, required: false

    offset = params["offset"] || 0
    limit = params["limit"] || 24

    series = Testudo::Model::Series[id]
    desc = "Books in #{series.name}"

    erb :"series/id", locals: {
      title: desc,
      description: desc,
      series: series,
      limit: limit,
      offset: offset
    }
  end
end
