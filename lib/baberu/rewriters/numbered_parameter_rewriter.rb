require 'parser'
require 'baberu/rewriters/numbered_parameter_rewriter/numparam'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
      using Numparam

      def on_numblock(node)
        numparams = collect_numparams(node.children[2])

        insert_block_params(node, numparams)

        numparams.each do |numparam|
          rewrite_params(numparam)
        end

        super
      end

      private

      def insert_block_params(numblock, numparams)
        numparams = numparams.uniq(&:number).sort_by(&:number)
        insert_after(numblock.loc.begin, "|#{block_params(numparams).join(', ')}|")
      end

      def block_params(numparams)
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

      def rewrite_params(numparam)
        replace(numparam.loc.expression, numparam.denominate)
      end

      def collect_numparams(node, numparams = [])
        return numparams unless node.respond_to?(:children)
        return collect_numparams(node.children[0]) if node.type == :block || node.type == :numblock
        return numparams.push(node) if node.type == :numparam

        node.children.flat_map { |child| collect_numparams(child) }
      end
    end
  end
end
