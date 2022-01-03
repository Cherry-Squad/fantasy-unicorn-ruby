
module Api
  module V1
    class AchievementController < DeviseTokenAuth::RegistrationsController
      before_action :authenticate_api_v1_user!

      def create
        begin
          achievement = Achievement.new(
            user_id: achievement_create_params[:user_id],
            achievement_identifier: achievement_create_params[:achievement_identifier]
          )
          if achievement.save
            render json: achievement, status: 201
          else
            render json: {error: "An Error occurred #{achievement.errors.full_messages}"}, status: 400
          end
        rescue => error
            render json: {error: "An Error occurred #{error.message}"}, status: 400
        end
      end

      def index
          achievements = get_achievements_for_current_user
          render json: achievements, status: 200
      end

      def update
        begin
          achievement = get_achievement_by_id
          if achievement
            if achievement.update(achievement_update_params)
                render json: achievement, status: 201
            else
                render json: {error: "An Error occurred #{achievement.errors.full_messages}"}, status: 400
            end
          else
            render json: {status: "Not Found 404"}, status: 404
          end
        rescue => error
            render json: {error: "An Error occurred #{error.message}"}, status: 400
        end
      end

      def delete
      achievement = get_achievement_by_id
        if achievement
            achievement.delete
            render json: nil, status: 204
        else
            render json: {status: "Not Found 404"}, status: 404
        end
      end

      def show
        achievement = Achievement.find(params[:id])
        if achievement
            render json: achievement, status: 200
        else
            render json: {status: "Not Found 404"}, status: 404
        end
      end
      private
        def achievement_create_params
            params.require(:achievement).permit([
                :user_id,
                :achievement_identifier
            ])
        end

        def achievement_update_params
            params.require(:achievement).permit([
                :id,
                :user_id,
                :achievement_identifier
            ])
        end

        def get_achievement_by_id
            @achievement = Achievement.find_by(id: params[:id], user: current_api_v1_user)
        end

        def get_achievements_for_current_user
            @achievements = Achievement.where(user: current_api_v1_user)
        end
    end
  end
end
