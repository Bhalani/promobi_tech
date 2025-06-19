module Api
  module V1
    module CourseOperations
      class Create < BaseOperation
        def initialize(params)
          @params = params
          @contract = CourseContract.new
        end

        def call
          validation = @contract.call(@params)
          return { success: false, errors: validation.errors.to_h } if validation.failure?

          begin
            course = nil
            ActiveRecord::Base.transaction do
              course_params = validation.to_h[:course]
              course = Course.create!(name: course_params[:name])
              course_params[:tutors_attributes].each do |tutor_params|
                course.tutors.create!(tutor_params)
              end
            end
            { success: true, data: course }
          rescue ActiveRecord::RecordInvalid => e
            { success: false, errors: { base: [e.message] } }
          end
        end
      end
    end
  end
end
