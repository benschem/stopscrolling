# frozen_string_literal: true

# Activities Controller
class ActivitiesController < ApplicationController
  NOTHING_LEFT_TO_SUGGEST = "You've already got everything we can think of."

  allow_signed_out_access only: %i[index random suggestion create destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :activity_not_found

  # Double the auth limit: typing out ten activities in a sitting is ordinary first-visit behaviour.
  rate_limit to: 20, within: 3.minutes, only: :create, with: lambda {
    redirect_to root_url, alert: 'Try again later.' # rubocop:disable Rails/I18nLocaleTexts
  }

  before_action :set_activity, only: %i[destroy]
  before_action :set_activities, only: %i[index random suggestion]

  # GET /activities
  def index
    @activity = Activity.new
    @random_activity = suggestion_named_in_the_url
  end

  # POST /activities
  def create
    build_demo_activities

    @activity = current_user.activities.build(activity_params)

    if activity_saved?
      redirect_to root_path, notice: 'Activity created!' # rubocop:disable Rails/I18nLocaleTexts
    else
      @activities = list_without(@activity)
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /activities/1
  def destroy
    discard_activity
    redirect_to root_path, notice: 'Activity deleted!', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  end

  # POST /activities/random
  def random
    redirect_to root_path(suggestion: @activities.sample&.name), status: :see_other
  end

  # POST /activities/suggestion
  def suggestion
    suggested_name = suggestions_not_on_the_list.sample

    return redirect_to root_path, notice: NOTHING_LEFT_TO_SUGGEST, status: :see_other if suggested_name.nil?

    redirect_to root_path(suggestion: suggested_name), status: :see_other
  end

  private

  def suggestion_named_in_the_url
    name = params[:suggestion]
    return if name.blank? || !ours_to_suggest?(name)

    Activity.new(name: name)
  end

  def ours_to_suggest?(name)
    @activities.any? { |activity| activity.name == name } || ACTIVITIES_LIST.include?(name)
  end

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
    name = params.expect(:id)

    @activity = if current_user.persisted?
                  current_user.activities.find_by!(name: name)
                else
                  find_demo_activity(name)
                end
  end

  def find_demo_activity(name)
    build_demo_activities

    current_user.activities.find { |activity| activity.name == name } ||
      raise(ActiveRecord::RecordNotFound)
  end

  def discard_activity
    return demo_activities.remove(@activity.name) unless @activity.persisted?

    @activity.destroy!
  end

  def suggestions_not_on_the_list
    ACTIVITIES_LIST - @activities.map(&:name)
  end

  def list_without(candidate)
    current_user.activities.reject { |activity| activity.equal?(candidate) }
  end

  def set_activities
    build_demo_activities

    @activities = current_user.activities
  end

  def activity_params
    params.expect(activity: [:name])
  end
end
