require 'ostruct'

module SimpleEtl
  module Source
    class ParseResult
      attr_reader :rows

      def initialize
        @rows = []
      end

      def valid?
        # return false if at least one row is not valid
        !@rows.detect { |r| !r.valid? }
      end

      def errors
        @rows.inject [] { |memo, row| memo.concat row.errors }
      end

      def append_row attributes
        @rows << Row.new(attributes)
      end

      def append_error row_index, message, e
        @errors << OpenStruct.new({
          :row_index => row_index,
          :message   => message,
          :exception => e
        })
        @rows[row_index].valid = false if @rows
      end
    end
  end
end