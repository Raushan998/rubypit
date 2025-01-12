# spec/spec_helper.rb
require 'fileutils'
require 'thor'

RSpec.describe Rubypit::CLI do
  describe '#create_project' do
    let(:cli) { described_class.new }
    let(:generator_double) { instance_double(Rubypit::ProjectGenerator) }

    it 'creates a new project using ProjectGenerator' do
      expect(Rubypit::ProjectGenerator).to receive(:new)
        .with('test_project')
        .and_return(generator_double)
      expect(generator_double).to receive(:generate)

      cli.create_project('test_project')
    end
  end
end

RSpec.describe Rubypit::ProjectGenerator do
  let(:project_name) { 'test_project' }
  let(:generator) { described_class.new(project_name) }
  let(:project_path) { File.join(Dir.pwd, project_name) }

  describe '#initialize' do
    it 'sets the project name' do
      expect(generator.name).to eq(project_name)
    end
  end

  describe '#generate' do
    before { generator.generate }
    after { FileUtils.rm_rf(project_path) }

    it 'creates the project directory structure' do
      expect(File.directory?(project_path)).to be true
      expect(File.directory?(File.join(project_path, 'app'))).to be true
      expect(File.directory?(File.join(project_path, 'app', 'models'))).to be true
      expect(File.directory?(File.join(project_path, 'config'))).to be true
    end

    it 'creates the database config file' do
      config_path = File.join(project_path, 'config', 'database.rb')
      expect(File.exist?(config_path)).to be true
      
      content = File.read(config_path)
      expect(content).to include('development:')
      expect(content).to include('test:')
      expect(content).to include('production:')
      expect(content).to include("database: '#{project_name}_development'")
    end

    it 'creates the .gitignore file' do
      gitignore_path = File.join(project_path, '.gitignore')
      expect(File.exist?(gitignore_path)).to be true
      
      content = File.read(gitignore_path)
      expect(content).to include('.env')
      expect(content).to include('.DS_Store')
      expect(content).to include('config/database.yml')
    end

    it 'creates the Gemfile' do
      gemfile_path = File.join(project_path, 'Gemfile')
      expect(File.exist?(gemfile_path)).to be true
      
      content = File.read(gemfile_path)
      expect(content).to include("source 'https://rubygems.org'")
      expect(content).to include("gem 'rubypit'")
      expect(content).to include("gem 'sequel'")
      expect(content).to include("gem 'pg'")
    end
  end

  describe 'private methods' do
    describe '#project_path' do
      it 'returns the full project path' do
        expect(generator.send(:project_path)).to eq(project_path)
      end
    end

    describe '#database_config_template' do
      it 'includes the project name in database names' do
        template = generator.send(:database_config_template)
        expect(template).to include("database: '#{project_name}_development'")
        expect(template).to include("database: '#{project_name}_test'")
      end
    end

    describe '#gitignore_template' do
      it 'includes common ignored files' do
        template = generator.send(:gitignore_template)
        expect(template).to include('.env')
        expect(template).to include('.DS_Store')
        expect(template).to include('config/database.yml')
      end
    end

    describe '#gemfile_template' do
      it 'includes required gems' do
        template = generator.send(:gemfile_template)
        expect(template).to include("gem 'rubypit'")
        expect(template).to include("gem 'sequel'")
        expect(template).to include("gem 'pg'")
      end
    end
  end
end