module Systemjs
  module Rails
    class Processor
      def self.instance
        @instance ||= new
      end

      def self.call(input)
        instance.call(input)
      end

      def initialize(options = {})
        @options = options.dup.freeze

        @cache_key = [
          self.class.name,
          VERSION,
          @options
        ].freeze
      end

      def call(input)
        @environment  = input[:environment]
        @uri          = input[:uri]
        @load_path    = input[:load_path]
        @filename     = input[:filename]
        @name         = input[:name]
        @dirname      = File.dirname(@filename)
        @content_type = input[:content_type]
        @cache        = input[:cache]

        @required         = Set.new(input[:metadata][:required])
        @stubbed          = Set.new(input[:metadata][:stubbed])
        @links            = Set.new(input[:metadata][:links])
        @dependency_paths = Set.new(input[:metadata][:dependency_paths])

        data = process_data(input[:data])

        {
          data: data,
          required: @required,
          stubbed: @stubbed,
          links: @links,
          dependency_paths: @dependency_paths
        }
      end

      def process_data(data)
        build_file = File.expand_path('javascripts/build.js', File.dirname(__FILE__))

        module_name = Systemjs::Rails.builder_config.module_name(@filename)

        # Do nothing if this file is outside the SystemJS configured directories
        return data unless module_name

        output = @cache.fetch(@cache_key + [data]) do
          io = IO.popen(['node', build_file, module_name], {err: [:child, :out]})
          output = io.read
          io.close
          JSON.parse(output)
        end

        @required += output['requires'].map do |file|
          file.gsub(/^file:/, 'file://') + "?type=application/javascript&skip_bundle"
        end

        output['source']
      end

    end
  end
end