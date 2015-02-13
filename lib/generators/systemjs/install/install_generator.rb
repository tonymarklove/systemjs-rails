require 'rails/generators'

module Systemjs
  module Generators

    class InstallGenerator < ::Rails::Generators::Base
      desc "Configures package.json and config.js for SystemJS"

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def create_or_update_package_json
        package_json_path = File.expand_path(File.join(destination_root, 'package.json'))

        if File.exists?(package_json_path)
          current_package_json = JSON.parse(File.read(package_json_path))
          template_package_json = JSON.parse(File.read(File.expand_path(File.join(source_root, 'package.json'))))

          File.write(package_json_path, current_package_json.merge(template_package_json))
        else
          copy_file 'package.json', 'package.json'
        end
      end

      def create_config
        copy_file 'config.js', 'config/systemjs/config.js'
      end

    end

  end
end
