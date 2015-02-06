require 'active_support/core_ext/class/attribute'
require 'sprockets/railtie'

module Systemjs
  module Rails
    class Railtie < ::Rails::Railtie
      config.system_js = ActiveSupport::OrderedOptions.new

      config.system_js.config_file_path = '/Users/tonymarklove/Web/es6-test/app/assets/javascripts/config.js'
      config.system_js.base_path = '/Users/tonymarklove/Web/es6-test/app/assets/javascripts'

      config.system_js.builder_config = Systemjs::Rails::BuilderConfig.new(config.system_js)

      initializer :setup_system_js, group: :all do |app|
        if app.assets
          app.assets.append_path '/Users/tonymarklove/Web/es6-test/public/jspm_packages'
          app.assets.register_preprocessor 'application/javascript', Systemjs::Rails::Processor

          Systemjs::Rails.builder_config = app.config.system_js.builder_config
        end
      end
    end
  end
end
