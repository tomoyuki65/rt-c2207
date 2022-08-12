require 'rails_helper'

RSpec.describe "Microposts", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }
  let(:micropost) { FactoryBot.create(:micropost,
                                      content: "I just ate an orange!",
                                      created_at: 10.minutes.ago,
                                      user: user) }
  let(:second_micropost) { FactoryBot.create(:micropost,
                                      content: "other user micropost",
                                      created_at: 10.minutes.ago,
                                      user: other_user) }

  describe "should redirect" do
    it "create when not logged in" do
      expect {
        post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
      }.to change(Micropost, :count).by(0)
      expect(response).to redirect_to login_url
    end

    it "destroy when not logged in" do
      expect {
        delete micropost_path(user)
      }.to change(Micropost, :count).by(0)
      expect(response).to redirect_to login_url
    end

    it "destroy for wrong micropost" do
      log_in_as(user)
      other_micropost = second_micropost
      expect {
        delete micropost_path(other_micropost)
      }.to change(Micropost, :count).by(0)
      expect(response).to redirect_to root_url
    end
  end
end
