module SimpleEtl
  module Source
    module FieldCaster
      extend self

      def parse_object o; o; end

      def parse_string o
        o && o.strip
      end

      def parse_boolean o
        !!(o && (o.downcase.strip == 'true' || o.strip == '1'))
      end

      def parse_integer o
        if o.nil? || o =~ /^\s*$/
          nil
        else
          if o =~ /^\s*\d+\s*$/
            o.to_i
          else
            raise(CastError.new "Cannot cast '#{o}' to 'integer'")
          end
        end
      end

      def parse_float o
        if o.nil? || o =~ /^\s*$/
          nil
        else
          if o =~ /^\s*\d*([\.\,]\d+)?\s*$/
            o.gsub(/\,/, '.').to_f
          else
            raise(CastError.new "Cannot cast '#{o}' to 'float'")
          end
        end
      end
    end
  end
end