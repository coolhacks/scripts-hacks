require 'yaml'
require 'erb'

module FuckingShellScripts
  class Configuration
    MissingServerType = Class.new(StandardError)
    MissingServerConfiguration = Class.new(StandardError)
    MissingCloudConfiguration = Class.new(StandardError)

    attr_reader :options

    def initialize(command_line_options = {})
      @command_line_options = command_line_options

      read_and_parse_server_options

      raise MissingServerType, "Please specify a type of server you want to create using the --type option" unless options[:type]
      raise MissingCloudConfiguration, "Please specify settings for your provider per http://fog.io/about/provider_documentation.html" unless options[:cloud]
    end

    private

    def default_options
      begin
        YAML.load(ERB.new(File.read('servers/defaults.yml')).result)
      rescue Errno::ENOENT
        {}
      end
    end

    def server_options
      begin
        YAML.load(ERB.new(File.read(server_file)).result)
      rescue Errno::ENOENT
        raise MissingServerConfiguration, "Please create a configuration file './servers/#{type}.yml'"
      end
    end

    def server_file
      "servers/#{type}.yml"
    end

    def read_and_parse_server_options
      options_string_hash = default_options.merge(server_options).merge(@command_line_options)
      @options = options_string_hash.symbolize_keys_deep!
    end

    def type
      @command_line_options[:type]
    end

  end
end
