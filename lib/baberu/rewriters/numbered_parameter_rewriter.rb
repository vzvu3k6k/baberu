require 'parser'
require 'baberu/rewriters/numbered_parameter_rewriter/numparam'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
      using Numparam

      def on_numblock(node)
        numparams = collect_numparams(node)

        insert_arguments(node, numparams)

        numparams.each do |numparam|
          rewrite_argument(numparam)
        end

        super
      end

      private

      def insert_arguments(numblock, numparams)
        numparams = numparams.uniq(&:number).sort_by(&:number)
        insert_after(numblock.loc.begin, "|#{parameters(numparams).join(', ')}|")
      end

      def parameters(numparams)
        return numparams.map(&:denominate) if numparams.size == 1

        (numparams << nil)
          .each_cons(2)
          .flat_map { |a, b|
            next [a.denominate] if b.nil?

            [
              a.denominate,
              *(b.number - a.number - 1).times.map { '_' }
            ]
          }
      end

      def rewrite_argument(numparam)
        replace(numparam.loc.expression, numparam.denominate)
      end

      def collect_numparams(numblock)
        _collect_numparams(numblock.children[2])
      end

      def _collect_numparams(node, numparams = [])
        return numparams unless node.respond_to?(:children)
        return _collect_numparams(node.children[0]) if node.type == :block || node.type == :numblock
        return numparams.push(node) if node.type == :numparam

        node.children.flat_map { |child| _collect_numparams(child) }
      end
    end
  end
end
