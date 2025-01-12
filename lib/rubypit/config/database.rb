# frozen_string_literal: true

require "sequel"
require "yaml"
require "erb"

module RubyPit
  module Config
    module Database
      class << self
        attr_accessor :connection

        def connect!
          return connection if connected?

          config = load_configuration
          self.connection = Sequel.connect(config)
          setup_connection_pool
          connection
        end

        def connected?
          !connection.nil? && !connection.pool.disconnected?
        end

        private

        def load_configuration
          config_file = find_database_config
          yaml = ERB.new(File.read(config_file)).result
          config = YAML.safe_load(yaml)[environment]


          config.transform_keys(&:to_sym)
        end

        def find_database_config
          paths = [
            File.join(Dir.pwd, "config", "database.rb"),
            File.join(Dir.pwd, "database.rb")
          ]

          config_file = paths.find { |path| File.exist?(path) }
          raise "Database configuration file not found! Expected at: #{paths.join(" or ")}" unless config_file

          config_file
        end

        def environment
          ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
        end

        def setup_connection_pool
          connection.pool.max_size = 5 # Adjust pool size as needed
          connection.logger = RubyPit.logger if defined?(RubyPit.logger)
          connection.sql_log_level = :debug
        end
      end
    end
  end
end
