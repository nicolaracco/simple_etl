module SimpleEtl
  module Source
    class Error < Exception; end
    class ParseError < Error; end

    class FieldNotFoundError < Error; end
    class FieldArgumentError < ParseError; end
    class FieldRequiredError < ParseError; end
    class CastError < ParseError; end
  end
end