class Testudo::Model::Book < Sequel::Model
  one_to_many :books_authors_link, key: :book
  many_to_many :authors,
               left_key: :book,
               right_key: :author,
               join_table: :books_authors_link

  one_to_many :books_series_link, key: :book
  many_to_many :series,
               left_key: :book,
               right_key: :series,
               join_table: :books_series_link

  one_to_many :formats, class: 'Testudo::Model::Datum', key: :book

  one_to_one :comment, key: :book
end
