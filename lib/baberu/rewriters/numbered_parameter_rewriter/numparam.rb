# frozen_string_literal: true

require 'parser'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
      module Numparam
        refine Parser::AST::Node do
          # @1 => 1
          def number
            children.first
          end

          def denominate
            "_np#{number}"
          end
        end
      end
    end
  end
end
