module SimpleEtl
  module Source
    class Base
      attr_reader :errors

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
        result = args[:result] || ParseResult.new
        row_obj = Row.new :index => (args[:row_index] || 0)
        result.rows << row_obj
        context.fields.each do |field|
          begin
            row_obj.attributes[field[:name]] = parse_field row, field, row_obj
          rescue SimpleEtl::Source::ParseError
            $!.row_index = row_obj.index
            $!.field_name = field[:name]
            row_obj.errors << $!
          end
        end
        if row_obj.valid?
          context.generators.each do |field|
            begin
              row_obj.attributes[field[:name]] = generate_field field, row_obj
            rescue SimpleEtl::Source::ParseError
              $!.row_index = row_obj.index
              row_obj.errors << $!
            end
          end
        end
        result
      end

      def read_rows src, args
        raise 'Abstract Method'
      end

      def parse src, args = {}
        result = args[:result] || ParseResult.new
        lines = read_rows src, args
        lines.each_with_index do |row, index|
          if index >= context.row_count_to_skip
            parse_row row, :row_index => index, :result => result
          end
        end
        result
      end

      def parse_field row, field, row_obj
        value = FieldCaster.send "parse_#{field[:type]}", fetch_field_from_row(row, field)
        if field[:required] && (value.nil? || value.to_s.empty?)
          raise FieldRequiredError.new "Field is blank"
        end
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