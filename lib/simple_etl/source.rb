module SimpleEtl
  module Source
    extend self

    @@formats = {}

    def formats; @@formats; end

    def define format, &block
      format_class = formats[format]
      raise "Format #{format} not found" unless format_class
      format_class.new &block
    end

    def load file
      raise "Cannot find file" unless File.exist? file
      module_eval File.read file
    end
  end
end

dir = File.expand_path File.dirname __FILE__
%w(exceptions field_caster row parse_result base_context base).each do |file|
  require File.join dir, "source/#{file}"
end

%w(context parser).each do |file|
  require File.join dir, "source/fixed_width/#{file}"
end