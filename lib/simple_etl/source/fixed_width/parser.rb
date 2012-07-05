module SimpleEtl
  module Source
    module FixedWidth
      class Parser < SimpleEtl::Source::Base
        def initialize &block
          super Context.new, &block
        end

        def fetch_field_from_row row, field
          length = field[:length]
          length = row.length - field[:start] if length == :eol
          row[field[:start], length]
        end

        def read_rows src, args
          (args[:type] == :inline && src.lines || File.readlines(src)).map &:chomp
        end
      end
    end

    formats[:fixed_width] = FixedWidth::Parser
  end
end