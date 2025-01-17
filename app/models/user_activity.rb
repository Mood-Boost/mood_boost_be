class UserActivity < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  validates :user, presence: true
  validates :activity, presence: true

  def self.get_user_activities(user_id)
    user = User.find_by(id: user_id)
    return [] if user.nil?
    user.activities
  end

  def self.create_new_activity(user_id, activity_id)
    user = User.find_by(id: user_id)
    return UserActivity.new if user.nil?
    create_with_user_and_activity(user.id, activity_id)
  end

  def self.create_with_user_and_activity(user_id, activity_id)
    return nil unless user_id && activity_id
    create(user_id: user_id, activity_id: activity_id)
  end

  def self.activity_summary_by_user(user_id)
    return {} unless User.exists?(id: user_id)
  
    summary = select('activities.name, COUNT(user_activities.id) as activity_count')
              .joins(:activity)
              .where(user_id: user_id)
              .group('activities.name')
              .order('activity_count DESC')
              
    build_summary_hash(summary)
  end

  def self.build_summary_hash(summary)
    summary.each_with_object({}) do |activity, hash|
      hash[activity[:name]] = activity[:activity_count]
    end
  end
end