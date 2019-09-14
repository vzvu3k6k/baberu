# frozen_string_literal: true

require 'parser/ruby27'
require 'baberu/rewriters/numbered_parameter_rewriter'

RSpec.describe Baberu::Rewriters::NumberedParameterRewriter do
  shared_examples 'rewrite' do
    specify 'source is rewritten as expected' do
      buffer = Parser::Source::Buffer.new('(example)')
      buffer.source = source
      ast = Parser::Ruby27.parse(source)
      actual_output = described_class.new.rewrite(buffer, ast)

      expect(actual_output).to eq expected_output
    end

    specify 'source and expected_output have the same result' do
      expect(eval(source)).to eq eval(expected_output)
    end
  end

  context 'With one arity block' do
    let(:source) { '[1, 2, 3].map { @1 * @1 }' }
    let(:expected_output) { '[1, 2, 3].map {|_np1| _np1 * _np1 }' }
    include_examples 'rewrite'
  end

  context 'With a numbered param in a receiver called with a block' do
    let(:source) { '[1].map { @1.tap { break @1 + 1 } }' }
    let(:expected_output) { '[1].map {|_np1| _np1.tap {|_np1| break _np1 + 1 } }' }
    include_examples 'rewrite'
  end

  context 'With two arity block' do
    let(:source) { '[[1, 2]].map { @1 * @2 }' }
    let(:expected_output) { '[[1, 2]].map {|_np1, _np2| _np1 * _np2 }' }
    include_examples 'rewrite'
  end

  context 'Without 1st numbered param' do
    let(:source) { '[[1, 2]].map { @2 }' }
    let(:expected_output) { '[[1, 2]].map {|_, _np2| _np2 }' }
    include_examples 'rewrite'
  end

  context 'With three arity block with skipping' do
    let(:source) { '[[1, 2, 3, 4, 5]].map { @1 * @3 * @5 }' }
    let(:expected_output) { '[[1, 2, 3, 4, 5]].map {|_np1, _, _np3, _, _np5| _np1 * _np3 * _np5 }' }
    include_examples 'rewrite'
  end

  context 'With nested numbered parameter blocks' do
    let(:source) { '[[1, 2]].map { [@2 + @1].map { @1 } }' }
    let(:expected_output) { '[[1, 2]].map {|_np1, _np2| [_np2 + _np1].map {|_np1| _np1 } }' }
    include_examples 'rewrite'
  end
end
