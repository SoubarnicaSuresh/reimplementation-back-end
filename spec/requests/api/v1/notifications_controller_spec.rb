require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  # Setup test data
  let(:course) { Course.create(name: "Sample Course") }
  let(:user) { User.create(name: "sampleuser", email: "sampleuser@example.com", password: "password", full_name: "Sample User", role_id: 1) }
  let!(:notification) { Notification.create(subject: "Test Subject", description: "Test Description", expiration_date: 1.week.from_now, course: course, user: user) }
  let!(:another_notification) { Notification.create(subject: "Another Test Subject", description: "Another Test Description", expiration_date: 2.weeks.from_now, course: course, user: user) }

  # Tests for the #index action
  describe "GET #index" do
    it "returns a list of notifications" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
      expect(JSON.parse(response.body).size).to eq(2) # Ensure there are 2 notifications
    end

    it "returns notifications in the correct format" do
      get :index
      notifications = JSON.parse(response.body)
      expect(notifications.first).to have_key("id")
      expect(notifications.first).to have_key("subject")
      expect(notifications.first).to have_key("description")
      expect(notifications.first).to have_key("expiration_date")
    end
  end

  # Tests for the #show action
  describe "GET #show" do
    it "returns the correct notification" do
      get :show, params: { id: notification.id }
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include("application/json")
      notification_response = JSON.parse(response.body)
      expect(notification_response["id"]).to eq(notification.id)
      expect(notification_response["subject"]).to eq(notification.subject)
      expect(notification_response["description"]).to eq(notification.description)
      expect(notification_response["expiration_date"]).to eq(notification.expiration_date.as_json) # Format match
    end

    it "returns a 404 if the notification is not found" do
      get :show, params: { id: 9999 } # Assuming there's no notification with this ID
      expect(response).to have_http_status(:not_found)
    end
  end
end
