require 'ostruct'
require 'erb'
require 'log_table'

namespace :db do
  desc 'Create a database migration for log tables'
  task generate_log_table: :environment do
    args = ENV['MODEL']

    unless args
      $stderr.puts 'Please specify at the model with MODEL=CamelCaseModelName'
      next
    end

    models = args.split(',')
    clazzes = models.map { |model_name| Object.const_get(model_name) }

    if clazzes.any? { |clazz| !(clazz < ActiveRecord::Base) }
      $stderr.puts 'The models must be an ActiveRecord model.'
      next
    end

    migration_with_action = 'create_log_tables'
    file_name = ActiveRecord::Migration.next_migration_number(0) + '_' + migration_with_action + '.rb'

    ns = OpenStruct.new
    ns.tables = []
    ns.migration_class_name = migration_with_action.camelize

    clazzes.each do |clazz|
      tables = ns.tables
      table = OpenStruct.new
      table.model_id_col_name = "#{clazz.name.underscore}_id"

      cols = [OpenStruct.new(name: LogTable::LogStatus::STATUS_COLUMN_NAME,
        type: :string)]

      cols += clazz.columns.map do |col|
          if col.name == 'id'
            OpenStruct.new(name: table.model_id_col_name, type: :integer)
          else
            col
          end
        end

      table.attributes = cols

      table.name = "#{clazz.table_name}_log"
      tables << table
    end

    file_path = File.join('db', 'migrate', file_name)
    template_file_path = File.join(File.dirname(__FILE__), 'templates',
      'create_log_table.erb')
    template_file = File.read(template_file_path)

    File.open(file_path, 'w') do |f|
      erb_binding = ns.instance_eval { binding }
      f.write ERB.new(template_file, nil, '-').result(erb_binding)
    end
    puts "Written to #{file_path}"
  end
end
