FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
  end
end
