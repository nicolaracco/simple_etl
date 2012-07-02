module SimpleEtl
  module Source
    class BaseContext
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
  end
end