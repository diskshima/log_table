# LogTable

[<img src="https://secure.travis-ci.org/diskshima/log_table.png?branch=master" />](http://travis-ci.org/diskshima/log_table)

The LogTable gem will read your Active Record model and generate a  table to store logs to.
It will additionally create triggers which will do the actual saving into the log table.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'log_table'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install log_table

## Usage

After installing the gem, you will need to run the below two Rake tasks

    $ bundle exec rake db:generate_log_table_migration MODEL=MODEL1,MODEL2,...
    $ bundle exec rake db:generate_log_trigger_migration MODEL=MODEL1,MODEL2,...

The first will generate a migration which will generate the log tables and the second will generate a migration for the triggers.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/diskshima/log_table. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
