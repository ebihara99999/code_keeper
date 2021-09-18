# frozen_string_literal: true

RSpec.describe CodeKeeper::Metrics::ClassLength do
  describe "#score" do
    # This context also has a view of testing counting a comment just after class definition precisely.
    context 'A file has one class, in which there is a comment, an empty line' do
      it 'returns a hash with the value 1' do
        expected = {}
        expected.store('SimpleClass', 2)
        cl = CodeKeeper::Metrics::ClassLength.new('spec/fixtures/class_samples/simple_class.rb')
        expect(cl.score).to eq(expected)
      end
    end

    context 'A file has 3 classes, which are a namespace class and a inner class, and a class in a namespace module' do
      it 'returns a hash with scores of 3 classes' do
        expected = {}
        expected.store('RootClass', 4)
        expected.store('RootClass::NameSpaceClass', 3)
        expected.store('RootClass::NameSpaceClass::A', 2)
        expected.store('RootModule', 3)
        expected.store('RootModule::NameSpaceModule', 2)
        expected.store('RootModule::NameSpaceModule::B', 4)
        expected.store('C::D::E', 2)
        cl = CodeKeeper::Metrics::ClassLength.new('spec/fixtures/class_samples/namespace.rb')
        expect(cl.score).to eq(expected)
      end
    end

    context 'A file has a class defined by overlapping constant assignments' do
      it 'returns a hash with a score of the class C' do
        expected_hash = { C: 2 }
        cl = CodeKeeper::Metrics::ClassLength.new('spec/fixtures/class_samples/overlapping_const_assignments.rb')
        expect(cl.score).to eq(expected_hash)
      end
    end

    context 'A file has 2 classes defined by a singleton class' do
      it 'returns a hash with scores of 2 classes' do
        expected_hash = { A: 3, B: 2 }
        cl = CodeKeeper::Metrics::ClassLength.new('spec/fixtures/class_samples/singleton.rb')
        expect(cl.score).to eq(expected_hash)
      end
    end

    context 'A file has 2 classes defined by a Struct object, one of which is a multiple assignment' do
      it 'returns a hash with scores of 2 classes' do
        expected_hash = { A: 2, B: 3 }
        cl = CodeKeeper::Metrics::ClassLength.new('spec/fixtures/class_samples/struct.rb')
        expect(cl.score).to eq(expected_hash)
      end
    end
  end
end
