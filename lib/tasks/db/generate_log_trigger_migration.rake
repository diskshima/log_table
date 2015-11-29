require 'log_trigger'

namespace :db do
  desc 'Create a migration to generate log triggers'
  task generate_log_trigger_migration: :environment do
    args = ENV['MODEL']

    models = args.split(',')
    clazzes = models.map { |model_name| Object.const_get(model_name) }

    clazzes.each do |clazz|
      include_log_triggers(clazz)
    end

    Rake::Task['db:generate_trigger_migration'].invoke
  end

  def include_log_triggers(clazz)
    clazz.class_eval do
      include LogTrigger
      add_log_trigger
    end
  end
end
