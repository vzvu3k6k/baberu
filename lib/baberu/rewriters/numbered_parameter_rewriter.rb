require 'parser'

module Baberu
  module Rewriters
    class NumberedParameterRewriter < Parser::TreeRewriter
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
        numparams =
          numparams.uniq { |node| node.children.first }
                   .sort_by { |node| node.children.first }

        insert_after(numblock.loc.begin, "|#{parameters(numparams).join(', ')}|")
      end

      def parameters(numparams)
        if numparams.size == 1
          [denominate(numparams.first)]
        else
          (numparams << nil)
            .each_cons(2)
            .flat_map { |a, b|
              next [denominate(a)] if b.nil?

              [
                denominate(a),
                *(b.children.first - a.children.first - 1).times.map { '_' }
              ]
            }
        end
      end

      def rewrite_argument(numparam)
        replace(numparam.loc.expression, denominate(numparam))
      end

      def denominate(numparam)
        "_np#{numparam.children.first}"
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
