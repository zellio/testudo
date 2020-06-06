# frozen_string_literal: true

require 'sinatra/base'
require 'open-uri'
require 'fileutils'
require 'tmpdir'

module Sinatra
  module TestudoDatabaseCache
    def download(url, path)
      url = "http://#{url}" unless File.exist?(url)
      case io = open(url)
      when StringIO
        File.open(path, 'w') { |fh| fh.write(io) }
      when Tempfile
        io.close
        FileUtils.mv(io.path, path)
      when File
        FileUtils.cp(io.path, path)
      else
        raise "Unhandled type: " + io.class
      end
    end

    def fetch_database(path)
      source_url = File.join(settings.library['path'], 'metadata.db')
      target_path = File.join(path, 'metadata.db')
      download(source_url, target_path)
    end

    def cache_database
      tmpdir = Dir.mktmpdir('testudo-', settings.library['tmpdir'])
      fetch_database(tmpdir)
      at_exit do
        File.unlink(File.join(tmpdir, 'metadata.db'))
        FileUtils.remove_dir(tmpdir)
      end
      tmpdir
    end
  end
end
