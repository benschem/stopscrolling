# frozen_string_literal: true

# Buttons labelled by a glyph carry their name in aria-label, so specs have to look there
# to find them by the name a screen reader would read out.
Capybara.enable_aria_label = true
