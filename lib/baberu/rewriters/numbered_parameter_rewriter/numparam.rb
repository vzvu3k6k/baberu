# frozen_string_literal: true

require 'parser'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
      module Numparam
        refine Parser::AST::Node do
          # @1 => 1
          def number
            assert_type!(:numparam)
            children.first
          end

          def denominate
            assert_type!(:numparam)
            "_np#{number}"
          end

          def assert_type!(type)
            raise "#{self} is not #{type}." if self.type != type
          end
        end
      end
    end
  end
end
