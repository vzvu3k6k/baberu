# frozen_string_literal: true

require 'parser/source/buffer'
require 'parser/source/range'
require 'baberu/tree_rewriter'

RSpec.describe Baberu::TreeRewriter do
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

  describe '#insert_before' do
    let(:source) { 'foo' }

    fit 'track changes' do
      rewriter.insert_before(range(0, 0), ':')
      expect(rewriter.sourcemap).to be_nil
    end
  end

  describe '#wrap' do
    let(:source) { 'foo' }

    it 'tracks changes' do
      rewriter.wrap(range(0, 3), '"', '"') # rewrites to "foo"
      expect(rewriter.sourcemap).to be_nil
    end
  end

  # it 'tracks replace' do
  #   source_buffer.source = 'foo'

  #   rewriter.replace(range(0, 3), 'barbaz')
  #   expect(rewriter.process).to eq 'barbaz'

  #   expect(rewriter.sourcemap).to be_nil
  # end
end
