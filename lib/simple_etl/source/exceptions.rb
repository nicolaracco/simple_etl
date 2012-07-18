module SimpleEtl
  module Source
    class Error < Exception; end
    class FieldNotFoundError < Error; end
    class FieldArgumentError < Error; end
    class ParseError < Error
      attr_accessor :row_index, :field_name, :base

      def initialize message = nil, args = {}
        super message
        self.row_index = args[:row_index]
        self.field_name = args[:field_name]
        self.base = args[:base]
      end
    end

    class FieldRequiredError < ParseError; end
    class CastError < ParseError; end
  end
end