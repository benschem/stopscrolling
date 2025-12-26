# frozen_string_literal: true

RSpec.configure do |config|
  # FactoryBot::Syntax::Methods gives you access to these in tests:
  # build, build_list, create, create_list, and attributes_for
  config.include FactoryBot::Syntax::Methods
end
