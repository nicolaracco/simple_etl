module SimpleEtl
  module Source
    module FixedWidth
      class Context < SimpleEtl::Source::BaseContext
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
    end
  end
end