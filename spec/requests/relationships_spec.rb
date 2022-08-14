require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }

  before do
    @relationship = FactoryBot.create(:relationship,
                                      follower_id: user.id,
                                      followed_id: other_user.id)
  end

  describe "should require logged-in user" do
    it "create" do
      expect {
        post relationships_path
      }.to change(Relationship, :count).by(0)
      expect(response).to redirect_to login_url
    end

    it "destroy" do
      expect {
        delete relationship_path(@relationship)
      }.to change(Relationship, :count).by(0)
      expect(response).to redirect_to login_url
    end
  end
end
