# frozen_string_literal: true

# Activities Controller
class ActivitiesController < ApplicationController
  include Drawing

  NOTHING_LEFT_TO_SUGGEST = 'Your list already has everything we can think of!'

  allow_signed_out_access only: %i[index create destroy pick rogue]

  rescue_from ActiveRecord::RecordNotFound, with: :activity_not_found

  # Double the auth limit: typing out ten activities in a sitting is ordinary first-visit behaviour.
  rate_limit to: 20, within: 3.minutes, only: :create, with: lambda {
    redirect_to root_url, alert: 'Try again later.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  }

  before_action :set_activity, only: %i[destroy]
  before_action :set_activities, only: %i[index pick rogue]

  # GET /activities
  def index
    @activity = Activity.new
    @drawn_activity = activity_from_url
  end

  # POST /activities
  def create
    @activity = current_user.activities.build(activity_params)

    if activity_saved?
      redirect_to root_path, notice: 'Added', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
    else
      @activities = list_without(@activity)
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.destroy!
    redirect_to root_path, notice: 'Removed', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  end

  # POST /activities/pick
  def pick
    redirect_to root_path(activity_name: user_deck.draw), status: :see_other
  end

  # POST /activities/rogue
  def rogue
    rogue_activity_name = rogue_deck.draw
    return redirect_to root_path, notice: NOTHING_LEFT_TO_SUGGEST, status: :see_other if rogue_activity_name.nil?

    redirect_to root_path(activity_name: rogue_activity_name), status: :see_other
  end

  private

  def activity_not_found
    redirect_to root_path, alert: 'That activity does not exist.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  end

  # Adding something is what perisists a visitor
  # Saving the user saves the whole visible list
  def activity_saved?
    return @activity.save if current_user.persisted?
    return false unless current_user.save

    start_session_for(current_user)
    true
  end

  def set_activity
    @activity = current_user.activities.find_by!(name: params.expect(:id))
  end

  def list_without(candidate)
    current_user.activities.reject { |activity| activity.equal?(candidate) }
  end

  def set_activities
    @activities = current_user.activities
  end

  def activity_params
    params.expect(activity: [:name])
  end
end
