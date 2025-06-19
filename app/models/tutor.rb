class Tutor < ApplicationRecord
  belongs_to :course

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true,
                   uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :cannot_be_assigned_to_multiple_courses, on: :create

  private

  def cannot_be_assigned_to_multiple_courses
    return unless email.present?

    if Tutor.exists?(email: email)
      errors.add(:base, "Tutor is already assigned to a course")
    end
  end
end
