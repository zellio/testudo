# frozen_string_literal: true

get '/?' do
  erb :index, locals: {
    desc: 'testudo -- Light read only calibre library'
  }
end
