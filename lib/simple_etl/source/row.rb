module SimpleEtl
  module Source
    class Row
      attr_reader :index
      attr_reader :attributes, :errors

      def initialize args = {}
        @index = args[:index]
        @attributes = args[:attributes] || {}
        @errors = []
      end

      def valid?; errors.empty?; end

      def method_missing name, *args, &block
        md = name.to_s.match /^(\w+)(=)?$/
        if md && attributes.has_key?(md[1].to_sym)
          field = md[1].to_sym
          md[2] && (attributes[field] = args.first) || attributes[field]
        else
          super
        end
      end
    end
  end
end