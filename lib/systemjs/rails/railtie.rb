require 'active_support/core_ext/class/attribute'
require 'sprockets/railtie'

module Systemjs
  module Rails
    class Railtie < ::Rails::Railtie
      config.system_js = ActiveSupport::OrderedOptions.new

      config.system_js.config_file_path = 'config/systemjs/config.js'
      config.system_js.package_dir = 'vendor/assets/javascripts/jspm_packages'

      # Add a custom file reloader middleware
      initializer :system_js_reloader do |app|
        app.middleware.use Systemjs::Rails::Reloader
      end

      initializer :system_js_setup, group: :all do |app|
        config = app.config.system_js

        config.base_path = File.dirname(app.root.join(config.config_file_path))

        if app.assets
          app.assets.append_path(app.root.join(config.package_dir))
          app.assets.register_preprocessor 'application/javascript', Systemjs::Rails::Processor

          # Add path for the SystemJS polyfill
          app.assets.append_path(File.expand_path('../../assets/javascripts', File.dirname(__FILE__)))
        end

        # Monitor the config file for changes in development
        setup_config = -> {
          Systemjs::Rails.builder_config = Systemjs::Rails::BuilderConfig.new(config)

          config_file = app.root.join(app.config.system_js.config_file_path)

          if app.config.reload_classes_only_on_change
            Systemjs::Rails::Reloader.on_change([config_file], &setup_config)
          end
        }

        setup_config.call
      end
    end
  end
end
