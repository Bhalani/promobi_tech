class CourseSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :tutors
end
