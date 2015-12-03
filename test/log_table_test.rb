#
# log_table_test.rb
# Copyright (C) 2015 Daisuke Shimamoto <diskshima@gmail.com>
#
# Distributed under terms of the MIT license.
#

require 'test_helper'
require 'rake'

FILE_DIR = File.dirname(__FILE__)

db_yaml = YAML.load_file(File.expand_path(File.join(FILE_DIR, 'database.yml')))
db_config = db_yaml['test']
ActiveRecord::Base.establish_connection(db_config)

DB_FILE = db_config['database']

Dir.glob(['lib/tasks/db/*.rake', 'test/tasks/*.rake']).each { |r| load r }

spec = Gem::Specification.find_by_name 'hairtrigger'
load "#{spec.gem_dir}/lib/tasks/hair_trigger.rake"

PROJECT_ROOT = File.expand_path(File.join(FILE_DIR, '..'))
TMP_DIR = File.join(PROJECT_ROOT, 'tmp')
TMP_MIGRATIONS_PATH = File.join(TMP_DIR, 'migrations')
MIGRATE_DIR = File.join(PROJECT_ROOT, 'db', 'migrate')

load File.join('test', 'models', 'user.rb')

class LogTableTest < Minitest::Test
  def setup
    FileUtils.mkdir_p(TMP_MIGRATIONS_PATH)
    FileUtils.mkdir_p(MIGRATE_DIR)
    FileUtils.cp_r(File.join(FILE_DIR, 'migrations/'), TMP_MIGRATIONS_PATH)
  end

  def teardown
    rollback_migrations
    FileUtils.rm_rf(TMP_MIGRATIONS_PATH)
    FileUtils.rm_rf(MIGRATE_DIR)
  end

  def migrate_db
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(TMP_MIGRATIONS_PATH)
  end

  def run_generated_migration
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(MIGRATE_DIR)
  end

  def rollback_migrations
    ActiveRecord::Migration.verbose = false
    all_migration_paths = [TMP_MIGRATIONS_PATH, MIGRATE_DIR]
    steps = ActiveRecord::Migrator.migrations(all_migration_paths).count
    ActiveRecord::Migrator.rollback(all_migration_paths, steps)
  end

  def execute_log_trigger_migration
    ENV['MODEL'] = 'User'
    Rake::Task['db:generate_log_trigger_migration'].execute
  end

  def execute_log_table_migration
    ENV['MODEL'] = 'User'
    Rake::Task['db:generate_log_table'].execute
  end

  def last_migration_file
    migration_files = Dir.glob(File.join(MIGRATE_DIR, '*.rb'))
    migration_files.sort.last
  end

  def table_exists?(table_name)
    st = ActiveRecord::Base.connection.raw_connection.prepare(
      'SELECT name FROM sqlite_master WHERE type="table" AND name=?')
    result = st.execute(table_name).next
    st.close

    result.count == 1
  end

  def test_that_it_has_a_version_number
    refute_nil ::LogTable::VERSION
  end

  def test_that_trigger_migration_will_be_generated
    migrate_db
    execute_log_trigger_migration

    assert User.methods.include?(:add_log_trigger)

    mig_file_name = File.basename(last_migration_file)
    assert mig_file_name.include? 'create_triggers_users'
  end

  def test_that_log_table_migration_will_be_generated
    migrate_db
    execute_log_table_migration

    run_generated_migration

    assert table_exists?('users_log')

    has_comment = false
    File.foreach(last_migration_file) do |line|
      has_comment = line.include? 'Generated'
      return if has_comment
    end

    assert has_comment
  end
end
