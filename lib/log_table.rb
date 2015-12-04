#
# log_table.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

require 'log_table/version'
require 'hairtrigger'
require 'log_table/railtie' if defined?(Rails::Railtie)

module LogTable
  STATUS_COLUMN_NAME = 'log_table_status'

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    INSERTED = 'inserted'
    UPDATED = 'updated'
    DELETED = 'deleted'

    def sql_func(status, options)
      col_names = column_names    # Avoid any unnecessary round trips to the database

      db_columns = [STATUS_COLUMN_NAME] + col_names.map { |col_name|
          col_name == 'id' ? "#{model_name.to_s.underscore}_id" : "#{col_name}"
        }

      db_columns_str = db_columns.join(', ')

      values = ["\"#{status}\""]

      col_prefix = status == DELETED ? 'OLD' : 'NEW'

      values += col_names.map { |col| "#{col_prefix}.#{col}" }

      values_str = values.join(', ')

      log_table_name = options[:table_name] || "#{table_name}_log"

      sql = "INSERT INTO #{log_table_name}(#{db_columns_str}) VALUES (#{values_str})"

      sql
    end

    ##
    # add_log_trigger will add hairtrigger triggers to the model.
    # It will generate triggers for :insert and :update.
    #
    # Options:
    #
    # - :table_name - Specify table name of the log table.
    #
    def add_log_trigger(options = {})
      trigger.after(:insert) do
        sql_func(INSERTED, options)
      end

      trigger.after(:update) do
        sql_func(UPDATED, options)
      end

      trigger.after(:delete) do
        sql_func(DELETED, options)
      end
    end
  end
end
