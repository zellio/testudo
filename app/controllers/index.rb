module Testudo::Controller::Index
  def self.registered(app)
    app.get '/?' do
      erb :index, locals: {
        desc: 'testudo -- Light read only calibre library'
      }
    end
  end
end
