#!/usr/bin/env ruby
#
# railtie.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

require 'log_table'
require 'rails'

module LogTable
  class Railtie < Rails::Railtie
    railtie_name :log_table

    rake_tasks do
      load 'tasks/db/generate_log_table.rake'
      load 'tasks/db/generate_log_trigger_migration.rake'
    end
  end
end
