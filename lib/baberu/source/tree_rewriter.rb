# frozen_string_literal: true

require 'parser'

module Baberu
  module Source
    # TODO: Make sure this works fine
    class TreeRewriter < Parser::Source::TreeRewriter
      def initialize(*)
        @actions = []
        super
      end

      def line_map
        lines = 1.upto(source_buffer.source_lines.size).to_a

        @actions.sort_by(&:range).each do |action|
          original_line = action.range.line

          # OPTIMIZE: use bisect
          index = lines.find_index { |line| line == original_line }
          raise 'index is not found' unless index

          case action.type
          when :insert_before, :insert_after, :replace
            newlines = action.content.count("\n")
            lines[index, 0] = newlines.times.map { index }
          when :remove
            newlines = action.range.source.count("\n")
            lines[index, newlines] = []
          end
        end

        lines
      end

      class Action < Struct.new(:type, :range, :content)
      end

      def replace(range, content)
        @actions << Action.new(:replace, range, content)
      end

      def wrap(range, insert_before, insert_after)
        insert_before(range, insert_before)
        insert_after(range, insert_after)
      end

      def remove(range)
        @actions << Action.new(:remove, range)
      end

      def insert_before(range, content)
        @actions << Action.new(:insert_before, range, content)
      end

      def insert_after(range, content)
        @actions << Action.new(:insert_after, range, content)
      end
    end
  end
end
