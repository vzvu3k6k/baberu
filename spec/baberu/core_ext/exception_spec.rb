# frozen_string_literal: true

require 'baberu/core_ext/exception'

RSpec.describe Baberu::CoreExt::Exception do
  let(:example_error) { Class.new(RuntimeError) }

  before do
    Baberu::CoreExt::Exception.apply(example_error)
    example_error.add_backtrace_mapping('example.rb', [nil, 1729])
  end

  subject { eval('raise example_error, "boom"', nil, 'example.rb') }

  it 'modifies a backtrace' do
    expect { subject }.to raise_error(example_error, 'boom') { |error|
      expect(error.backtrace).to include('example.rb:1729:in')
    }
  end
end
