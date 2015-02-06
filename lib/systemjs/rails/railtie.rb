require 'active_support/core_ext/class/attribute'
require 'sprockets/railtie'

module Systemjs
  module Rails
    class Railtie < ::Rails::Railtie
      config.system_js = ActiveSupport::OrderedOptions.new

      config.system_js.config_file_path = 'config/systemjs/config.js'
      config.system_js.package_dir = 'vendor/assets/javascripts/jspm_packages'

      initializer :setup_system_js, group: :all do |app|
        config = app.config.system_js

        config.base_path = File.dirname(app.root.join(config.config_file_path))

        if app.assets
          app.assets.append_path(app.root.join(config.package_dir))
          app.assets.register_preprocessor 'application/javascript', Systemjs::Rails::Processor

          # Add path for the SystemJS polyfill
          app.assets.append_path(File.expand_path('../../assets/javascripts', File.dirname(__FILE__)))
        end

        Systemjs::Rails.builder_config = Systemjs::Rails::BuilderConfig.new(config)
      end
    end
  end
end
