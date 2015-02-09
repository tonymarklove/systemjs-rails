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
        module_name = Systemjs::Rails.builder_config.module_name(@filename)

        # Do nothing if this file is outside the SystemJS configured directories
        return data unless module_name

        combined_js = "#{config_script}\n\n#{build_script}"

        output = @cache.fetch(@cache_key + [data]) do
          tmpfile = write_to_tempfile(combined_js)
          begin
            io = IO.popen(['node', tmpfile.path, module_name], {err: [:child, :out]})
            output = io.read
            io.close
            JSON.parse(output)
          ensure
            File.unlink(tmpfile)
          end
        end

        @required << polyfill_file_path + "?type=application/javascript&skip_bundle"
        @required += output['requires'].map do |file|
          file.gsub(/^file:/, 'file://') + "?type=application/javascript&skip_bundle"
        end

        output['source']
      end

      private

      def config_script
        "var opts = {
          config: #{Systemjs::Rails.builder_config.system_config.to_json}
        };"
      end

      def build_script
        @build_file ||= File.read(build_file)
      end

      def build_file
        File.expand_path('javascripts/build.js', File.dirname(__FILE__))
      end

      def polyfill_file_path
        'file://' + File.expand_path('../../assets/javascripts/systemjs-polyfill.js', File.dirname(__FILE__))
      end

      def create_tempfile
        mode = File::WRONLY | File::CREAT | File::EXCL
        File.open(temp_file_path, mode, 0600)
      end

      def write_to_tempfile(contents)
        tmpfile = create_tempfile
        tmpfile.write(contents)
        tmpfile.close
        tmpfile
      end

      def temp_file_path
        File.expand_path("../../../tmp/#{SecureRandom.urlsafe_base64}", File.dirname(__FILE__))
      end

    end
  end
end
