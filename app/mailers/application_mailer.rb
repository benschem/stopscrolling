# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@stopscroll.ing'
  layout 'mailer'
end
