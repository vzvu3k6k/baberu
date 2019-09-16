# frozen_string_literal: true

require 'parser/ruby27'
require 'parser/source/buffer'
require 'baberu/rewriter'

module Baberu
  module Loader
    module_function

    def load(path)
      code = File.read(path)

      ast = Parser::Ruby27.parse(code)
      buffer = Parser::Source::Buffer.new(path)
      buffer.source = code

      compiled_code, line_map = Baberu::Rewriter.rewrite_with_line_map(buffer, ast)

      register_exception_mapping(path, line_map)
      eval compiled_code, nil, path
    end

    def register_exception_mapping(path, line_map)
      Exception.class_variable_set(:@@path, path)
      Exception.class_variable_set(:@@line_map, line_map)

      patch_exception
    end

    def patch_exception
      return if @patched

      Exception.prepend Module.new {
        def backtrace
          locations = backtrace_locations
          return super unless locations

          path = self.class.class_variable_get(:@@path)
          line_map = self.class.class_variable_get(:@@line_map)

          locations.map { |l|
            next l.to_s if l.path != path

            l.to_s.sub(/^([^:]+):(\d+):/) { "#{$1}:#{line_map[$2.to_i]}:" }
          }.join("\n")
        end
      }
      @patched = true
    end
  end
end
