module SimpleEtl
  module Source
    class FixedWidth < Base
      class Context < Context
        def field name, start, length, args = {}
          raise(FieldArgumentError.new "#{name}::start required") unless start
          raise(FieldArgumentError.new "#{name}::length required") unless length
          start = Integer(start) rescue
            raise(FieldArgumentError.new "#{name}::start (#{start}) is not integer")
          if length != :eol
            length = Integer(length) rescue
              raise(FieldArgumentError.new "#{name}::length (#{length}) is not integer")
          end
          super name, { :start => start, :length => length }.merge(args)
        end
      end

      def initialize &block
        super Context.new, &block
      end

      def fetch_field_from_row row, field
        length = field[:length]
        length = row.length - field[:start] if length == :eol
        row[field[:start], length]
      end
    end

    formats[:fixed_width] = FixedWidth
  end
end