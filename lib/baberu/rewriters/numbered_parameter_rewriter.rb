# frozen_string_literal: true

require 'parser'
require 'baberu/rewriters/numbered_parameter_rewriter/numparam'
require 'baberu/tree_rewriter'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
      # using Numparam

      def line_map(source_buffer, ast, **policy)
        @source_rewriter = Baberu::TreeRewriter.new(source_buffer, **policy)

        process(ast)

        @source_rewriter.process
        @source_rewriter.line_map
      end

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

      # [@3, @6] => [_, _, @3, _, _, @6]
      def block_params(numparams)
        [nil, *numparams]
          .each_cons(2)
          .flat_map { |a, b|
            blank_nums = (a.nil? ? b.number : b.number - a.number) - 1

            [
              *blank_nums.times.map { '_' },
              b.denominate
            ]
          }
      end

      def rewrite_params(numparam)
        replace(numparam.loc.expression, numparam.denominate)
      end

      # collect numparam nodes in the current scope
      def collect_numparams(node, numparams = [])
        return numparams unless node.respond_to?(:children)
        return collect_numparams(node.children[0]) if node.type == :block || node.type == :numblock
        return numparams.push(node) if node.type == :numparam

        node.children.flat_map { |child| collect_numparams(child) }
      end
    end
  end
end
