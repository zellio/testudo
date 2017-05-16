DROP TABLE IF EXISTS fts_short_index;
CREATE VIRTUAL TABLE
    fts_short_index
USING
    fts5(book_id, title, series, authors);

INSERT INTO
    fts_short_index
SELECT
    id,
    title,
    (SELECT name FROM series WHERE series.id IN (SELECT series FROM books_series_link WHERE book=books.id)) series,
    (SELECT Group_Concat(name) FROM authors WHERE id in (select author from books_authors_link where book = books.id) GROUP BY 1=1) authors
FROM
    books;

DROP TABLE IF EXISTS fts_index;
CREATE VIRTUAL TABLE
    fts_index
USING
    fts5(book_id, title, series, authors, comments);

INSERT INTO
    fts_index
SELECT
    id,
    title,
    (SELECT name FROM series WHERE series.id IN (SELECT series FROM books_series_link WHERE book=books.id)) series,
    (SELECT Group_Concat(name) FROM authors WHERE id in (select author from books_authors_link where book = books.id) GROUP BY 1=1) authors,
    (SELECT text FROM comments WHERE comments.book = books.id) comments
FROM
    books;
