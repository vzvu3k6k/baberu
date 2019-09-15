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
      compiled_code = rewriter.rewrite(buffer, ast)
      line_map = rewriter.line_map(buffer, ast)
      
      begin
        eval compiled_code, nil, path
      rescue => e
        raise rewrite_exception(e, path, line_map)
      end
    end

    def rewrite_exception(e, path, line_map)
      backtrace =
        e.backtrace.map { |i|
          i.sub(/^([^:]+):(\d+):/) { |m|
            if $1 == path
              "#{$1}:#{line_map[$2.to_i]}:"
            else
              m
            end
          }
        }
      e.tap { |e| e.set_backtrace(backtrace) }
    end
  end
end
