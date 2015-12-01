#
# log_table.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

require 'log_table/version'
require 'hairtrigger'

module LogTable
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    ##
    # add_log_trigger will add hairtrigger triggers to the model.
    # It will generate triggers for :insert and :update.
    #
    # Options:
    #
    # - :table_name - Specify table name of the log table.
    #
    def add_log_trigger(options = {})
      col_names = column_names

      db_columns = col_names.map { |col_name|
        col_name == 'id' ? "#{name.underscore}_id" : "#{col_name}"
      }.join(', ')

      values = col_names.map { |col| "NEW.#{col}" }.join(', ')

      log_table_name = options[:table_name] || "#{table_name}_log"

      insert_sql = "INSERT INTO #{log_table_name}(#{db_columns}) VALUES (#{values})"

      trigger.after(:insert) do
        insert_sql
      end

      trigger.after(:update) do
        insert_sql
      end
    end
  end
end
