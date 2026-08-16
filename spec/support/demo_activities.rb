# frozen_string_literal: true

# The suggestions a visitor is being shown, read from the session the same way the app writes them.
module DemoActivitySuggestions
  def suggestions
    session[DemoActivityList::KEY]
  end
end

RSpec.configure do |config|
  config.include DemoActivitySuggestions, type: :request
end
