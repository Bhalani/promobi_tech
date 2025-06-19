module Api
  module V1
    class CoursesController < ApplicationController
      def create
        result = Api::V1::CourseOperations::Create.new(params.to_unsafe_h).call

        if result[:success]
          render json: {
            success: true,
            data: ActiveModelSerializers::SerializableResource.new(result[:data], include: [:tutors])
          }
        else
          render json: {
            success: false,
            errors: result[:errors]
          }, status: :unprocessable_entity
        end
      end

      def index
        courses = Course.includes(:tutors).all
        render json: {
          success: true,
          data: ActiveModelSerializers::SerializableResource.new(courses, include: [:tutors])
        }
      end

      private

      def course_params
        params.require(:course).permit(:name, tutors_attributes: [:name, :email])
      end
    end
  end
end
