require "rails_helper"

RSpec.describe UserActivity, type: :model do
  describe "Relationships" do
    it { should belong_to(:user) }
    it { should belong_to(:activity) }
  end

  describe ".create_new_activity" do
    let!(:user) { create(:user) }
    let!(:activity) { create(:activity) }

    it "validates the presence of user and activity" do
      user_activity = UserActivity.new(user_id: nil, activity_id: nil)

      expect(user_activity).not_to be_valid
      expect(user_activity.errors[:user]).to include("must exist")
      expect(user_activity.errors[:activity]).to include("must exist")
    end

    context "when user and activity are valid" do
      it "creates a new UserActivity" do
        user_activity = UserActivity.create_new_activity(user.id, activity.id)

        expect(user_activity).to be_persisted
        expect(user_activity.user_id).to eq(user.id)
        expect(user_activity.activity_id).to eq(activity.id)
      end
    end

    context "when the user does not exist" do
      it "returns an unsaved UserActivity object" do
        user_activity = UserActivity.create_new_activity(999, activity.id)

        expect(user_activity).not_to be_persisted
        expect(user_activity.errors.full_messages).to be_empty
      end
    end

    context "when the activity ID is nil" do
      it "returns an unsaved UserActivity object with validation errors" do
        user_activity = UserActivity.create_new_activity(user.id, nil)

        expect(user_activity).not_to be_persisted
        expect(user_activity.errors.full_messages).to include("Activity must exist")
      end
    end
  end

  describe ".get_user_activities" do
    let!(:user) { create(:user) }
    let!(:activity1) { create(:activity) }
    let!(:activity2) { create(:activity) }

    before do
      create(:user_activity, user: user, activity: activity1)
      create(:user_activity, user: user, activity: activity2)
    end

    context "when the user exists" do
      it "returns all activities associated with the user" do
        activities = UserActivity.get_user_activities(user.id)

        expect(activities).to contain_exactly(activity1, activity2)
      end
    end

    context "when the user does not exist" do
      it "returns an empty array" do
        activities = UserActivity.get_user_activities(999)

        expect(activities).to eq([])
      end
    end

    context "when the user has no activities" do
      let!(:new_user) { create(:user) }

      it "returns an empty array" do
        activities = UserActivity.get_user_activities(new_user.id)

        expect(activities).to eq([])
      end
    end
  end

  describe ".activity_summary_by_user" do
    let!(:user) { create(:user) }
    let!(:activity1) { create(:activity, name: "Running") }
    let!(:activity2) { create(:activity, name: "Swimming") }
  
    before do
      create_list(:user_activity, 5, user: user, activity: activity1)
      create_list(:user_activity, 3, user: user, activity: activity2)
    end
  
    context "when the user exists" do
      it "returns a summary of activity counts for the user" do
        summary = UserActivity.activity_summary_by_user(user.id)
  
        expect(summary).to eq({ "Running" => 5, "Swimming" => 3 })
      end
    end
  
    context "when the user does not exist" do
      it "returns an empty hash" do
        summary = UserActivity.activity_summary_by_user(999)
  
        expect(summary).to eq({})
      end
    end
  
    context "when the user has no activities" do
      let!(:new_user) { create(:user) }
  
      it "returns an empty hash" do
        summary = UserActivity.activity_summary_by_user(new_user.id)
        expect(summary).to eq({})
      end
    end
  end

  it "converts a summary array into a hash of activity names and counts" do
    summary = [
      { name: "Running", activity_count: 5 },
      { name: "Swimming", activity_count: 3 }
    ]
    result = UserActivity.build_summary_hash(summary)
    expected_result = {
      "Running" => 5,
      "Swimming" => 3
    }

    expect(result).to eq(expected_result)
  end

  it "returns an empty hash when the summary is empty" do
  
    summary = []
    result = UserActivity.build_summary_hash(summary)

    expect(result).to eq({})
  end
  
  describe ".activity_summary_by_user" do
    it "handles edge case where user ID is not an integer" do
      summary = UserActivity.activity_summary_by_user("invalid_id")
  
      expect(summary).to eq({})
    end
  end
  
end  