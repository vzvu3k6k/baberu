# frozen_string_literal: true

require 'parser/source/buffer'
require 'parser/source/range'
require 'baberu/source/tree_rewriter'

RSpec.describe Baberu::Source::TreeRewriter do
  def range(begin_pos, end_pos)
    Parser::Source::Range.new(source_buffer, begin_pos, end_pos)
  end

  def map(source_range, output_range)
    Baberu::TreeRewriter::Map.new(source_range, output_range)
  end

  let(:source_buffer) {
    Parser::Source::Buffer.new('(str)').tap do |buf|
      buf.source = source
    end
  }
  let(:rewriter) { described_class.new(source_buffer) }

  describe '#insert_before', :skip do
    let(:source) { 'foo' }

    it 'track changes' do
      rewriter.insert_before(range(0, 0), ':')
      expect(rewriter.line_map).to eq [1]
    end
  end

  describe '#wrap', :skip do
    let(:source) { 'foo' }

    it 'tracks changes' do
      rewriter.wrap(range(0, 3), '"', '"')
      expect(rewriter.line_map).to eq [1]
    end
  end
end
