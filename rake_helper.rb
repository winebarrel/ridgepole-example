require "yaml"
require "json"
require "tmpdir"
require "fileutils"
require "open3"

PROJECT_DIR = File.expand_path("..", __FILE__)

def database_config
  database_yml = File.expand_path("../database.yml", __FILE__)
  YAML.load_file(database_yml)
end

def ridgepole(config_name, *args)
  unless config = database_config[config_name.to_s]
    raise "`#{config_name}` not found in database.yml"
  end

  config = JSON.dump(config)
  args << "--verbose" if ENV["VERBOSE"]
  args << "--debug" if ENV["DEBUG"]
  args = args.join(" ")

  out = []

 Open3.popen2e("ridgepole -c '#{config}' #{args}") do |stdin, stdout_and_stderr, wait_thr|
    stdin.close

    stdout_and_stderr.each_line do |line|
      out << line
      yield(line) if block_given?
    end
  end

  out.join("\n")
end

def export(environment, database, table, options = {}, &block)
  config_name = [environment, database].join("_")
  args = ["--export"]
  args.concat ["--tables", table] if table
  args << "--ignore-tables '#{options[:ignore_tables].join(",")}'" if options[:ignore_tables]

  Dir.mktmpdir do |dir|
    args.concat ["--output #{dir}/Schemafile", "--split"]
    ridgepole(config_name, *args, &block)
    files = Dir.glob("#{dir}/*").select {|f| not table or f !~ /Schemafile/ }
    database_dir = File.join(PROJECT_DIR, database)
    FileUtils.mkdir_p(database_dir)
    FileUtils.cp_r(files, database_dir)
  end
end

def apply(environment, database, table, options = {}, &block)
  mode = options[:mode] || :apply
  config_name = [environment, database].join("_")
  schema_file = File.join(PROJECT_DIR, database, "Schemafile")
  args = ["--#{mode}", '--file', schema_file]
  args.concat ["--dry-run"] if options[:dry_run]
  args.concat ["--tables", table] if table
  args << "--ignore-tables '#{options[:ignore_tables].join(",")}'" if options[:ignore_tables]
  ridgepole(config_name, *args, &block)
end