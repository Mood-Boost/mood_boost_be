class Api::V1::Users::ActivitiesController < ApplicationController
  def index
    if params[:summary] == 'true'
      if User.exists?(id: params[:user_id])
        summary = UserActivity.activity_summary_by_user(params[:user_id])
        render json: { activity_summary: summary }, status: :ok
      else
        render json: ErrorSerializer.format_error(
          ErrorMessage.new("User not found", :not_found)
        ), status: :not_found
      end
    else
      activities = UserActivity.get_user_activities(params[:user_id])
      if activities.empty?
        render json: ErrorSerializer.format_error(
          ErrorMessage.new("User not found", :not_found)
        ), status: :not_found
      else
        render json: { activities: activities }, status: :ok
      end
    end
  end

  def create
    user_activity = UserActivity.create_new_activity(params[:user_id], params[:activity_id])
  
    if user_activity.persisted?
      render json: { user_activity: user_activity }, status: :created
    else
      render json: ErrorSerializer.format_error(
        ErrorMessage.new("Unable to create activity. Please ensure the user and activity are valid.", :unprocessable_entity)
      ), status: :unprocessable_entity
    end
  end

  private

  def user_activity_params
   params.require(:user_activity).permit(:user_id, :activity_id)
  end
end
