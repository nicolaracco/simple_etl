module SimpleEtl
  module Source
    class Base
      attr_reader :errors

      class Context
        attr_reader :fields
        attr_reader :transformations
        attr_reader :generators

        def initialize
          @fields = []
          @transformations = {}
          @generators = []
        end

        def field name, args = {}
          args = {:required => false, :type => :object}.merge args
          unless FieldCaster.respond_to? "parse_#{args[:type]}"
            raise FieldArgumentError.new "#{name}:type (#{args[:type]}) is unknown"
          end
          fields << { :name => name }.merge(args)
        end

        def transform field, &block
          field = field.to_sym
          raise FieldNotFoundError.new(field) unless
            fields.detect { |d| d[:name] == field }
          transformations[field.to_sym] = block
        end

        def generate name, args = {}, &block
          generators << args.merge(:name => name, :block => block)
        end

        def method_missing name, *params, &block
          md = name.to_s.match /^(required_)?(\w+)$/
          type = md && md[2].to_sym
          if type && FieldCaster.respond_to?("parse_#{type}")
            params << {} unless params.last.is_a? Hash
            params.last[:type] = type
            params.last[:required] = true if md[1]
            field *params
          else
            super
          end
        end
      end

      attr_reader :context

      def initialize context, &block
        @errors = []
        @context = context
        context.send :instance_eval, &block if block
      end

      def fetch_field_from_row row, field
        raise 'Abstract Method'
      end

      def parse_row row, args = {}
        row_index = args[:row_index]
        result = args[:result] || ParseResult.new
        row_obj = Row.new
        context.fields.each do |field|
          begin
            row_obj.attributes[field[:name]] = parse_field row, field, row_obj
          rescue SimpleEtl::Source::ParseError
            row_info = row_index && "row #{row_index}" || ''
            result.append_error row_index, "Error parsing #{row_info}, column #{field[:name]}: #{$!.message}", $!
          end
        end
        if result.valid?
          context.generators.each do |field|
            begin
              row_obj.attributes[field[:name]] = generate_field field, row_obj
            rescue SimpleEtl::Source::ParseError
              row_info = row_index && "for row #{row_index}" || ''
              result.append_error row_index, "Error generating #{field[:name]} #{row_info}: #{$!.message}", $!
            end
          end
        end
        result.rows << row_obj
        result
      end

      def parse_rows list, args = {}
        result = args[:result] || ParseResult.new
        list.each_with_index do |row, index|
          parse_row row, :row_index => index, :result => result
        end
        result
      end

      def parse_text text, args = {}
        result = args[:result] || ParseResult.new
        parse_rows text.split("\n"), :result => result
        result
      end

      def parse_file file, args = {}
        result = args[:result] || ParseResult.new
        parse_text File.read(file), :result => result
        result
      end

      def parse_field row, field, row_obj
        value = FieldCaster.send "parse_#{field[:type]}", fetch_field_from_row(row, field)
        raise FieldRequiredError if field[:required] &&
          (value.nil? || value == '')
        if transformer = context.transformations[field[:name]]
          value = row_obj.instance_exec value, &transformer
        end
        value
      end

      def generate_field field, row_obj
        row_obj.instance_exec &field[:block]
      end
    end
  end
end