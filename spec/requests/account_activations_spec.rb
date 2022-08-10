require 'rails_helper'

RSpec.describe "AccountActivations", type: :request do
  let(:user) { FactoryBot.create(:user, activated: false, activated_at: nil) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "should redirect to root_url" do
    it "Invalid Activation Token" do
      get edit_account_activation_path("invalid token", email: user.email)
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq "Invalid activation link"
    end

    it "Token is correct but email address is invalid" do
      get edit_account_activation_path(user.activation_token, email: "wrong")
      expect(response).to redirect_to root_url
      expect(flash[:danger]).to eq "Invalid activation link"
    end
  end

  describe "should redirect to user_path(user)" do
    it "Activation token is correct" do
      get edit_account_activation_path(user.activation_token, email: user.email)
      expect(response).to redirect_to user_path(user)
      expect(logged_in?).to be_truthy
    end
  end
end
