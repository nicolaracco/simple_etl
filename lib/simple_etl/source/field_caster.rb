module SimpleEtl
  module Source
    module FieldCaster
      extend self

      def parse_object o; o; end

      def parse_string o
        o && o.strip
      end

      def parse_boolean o
        if o.nil? || o =~ /^\s*$/
          nil
        else
          if %w(true 1).include? o.strip
            true
          elsif %w(false 0).include? o.strip
            false
          else
            raise(CastError.new "Cannot cast '#{o}' to 'boolean'")
          end
        end
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