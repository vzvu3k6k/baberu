# frozen_string_literal: true

require 'parser/ruby27'
require 'baberu/rewriters/numbered_parameter_rewriter'

RSpec.describe Baberu::Rewriters::NumberedParameterRewriter do
  subject do
    buffer = Parser::Source::Buffer.new('(example)')
    buffer.source = source
    ast = Parser::Ruby27.parse(source)
    described_class.new.rewrite(buffer, ast)
  end

  context 'With one arity block' do
    let(:source) { '[1, 2, 3].map { @1 * @1 }' }
    it { expect(subject).to eq '[1, 2, 3].map {|_np1| _np1 * _np1 }' }
  end

  context 'With two arity block' do
    let(:source) { '[].map { @1 * @2 }' }
    it { expect(subject).to eq '[].map {|_np1, _np2| _np1 * _np2 }' }
  end

  context 'With three arity block with skipping' do
    let(:source) { '[].map { @1 * @3 * @5 }' }
    it { expect(subject).to eq '[].map {|_np1, _, _np3, _, _np5| _np1 * _np3 * _np5 }' }
  end

  context 'With nested numbered parameter blocks' do
    let(:source) { '[].map { @1.sum { @1 } }' }
    it { expect(subject).to eq '[].map { |_np1_1| _np1_1.sum { _np2_1 } }'}
  end
end
