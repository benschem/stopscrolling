# frozen_string_literal: true

# Suggestion endpoint picks from the list at config/activities_list.yml
ACTIVITIES_LIST = Rails.application
                       .config_for(:activities_list)
                       .fetch(:activities)
                       .uniq
                       .freeze
