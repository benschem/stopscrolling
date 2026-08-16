# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemoActivityList, type: :model do
  subject(:demo_list) { described_class.new(session) }

  let(:session) { {} }

  describe '#names' do
    context 'when the visitor has not been given any suggestions yet' do
      it 'suggests five activities' do
        expect(demo_list.names.size).to eq(5)
      end

      it 'picks them from the pre-seeded activities list' do
        expect(ACTIVITIES_LIST).to include(*demo_list.names)
      end
    end

    context 'when the visitor has already been given suggestions' do
      let!(:first_visit) { described_class.new(session).names }

      it 'suggests the same five on the next request' do
        expect(demo_list.names).to eq(first_visit)
      end
    end

    context 'when the visitor has dismissed every suggestion' do
      before { session[described_class::KEY] = [] }

      it 'suggests a fresh five' do
        expect(demo_list.names.size).to eq(5)
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

    it 'suggests a fresh five when asked again' do
      expect(demo_list.names.size).to eq(5)
    end
  end
end
