# frozen_string_literal: true
require 'sinatra/base'

module Sinatra
  module RemoteUri
    module Helpers
      def path_uri(path = nil, addr = nil, absolute = true, add_script = true)
        if path
          return addr if addr =~ /\A[a-z][a-z0-9\+\.\-]*:/i

          uri = ["http#{'s' if request.secure?}://#{path}"]
          uri << request.script_name.to_s if add_script
          uri << (addr || request.path_info).to_s
          File.join(uri)
        else
          url(addr, absolute, add_script)
        end
      end
    end

    def self.registered(app)
      app.helpers RemoteUri::Helpers
    end
  end
end
