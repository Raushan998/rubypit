# frozen_string_literal: true

require "sequel"
require "yaml"
require "erb"

RSpec.configure do |config|
  config.before(:each) do
    Rubypit::Config::Database.connection = nil
  end
end

RSpec.describe Rubypit::Config::Database do
  let(:test_config) do
    {
      "development" => {
        "adapter" => "postgres",
        "host" => "localhost",
        "database" => "test_db",
        "username" => "user",
        "password" => "password"
      }
    }
  end

  let(:config_content) do
    <<~YAML
      development:
        adapter: postgres
        host: localhost
        database: test_db
        username: user
        password: password
    YAML
  end

  describe ".connect!" do
    context "when configuration file exists" do
      let(:pool) { double("Pool", disconnected?: false) }
      let(:connection) { double("Connection", pool: pool) }
      let(:expected_config) do
        {
          adapter: "postgres",
          host: "localhost",
          database: "test_db",
          username: "user",
          password: "password"
        }
      end

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(config_content)
        allow(Sequel).to receive(:connect).and_return(connection)
        allow(pool).to receive(:max_size=)
        allow(connection).to receive(:sql_log_level=)
      end

      it "establishes a database connection" do
        expect(Sequel).to receive(:connect).with(hash_including(expected_config))
        described_class.connect!
      end

      it "sets up the connection pool" do
        expect(pool).to receive(:max_size=).with(5)
        expect(connection).to receive(:sql_log_level=).with(:debug)

        described_class.connect!
      end

      it "returns existing connection if already connected" do
        existing_connection = double("Connection", pool: double("Pool", disconnected?: false))
        described_class.connection = existing_connection

        expect(described_class.connect!).to eq(existing_connection)
        expect(Sequel).not_to receive(:connect)
      end
    end
  end

  describe ".connected?" do
    context "when connected" do
      before do
        described_class.connection = double("Connection", pool: double("Pool", disconnected?: false))
      end

      it "returns true" do
        expect(described_class.connected?).to be true
      end
    end

    context "when not connected" do
      before do
        described_class.connection = nil
      end

      it "returns false" do
        expect(described_class.connected?).to be false
      end
    end

    context "when connection is disconnected" do
      before do
        described_class.connection = double("Connection", pool: double("Pool", disconnected?: true))
      end

      it "returns false" do
        expect(described_class.connected?).to be false
      end
    end
  end

  describe "private methods" do
    describe ".environment" do
      after do
        ENV["RACK_ENV"] = nil
        ENV["RAILS_ENV"] = nil
      end

      it "returns RACK_ENV if set" do
        ENV["RACK_ENV"] = "production"
        expect(described_class.send(:environment)).to eq("production")
      end

      it "returns RAILS_ENV if set and RACK_ENV is not set" do
        ENV["RAILS_ENV"] = "staging"
        expect(described_class.send(:environment)).to eq("staging")
      end

      it "returns development by default" do
        expect(described_class.send(:environment)).to eq("development")
      end
    end

    describe ".load_configuration" do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(config_content)
      end

      it "loads and transforms configuration" do
        config = described_class.send(:load_configuration)
        expect(config).to eq({
                               adapter: "postgres",
                               host: "localhost",
                               database: "test_db",
                               username: "user",
                               password: "password"
                             })
      end

      it "processes ERB in the configuration" do
        erb_config = <<~YAML
          development:
            adapter: postgres
            database: <%= 'test_' + 'db' %>
        YAML

        allow(File).to receive(:read).and_return(erb_config)
        config = described_class.send(:load_configuration)
        expect(config[:database]).to eq("test_db")
      end
    end

    describe ".find_database_config" do
      context "when config exists in config/database.rb" do
        before do
          allow(File).to receive(:exist?).with(File.join(Dir.pwd, "config", "database.rb")).and_return(true)
        end

        it "returns the config path" do
          expect(described_class.send(:find_database_config)).to eq(File.join(Dir.pwd, "config", "database.rb"))
        end
      end

      context "when config exists in root database.rb" do
        before do
          allow(File).to receive(:exist?).with(File.join(Dir.pwd, "config", "database.rb")).and_return(false)
          allow(File).to receive(:exist?).with(File.join(Dir.pwd, "database.rb")).and_return(true)
        end

        it "returns the config path" do
          expect(described_class.send(:find_database_config)).to eq(File.join(Dir.pwd, "database.rb"))
        end
      end
    end
  end
end
