# frozen_string_literal: true

# Rate limits count through Rails.cache, which is the null store in test, so nothing is ever counted
# and every limit looks like it isn't there. Examples that exercise a limit swap in a store that
# actually counts, for that example only.
module RateLimiting
  def enable_rate_limiting
    counter = ActiveSupport::Cache::MemoryStore.new

    allow(Rails.cache).to receive(:increment) do |key, amount, **options|
      counter.increment(key, amount, **options)
    end
  end
end

RSpec.configure do |config|
  config.include RateLimiting, type: :request
end
