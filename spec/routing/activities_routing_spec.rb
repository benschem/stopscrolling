# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivitiesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/activities').to route_to('activities#index')
    end

    it 'routes to #create' do
      expect(post: '/activities').to route_to('activities#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/activities/1').to route_to('activities#destroy', id: '1')
    end

    it 'keeps a dot in the name instead of reading it as a format' do
      expect(delete: '/activities/Watch%20Dr.%20Who').to route_to('activities#destroy', id: 'Watch Dr. Who')
    end

    it 'keeps an escaped slash in the name' do
      expect(delete: '/activities/Cook%2Fbake').to route_to('activities#destroy', id: 'Cook/bake')
    end

    it 'routes to #pick' do
      expect(post: '/activities/pick').to route_to('activities#pick')
    end

    it 'routes to #rogue' do
      expect(post: '/activities/rogue').to route_to('activities#rogue')
    end
  end
end
