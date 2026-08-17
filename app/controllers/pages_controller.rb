# frozen_string_literal: true

# Static pages that anyone can read, signed in or not
class PagesController < ApplicationController
  allow_signed_out_access only: %i[privacy]

  # GET /privacy
  def privacy; end
end
