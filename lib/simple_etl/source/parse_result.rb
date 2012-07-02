require 'ostruct'

module SimpleEtl
  module Source
    class ParseResult
      attr_reader :errors, :rows

      def initialize
        @errors = []
        @rows = []
      end

      def valid?; @errors.empty?; end

      def append_row attributes
        @rows << Row.new(attributes)
      end

      def append_error row_index, message, e
        @errors << OpenStruct.new({
          :row_index => row_index,
          :message   => message,
          :exception => e
        })
      end
    end
  end
end