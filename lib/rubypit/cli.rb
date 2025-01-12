require 'thor'
require 'fileutils'

module Rubypit
  class CLI < Thor
    desc "create_project NAME", "Create a new RubyPit project"
    def create_project(name)
      generator = ProjectGenerator.new(name)
      generator.generate
    end
  end

  class ProjectGenerator
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def generate
      create_project_directory
      create_config_directory
      create_database_config
      create_gitignore
      create_gemfile
    end

    private

    def create_project_directory
      FileUtils.mkdir_p(project_path)
      FileUtils.mkdir_p(File.join(project_path, 'app'))
      FileUtils.mkdir_p(File.join(project_path, 'app', 'models'))
    end

    def create_config_directory
      FileUtils.mkdir_p(File.join(project_path, 'config'))
    end

    def create_database_config
      File.open(File.join(project_path, 'config', 'database.rb'), 'w') do |file|
        file.write(database_config_template)
      end
    end

    def create_gitignore
      File.open(File.join(project_path, '.gitignore'), 'w') do |file|
        file.write(gitignore_template)
      end
    end

    def create_gemfile
      File.open(File.join(project_path, 'Gemfile'), 'w') do |file|
        file.write(gemfile_template)
      end
    end

    def project_path
      File.join(Dir.pwd, name)
    end

    def database_config_template
      <<~RUBY
        {
          development: {
            adapter: 'postgres',
            host: 'localhost',
            database: '#{name}_development',
            username: 'user',
            password: 'password',
            port: 5432
          },
          
          test: {
            adapter: 'postgres',
            host: 'localhost',
            database: '#{name}_test',
            username: 'user',
            password: 'password',
            port: 5432
          },
          
          production: {
            adapter: 'postgres',
            host: ENV['DB_HOST'],
            database: ENV['DB_NAME'],
            username: ENV['DB_USER'],
            password: ENV['DB_PASSWORD'],
            port: ENV['DB_PORT']
          }
        }
      RUBY
    end

    def gitignore_template
      <<~TEXT
        .env
        .DS_Store
        /log/*
        !/log/.keep
        /tmp/*
        !/tmp/.keep
        config/database.yml
      TEXT
    end

    def gemfile_template
      <<~RUBY
        source 'https://rubygems.org'

        gem 'rubypit'
        gem 'sequel'
        gem 'pg'
      RUBY
    end
  end
end