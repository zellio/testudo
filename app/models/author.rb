# frozen_string_literal: true

class Testudo::Model::Author < Sequel::Model
  one_to_many :books_authors_link, key: :author
  many_to_many :books,
               left_key: :author,
               right_key: :book,
               join_table: :books_authors_link
end
