# frozen_string_literal: true

# Activities Controller
class ActivitiesController < ApplicationController
  allow_signed_out_access only: %i[index random suggestion destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :activity_not_found

  before_action :set_activity, only: %i[destroy]
  before_action :set_activities, only: %i[index random suggestion]

  # GET /activities
  def index
    @activity = Activity.new
  end

  # POST /activities
  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user

    if @activity.save
      redirect_to activities_path, notice: 'Activity created!' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /activities/1
  def destroy
    discard_activity
    redirect_to activities_path, notice: 'Activity deleted!', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  end

  # GET /activities/random
  def random
    @activity = Activity.new
    @random_activity = @activities.sample
    render :index
  end

  # GET /activities/suggestion
  def suggestion
    @activity = Activity.new
    @random_activity = Activity.new(name: ACTIVITIES_LIST.sample)
    render :index
  end

  private

  def activity_not_found
    redirect_to activities_path, alert: 'That activity does not exist.', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
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

  def set_activities
    build_demo_activities

    @activities = current_user.activities
  end

  def activity_params
    params.expect(activity: [:name])
  end
end
