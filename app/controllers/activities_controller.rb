# frozen_string_literal: true

# Activities Controller
class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[destroy]
  before_action :set_activities, only: %i[index random]

  # GET /activities
  def index
    @activity = Activity.new
  end

  # POST /activities
  def create
    @activity = Activity.new(activity_params)
    @activity.user = Current.user

    if @activity.save
      redirect_to activities_path, notice: 'Activity created!' # rubocop:disable Rails/I18nLocaleTexts
    else
      render :index, status: :unprocessable_content
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.destroy!
    redirect_to activities_path, notice: 'Activity deleted!', status: :see_other # rubocop:disable Rails/I18nLocaleTexts
  end

  # GET /activities/random
  def random
    @activity = Activity.new
    @random_activity = @activities.sample
    render :index
  end

  private

  def set_activity
    @activity = Activity.find(params.expect(:id))
  end

  def set_activities
    @activities = Current.user.activities
  end

  def activity_params
    params.expect(activity: [:name])
  end
end
