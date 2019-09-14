# frozen_string_literal: true

require 'parser'

module Baberu
  module Source
    class TreeRewriter < Parser::Source::TreeRewriter
      # Based on Parser::Source::TreeRewriter#process
      def sourcemap
        adjustment = 0
        maps = []

        @action_root.ordered_replacements.each do |range, replacement|
          begin_pos = range.begin_pos + adjustment
          end_pos   = begin_pos + replacement.size

          maps << [range, (begin_pos...end_pos)]

          adjustment += replacement.length - range.length
        end

        maps
      end
    end
  end
end
