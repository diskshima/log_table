#
# log_table.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

require 'log_table/version'
require 'hairtrigger'

module LogTable
  module LogStatus
    STATUS_COLUMN_NAME = 'log_table_status'
    INSERTED = 'inserted'
    UPDATED = 'updated'
    DELETED = 'deleted'

    def self.sql_func(status, model_name, column_names, table_name, options)
      col_names = column_names

      db_columns = [STATUS_COLUMN_NAME] + col_names.map { |col_name|
          col_name == 'id' ? "#{model_name.underscore}_id" : "#{col_name}"
        }

      db_columns_str = db_columns.join(', ')

      values = (["\"#{status}\""] + col_names.map { |col| "NEW.#{col}" }).join(', ')

      log_table_name = options[:table_name] || "#{table_name}_log"

      sql = "INSERT INTO #{log_table_name}(#{db_columns_str}) VALUES (#{values})"

      sql
    end
  end

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

      trigger.after(:insert) do
        LogStatus.sql_func(LogStatus::INSERTED, name, column_names, table_name,
          options)
      end

      trigger.after(:update) do
        LogStatus.sql_func(LogStatus::UPDATED, name, column_names, table_name,
          options)
      end

      trigger.after(:delete) do
        LogStatus.sql_func(LogStatus::DELETED, name, column_names, table_name,
          options)
      end
    end
  end
end
