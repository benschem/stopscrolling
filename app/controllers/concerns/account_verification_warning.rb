# frozen_string_literal: true

# Nags whoever is signed in to verify their email address before the account is swept
module AccountVerificationWarning
  extend ActiveSupport::Concern
  include ActionView::Helpers::DateHelper

  include SessionManagement

  included do
    before_action :warn_of_impending_account_deletion, if: :account_email_address_unverified?
  end

  private

  def account_email_address_unverified?
    Current.account&.unverified?
  end

  def warn_of_impending_account_deletion
    if Current.account.verification_expired?
      grace_timeframe = distance_of_time_in_words(grace_time_remaining)

      flash[:warn] = "This account will be deleted unless you verify your email address within #{grace_timeframe}"
    else
      flash[:warn] = 'Please verify your email address' # rubocop:disable Rails/I18nLocaleTexts
    end
  end

  def grace_time_remaining
    active_for = Time.current - Current.account.created_at
    [EmailAddressVerification::UNVERIFIED_GRACE_PERIOD - active_for, 0].max
  end
end
