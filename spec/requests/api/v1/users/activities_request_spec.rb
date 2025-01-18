require 'rails_helper'

RSpec.describe "Activities Endpoints:", type: :request do
  describe "GET #index" do
    let!(:user) { create(:user) }

    context "when the user exists" do
      let!(:activity1) { create(:activity, name: "Running") }
      let!(:activity2) { create(:activity, name: "Swimming") }
      let!(:activity3) { create(:activity, name: "Cryptography") }

      before do
        create(:user_activity, user: user, activity: activity1)
        create(:user_activity, user: user, activity: activity2)
        create(:user_activity, user: user, activity: activity3)
      end

      it "returns a successful response" do
        get "/api/v1/users/#{user.id}/activities"

        expect(response).to have_http_status(:ok)
      end

      it "returns the correct list of activities for the user" do
        get "/api/v1/users/#{user.id}/activities"

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        activity_ids = [activity1.id, activity2.id, activity3.id]

        expect(parsed_response[:activities].map { |activity| activity[:id] }).to match_array(activity_ids)
      end
    end

    context "when the user does not exist" do
      it "returns a 404 status with an error message" do
        get "/api/v1/users/0/activities"
    
        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response[:errors].first[:detail]).to eq("User not found")
      end
    end

    context "when the summary parameter is true" do
      let!(:activity1) { create(:activity, name: "Running") }
      let!(:activity2) { create(:activity, name: "Swimming") }
      let!(:activity3) { create(:activity, name: "Cryptography") }
      let!(:activity4) { create(:activity, name: "Embroidery") }
      let!(:activity5) { create(:activity, name: "Worldbuilding") }

      before do
        create_list(:user_activity, 5, user: user, activity: activity1)
        create_list(:user_activity, 3, user: user, activity: activity2)
        create(:user_activity, user: user, activity: activity3)
        create(:user_activity, user: user, activity: activity4)
        create(:user_activity, user: user, activity: activity5)
      end

      it "returns a summary of activity counts for the user" do
        get "/api/v1/users/#{user.id}/activities", params: { summary: 'true' }

        parsed_response = JSON.parse(response.body, symbolize_names: true)

        expected_summary = {
          Cryptography: 1,
          Embroidery: 1,
          Running: 5,
          Swimming: 3,
          Worldbuilding: 1
        }

        expect(response).to have_http_status(:ok)
        expect(parsed_response[:activity_summary]).to eq(expected_summary)
      end

      it "returns an empty summary if the user has no activities" do
        new_user = create(:user)
        get "/api/v1/users/#{new_user.id}/activities", params: { summary: 'true' }

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:ok)
        expect(parsed_response[:activity_summary]).to eq({})
      end

      it "returns a 404 status if the user does not exist" do
        get "/api/v1/users/0/activities", params: { summary: 'true' }
    
        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response[:errors].first[:detail]).to eq("User not found")
      end
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user) }
    let!(:activity) { create(:activity, name: "Yoga") }

    context "when the request is valid" do
      it "creates a new UserActivity and returns a 201 status" do
        post "/api/v1/users/#{user.id}/activities", params: { activity_id: activity.id }

        expect(response).to have_http_status(:created)
        parsed_response = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_response[:user_activity][:user_id]).to eq(user.id)
        expect(parsed_response[:user_activity][:activity_id]).to eq(activity.id)
      end
    end

    context "when the activity is invalid" do
      it "returns a 422 status with an error message" do
        post "/api/v1/users/#{user.id}/activities", params: { activity_id: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        parsed_response = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_response[:errors][0][:detail]).to eq("Unable to create activity. Please ensure the user and activity are valid.")
      end
    end
  end

  describe "GET /api/v1/users/:user_id/activities" do
    context "when user ID is invalid" do
      it "returns a not found error" do
        get "/api/v1/users/999/activities"
  
        expect(response).to have_http_status(:not_found)
  
        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:errors].first[:detail]).to eq("User not found")
      end
    end
  end
  
  describe "POST /api/v1/users/:user_id/activities" do
    context "when user ID is invalid" do
      it "returns an unprocessable entity error" do
        post "/api/v1/users/999/activities", params: { activity_id: 1 }
  
        expect(response).to have_http_status(:unprocessable_entity)
  
        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:errors].first[:detail]).to eq("Unable to create activity. Please ensure the user and activity are valid.")
      end
    end
  end
end
