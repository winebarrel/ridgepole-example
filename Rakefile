require File.expand_path("../rake_helper", __FILE__)

namespace :development do
  task :export, :database, :table do |t, args|
    export(:development, args[:database], args[:table]) do |line|
      puts line.gsub(/write `([^`]+)`/) { "write `#{File.basename($1)}`" }
    end
  end

  task :'dry-run', :database, :table do |t, args|
    apply(:development, args[:database], args[:table], dry_run: true) do |line|
      puts line
    end
  end

  task :apply, :database, :table do |t, args|
    apply(:development, args[:database], args[:table]) do |line|
      puts line
    end
  end
end
