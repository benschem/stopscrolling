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

    it 'routes to #random' do
      expect(get: '/activities/random').to route_to('activities#random')
    end

    it 'routes to #suggestion' do
      expect(get: '/activities/suggestion').to route_to('activities#suggestion')
    end
  end
end
