module Api
  module V1
    class CourseContract < Dry::Validation::Contract
      params do
        required(:course).hash do
          required(:name).filled(:string)
          required(:tutors_attributes).array(:hash) do
            required(:name).filled(:string)
            required(:email).filled(:string)
          end
        end
      end

      rule("course.name") do
        key.failure("can't be blank") if value.blank?
        key.failure("has already been taken") if value.present? && Course.exists?(name: value)
      end

      rule("course.tutors_attributes").each do
        if value[:name].blank? || value[:email].blank?
          key("tutors[#{path.last}]").failure("name and email are required")
        end
      end

      rule("course.tutors_attributes").each do
        unless value[:email] =~ URI::MailTo::EMAIL_REGEXP
          key("tutors[#{path.last}].email").failure("is invalid")
        end
      end

      rule("course.tutors_attributes").each do
        if value[:email].present?
          existing_tutor = Tutor.find_by(email: value[:email])
          if existing_tutor&.course_id.present?
            key("base").failure("Tutor #{value[:email]} is already assigned to another course")
          end
        end
      end
    end
  end
end
