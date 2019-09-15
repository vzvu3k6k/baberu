# frozen_string_literal: true

require 'baberu/rewriters/numbered_parameter_rewriter'

module Baberu
  module Rewriter
    module_function

    def rewrite_with_line_map(source_buffer, ast)
      rewriter = Baberu::Rewriters::NumberedParameterRewriter.new
      compiled_code = rewriter.rewrite(source_buffer, ast)
      line_map = rewriter.line_map(source_buffer, ast)

      [compiled_code, line_map]
    end
  end
end
