# frozen_string_literal: true

require 'sinatra/base'

module Sinatra
  module TestudoBookHelpers
    def book_cover_uri(book)
      library = { 'remote': false, 'path': '' }
      library.merge!(settings.reponds_to?(:library) ? settings.library : {})

      if library['remote']
        File.join(book.path, 'cover.jpg')
      else
        "/books/#{book.id}/cover"
      end
    end

    def book_download_uri(book, format)
      library = { 'remote': false, 'path': '' }
      library.merge!(settings.reponds_to?(:library) ? settings.library : {})

      if library['remote']
        format_str = format.format.downcase
        filename = "#{format.name}.#{format_str}"
        File.join(book.path, filename)
      else
        "/books/#{book.id}/download/#{format.format.downcase}"
      end
    end
  end

  helpers TestudoBookHelpers
end
