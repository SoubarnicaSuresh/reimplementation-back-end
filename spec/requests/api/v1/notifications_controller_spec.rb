require 'rails_helper'
require 'rails_helper'

RSpec.describe 'Notifications API', type: :request do
  let(:institution) { Institution.create(id: 100, name: 'NCSU') }
  let(:user) do
    institution
    User.create(id: 1, name: "admin", full_name: "admin", email: "admin@gmail.com", password_digest: "admin", role_id: 2, institution_id: institution.id)
  end
  let(:course) { Course.create(id: 101, name: 'CSC 574', institution_id: institution.id) }

  before do
    Notification.create(id: 1, course_name: course.name, user: user)
  end

  path '/api/v1/notifications' do
    get('list notifications') do
      tags 'Notifications'
      produces 'application/json'

      response(200, 'Success') do
        let!(:notifications) { create_list(:notification, 5, user: user, course_name: course.name) }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test! do |response|
          expect(JSON.parse(response.body).size).to eq(5)
        end
      end
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

  path '/api/v1/notifications/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the notification'

    get('show notification') do
      tags 'Notifications'
      response(200, 'Success') do
        let(:id) { Notification.first.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    patch('update notification') do
      tags 'Notifications'
      consumes 'application/json'
      parameter name: :notification, in: :body, schema: {
        type: :object,
        properties: {
          subject: { type: :string },
          description: { type: :string },
          expiration_date: { type: :string, format: :date },
          active_flag: { type: :boolean }
        }
      }

      response(200, 'Updated') do
        let(:id) { Notification.first.id }
        let(:notification) { { subject: 'Updated Notification', active_flag: true } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }
        let(:notification) { { subject: 'Updated Notification', active_flag: true } }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    delete('delete notification') do
      tags 'Notifications'

      response(204, 'Deleted') do
        let(:id) { Notification.first.id }
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/notifications/{id}/toggle_active' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the notification'

    patch('toggle notification visibility') do
      tags 'Notifications'

      response(200, 'Visibility toggled') do
        let(:id) { Notification.first.id }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end

      response(404, 'Not Found') do
        let(:id) { 'INVALID' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
