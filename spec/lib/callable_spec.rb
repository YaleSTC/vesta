# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Callable do
  describe 'class methods defined' do
    class Klass
      include Callable
    end
    it 'defines a class method .make_callable' do
      expect(Klass).to respond_to(:make_callable)
    end
  end

  describe '.make_callable' do
    context 'method defined on class' do
      class Klass
        include Callable

        def initialize(attr:); end

        def foo; end
      end
      it 'defines a method on self to call method on new instance' do
        klass_spy = instance_spy('Klass', foo: true)
        allow(Klass).to receive(:new).with(attr: 'foo').and_return(klass_spy)
        Klass.make_callable(:foo)
        expect(Klass.foo(attr: 'foo')).to eq(true)
      end
    end
    context 'method not defined on class' do
      it 'raises an ArgumentError' do
        expect { Klass.make_callable(:bar) }.to raise_error(ArgumentError)
      end
    end
  end
end
