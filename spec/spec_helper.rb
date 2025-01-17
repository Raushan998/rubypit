# frozen_string_literal: true

require "rubypit"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    FileUtils.rm_rf(Dir["#{Dir.pwd}/test_*"])
  end

  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Dir.pwd}/test_*"])
  end

  config.before(:each) do
    Rubypit::Config::Database.connection = nil
  end
end
