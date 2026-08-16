# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemoActivityList, type: :model do
  subject(:demo_list) { described_class.new(session) }

  let(:session) { {} }

  describe '#names' do
    context 'when the visitor has not been given any suggestions yet' do
      it 'suggests a list of activities' do
        expect(demo_list.names.size).to eq(described_class::SIZE)
      end

      it 'picks them from the pre-seeded activities list' do
        expect(ACTIVITIES_LIST).to include(*demo_list.names)
      end
    end

    context 'when the visitor has already been given suggestions' do
      let!(:first_visit) { described_class.new(session).names }

      it 'suggests the same ones on the next request' do
        expect(demo_list.names).to eq(first_visit)
      end
    end

    context 'when the visitor has dismissed every suggestion' do
      before { session[described_class::KEY] = [] }

      it 'suggests a fresh set' do
        expect(demo_list.names.size).to eq(described_class::SIZE)
      end
    end
  end

  describe '#remove' do
    let!(:suggested_names) { demo_list.names.dup }

    before { demo_list.remove(suggested_names.first) }

    it 'forgets the dismissed suggestion' do
      expect(demo_list.names).not_to include(suggested_names.first)
    end

    it 'keeps the rest' do
      expect(demo_list.names).to match_array(suggested_names.drop(1))
    end

    context 'when it is not one of the suggestions' do
      before { demo_list.remove('Something else entirely') }

      it 'leaves the rest alone' do
        expect(demo_list.names).to match_array(suggested_names.drop(1))
      end
    end
  end

  describe '#clear' do
    before do
      demo_list.names
      demo_list.clear
    end

    it 'forgets the suggestions' do
      expect(session).not_to have_key(described_class::KEY)
    end

    it 'suggests a fresh set when asked again' do
      expect(demo_list.names.size).to eq(described_class::SIZE)
    end
  end
end
