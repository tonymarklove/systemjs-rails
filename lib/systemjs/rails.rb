module Systemjs
  module Rails

    class << self
      attr_accessor :builder_config
    end

  end
end

require "systemjs/rails/version"
require "systemjs/rails/builder_config"
require "systemjs/rails/railtie"
require "systemjs/rails/system_js_processor"
