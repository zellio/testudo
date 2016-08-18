module Testudo
  module Controller; end

  module Controllers
    def self.registered(app)
      Controller.constants.each do |const|
        nodule = Testudo::Controller.const_get const
        app.register(nodule) if nodule.class == Module
      end
    end
  end
end
