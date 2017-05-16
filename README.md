# Testudo

A small, opinionated web view for your [calibre](https://calibre-ebook.com/)
library.

Testudo is designed to serve your ebooks in an easy to manage fashion for quick
access and reference. That's it. If you want access controls, put it behind a
proxy. If you want faster downloads, put it behind a CDN. If you want to read
your ebooks, use calibre.

If you would like to display and access your ebooks with a very small number of
dependencies, use Testudo.

## Installation

Edit the `config/database.yml` file to specify the directory your calibre
database is in and update the `config/library.yml` file to specify where your
calibre library is located. Then just fire it up with your favourite rack
server and enjoy.

```ruby
bundle install
bundle exec rackup
```

### Search

If you'd like search to work you'll need to run
the [search.sql](db/search.sql) script against your database to generate the
search indices. This shouldn't affect the ability of the database to function
for calibre but you will need to re-run the script every time you add new
content.

## Usage

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/testudo. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Copyright

The MIT License (MIT)
Copyright (C) 2016 Zachary Elliott <contact@zell.io>
