require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }
  let(:relationship) { FactoryBot.build(:relationship,
                                        follower_id: user.id,
                                        followed_id: other_user.id) }

  it "should be valid" do
    expect(relationship).to be_valid
  end

  it "should require a follower_id" do
    relationship.follower_id = nil
    expect(relationship).to be_invalid
  end

  it "should require a followed_id" do
    relationship.followed_id = nil
    expect(relationship).to be_invalid
  end
end
