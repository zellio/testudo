# frozen_string_literal: true

class Testudo::Model::Series < Sequel::Model
  one_to_many :books_series_link, key: :series
  many_to_many :books,
               left_key: :series,
               right_key: :book,
               join_table: :books_series_link,
               order: :series_index
end
