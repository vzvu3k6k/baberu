# frozen_string_literal: true

require 'parser/ruby27'
require 'parser/source/buffer'
require 'baberu/rewriters/numbered_parameter_rewriter'

module Baberu
  module Loader
    module_function

    def load(path)
      code = File.read(path)

      ast = Parser::Ruby27.parse(code)
      buffer = Parser::Source::Buffer.new(path)
      buffer.source = code

      rewriter = Baberu::Rewriters::NumberedParameterRewriter.new
      eval rewriter.rewrite(buffer, ast)
    end
  end
end
