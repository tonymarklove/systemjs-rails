require 'digest/sha1'

module Systemjs
  module Rails
    class BuilderConfig

      def initialize(config)
        @config = config
      end

      def module_name(file_path)
        module_name = nil

        paths_regex.each do |map, regex|
          if matches = regex.match(file_path)
            module_name = map.gsub('*', matches[1])
            break;
          end
        end

        module_name
      end

      def system_config
        @system_config ||= begin
          fetcher_script = File.read(File.join(File.dirname(__FILE__), 'javascripts/config_fetcher.js'))

          combined_js = "#{fetcher_script}\n\n#{config_script}"

          context = ExecJS.compile(combined_js)
          config = JSON.parse(context.call('System.fetchConfig'))
          config['paths'] = expand_paths(config['paths'])
          config
        end
      end

      def cache_key
        Digest::SHA1.hexdigest(config_script)
      end

      private

      attr_reader :config

      def expand_paths(paths)
        sorted_paths = Hash[paths.sort_by { |key, value| value.length }.reverse]

        sorted_paths.each_with_object({}) do |(key, value), memo|
          full_path = File.expand_path(value, config.base_path)
          memo[key] = full_path
        end
      end

      def paths_regex
        @system_config_paths ||= begin
          system_config['paths'].each_with_object({}) do |(key, full_path), memo|
            escaped = Regexp.escape(full_path).gsub('\*','(.*)')
            regex = Regexp.new "^#{escaped}$", Regexp::IGNORECASE

            memo[key] = regex
          end
        end
      end

      def config_script
        @config_script ||= File.read(config.config_file_path)
      end

    end
  end
end
