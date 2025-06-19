require 'debug'
require "rails_helper"

RSpec.describe "API V1 Courses", type: :request do
  describe "POST /api/v1/courses" do
    context "happy scenarios" do
      context "when creating a course with one tutor" do
        it "returns success" do
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [
                { name: "John Doe", email: "john@example.com" }
              ]
            }
          }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["success"]).to be true
          expect(json["data"]["name"]).to eq("Ruby Programming")
          expect(json["data"]["tutors"].size).to eq(1)
          expect(json["data"]["tutors"].first["email"]).to eq("john@example.com")
        end
      end

      context "when creating a course with multiple tutors" do
        it "returns success" do
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [
                { name: "John Doe", email: "john@example.com" },
                { name: "Jane Smith", email: "jane@example.com" }
              ]
            }
          }
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          expect(json["success"]).to be true
          expect(json["data"]["tutors"].map { |t| t["email"] }).to contain_exactly("john@example.com", "jane@example.com")
        end
      end

      context "when adding a new tutor to an existing course" do
        it "returns error" do
          course = Course.create!(name: "Ruby Programming")
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [
                { name: "Jane Smith", email: "jane@example.com" }
              ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]["name"]).to include("has already been taken")
        end
      end
    end

    context "breaking scenarios" do
      context "when course name is missing" do
        it "returns error" do
          post "/api/v1/courses", params: {
            course: {
              tutors_attributes: [ { name: "John Doe", email: "john@example.com" } ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]["name"]).to include("is missing")
        end
      end

      context "when tutor name is missing" do
        it "returns error" do
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [ { email: "john@example.com" } ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]["tutors_attributes"]["0"]["name"]).to include("is missing")
        end
      end

      context "when tutor email is missing" do
        it "returns error" do
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [ { name: "John Doe" } ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]["tutors_attributes"]["0"]["email"]).to include("is missing")
        end
      end

      context "when tutor email format is invalid" do
        it "returns error" do
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [ { name: "John Doe", email: "not-an-email" } ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["tutors[0]"]["email"]).to include("is invalid")
        end
      end

      context "when course name already exists" do
        it "returns error" do
          Course.create!(name: "Ruby Programming")
          post "/api/v1/courses", params: {
            course: {
              name: "Ruby Programming",
              tutors_attributes: [ { name: "Jane Smith", email: "jane@example.com" } ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]["name"]).to include("has already been taken")
        end
      end

      context "when multiple fields are invalid" do
        it "returns all validation errors" do
          post "/api/v1/courses", params: {
            course: {
              tutors_attributes: [ {} ]
            }
          }
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["success"]).to be false
          expect(json["errors"]["course"]).to be_an(Array)
        end
      end
    end
  end

  describe "GET /api/v1/courses" do
    it "returns all courses with their tutors" do
      course1 = Course.create!(name: "Ruby Programming")
      course2 = Course.create!(name: "Python Programming")
      Tutor.create!(name: "John Doe", email: "john@example.com", course: course1)
      Tutor.create!(name: "Jane Smith", email: "jane@example.com", course: course2)
      get "/api/v1/courses"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["success"]).to be true
      expect(json["data"].length).to eq(2)
      expect(json["data"].first["tutors"]).to be_present
    end
  end
end
