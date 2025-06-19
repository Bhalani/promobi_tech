require "rails_helper"

RSpec.describe Tutor, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { build(:tutor) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value("test@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }
  end

  describe "#cannot_be_assigned_to_multiple_courses" do
    let(:course) { FactoryBot.create(:course) }
    let(:email) { "unique@example.com" }

    it "allows creation if email is unique" do
      tutor = described_class.new(name: "John Doe", email: email, course: course)
      expect(tutor).to be_valid
    end

    it "adds error if email is already taken" do
      FactoryBot.create(:tutor, email: email)
      tutor = described_class.new(name: "Jane Smith", email: email, course: course)
      expect(tutor).not_to be_valid
      expect(tutor.errors[:base]).to include("Tutor is already assigned to a course")
    end
  end
end
