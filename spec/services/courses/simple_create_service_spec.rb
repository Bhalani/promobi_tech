require 'rails_helper'

RSpec.describe Courses::SimpleCreateService, type: :service do
  let(:valid_course_params) do
    {
      course: {
        name: 'Math 101',
        tutors_attributes: [
          { name: 'Alice', email: 'alice@example.com' },
          { name: 'Bob', email: 'bob@example.com' }
        ]
      }
    }
  end

  it 'creates a course and tutors with valid params' do
    result = described_class.new(valid_course_params).call
    expect(result.success).to be true
    expect(result.data).to be_a(Course)
    expect(result.data.tutors.count).to eq(2)
  end

  it 'fails if course name is missing' do
    params = valid_course_params.deep_dup
    params[:course][:name] = ''
    result = described_class.new(params).call
    expect(result.success).to be false
    expect(result.errors).to include("name")
    expect(result.errors["name"]).to include("Name can't be blank")
  end

  it 'fails if course name is not unique' do
    Course.create!(name: 'Math 101')
    result = described_class.new(valid_course_params).call
    expect(result.success).to be false
    expect(result.errors).to include("name")
    expect(result.errors["name"]).to include("Name has already been taken")
  end

  it 'fails if tutor email is invalid' do
    params = valid_course_params.deep_dup
    params[:course][:tutors_attributes][0][:email] = 'not-an-email'
    result = described_class.new(params).call
    expect(result.success).to be false
    expect(result.errors["tutors_attributes"]).to be_a(Hash)
    expect(result.errors["tutors_attributes"]["0"]["email"]).to include("is invalid").or include("Tutors email is invalid")
  end

  it 'fails if tutor email is not unique' do
    Tutor.create!(name: 'Existing', email: 'alice@example.com', course: Course.create!(name: 'Other'))
    result = described_class.new(valid_course_params).call
    expect(result.success).to be false
    expect(result.errors["tutors_attributes"]).to be_a(Hash)
    expect(result.errors["tutors_attributes"]["0"]["email"]).to include("has already been taken").or include("assigned")
  end

  it 'fails if tutor name is missing' do
    params = valid_course_params.deep_dup
    params[:course][:tutors_attributes][0][:name] = ''
    result = described_class.new(params).call
    expect(result.success).to be false
    expect(result.errors["tutors_attributes"]).to be_a(Hash)
    expect(result.errors["tutors_attributes"]["0"]["name"]).to include("can't be blank")
  end

  it 'fails if a tutor is already assigned to a course' do
    existing_course = Course.create!(name: 'Physics')
    Tutor.create!(name: 'Alice', email: 'alice@example.com', course: existing_course)
    params = valid_course_params.deep_dup
    params[:course][:tutors_attributes][0][:email] = 'alice@example.com'
    result = described_class.new(params).call
    expect(result.success).to be false
    expect(result.errors["tutors_attributes"]).to be_a(Hash)
    expect(result.errors["tutors_attributes"]["0"]["base"]).to include("assigned")
  end

  it 'fails if all tutors have invalid params' do
    params = valid_course_params.deep_dup
    params[:course][:tutors_attributes] = [
      { name: '', email: 'not-an-email' },
      { name: '', email: '' },
      { name: 'A', email: 'bademail' }
    ]
    result = described_class.new(params).call
    expect(result.success).to be false
    # Tutor 1
    expect(result.errors["tutors_attributes"]["0"]["name"]).to include("can't be blank").or include("too short")
    expect(result.errors["tutors_attributes"]["0"]["email"]).to include("is invalid")
    # Tutor 2
    expect(result.errors["tutors_attributes"]["1"]["name"]).to include("can't be blank")
    expect(result.errors["tutors_attributes"]["1"]["email"]).to include("can't be blank")
    # Tutor 3
    expect(result.errors["tutors_attributes"]["2"]["name"]).to include("too short")
    expect(result.errors["tutors_attributes"]["2"]["email"]).to include("is invalid")
  end
end
