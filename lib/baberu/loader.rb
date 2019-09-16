# frozen_string_literal: true

require 'parser/ruby27'
require 'parser/source/buffer'
require 'baberu/rewriter'
require 'baberu/core_ext/exception'

module Baberu
  module Loader
    module_function

    def load(path)
      code = File.read(path)

      ast = Parser::Ruby27.parse(code)
      buffer = Parser::Source::Buffer.new(path)
      buffer.source = code

      compiled_code, line_map = Baberu::Rewriter.rewrite_with_line_map(buffer, ast)

      CoreExt::Exception.apply
      Exception.set_backtrace_mapping(path, line_map)

      eval compiled_code, nil, path
    end
  end
end
