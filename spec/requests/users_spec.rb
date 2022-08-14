require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }
  let(:unactivated_user) { FactoryBot.create(:unactivated_user) }

  describe "GET /signup" do
    it "returns http success" do
      get signup_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "should redirect not logged in" do
    it "users#edit" do
      get edit_user_path(user)
      expect(response).to_not have_http_status(:success)
      expect(response).to redirect_to login_url
      expect(flash).to be_any
      expect(flash[:danger]).to eq "Please log in."
    end

    it "users#update" do
      patch user_path(user), params: { user: { name: user.name,
                                               email: user.email } }
      expect(response).to_not have_http_status(:success)
      expect(response).to redirect_to login_url
      expect(flash).to be_any
      expect(flash[:danger]).to eq "Please log in."
    end

    it "users#index" do
      get users_path
      expect(response).to_not have_http_status(:success)
      expect(response).to redirect_to login_url
      expect(flash).to be_any
      expect(flash[:danger]).to eq "Please log in."
    end

    it "users#destroy" do
      admin_user = user
      not_admin_user = other_user

      expect {
        delete user_path(admin_user)
        expect(response).to redirect_to login_url
      }.to change(User, :count).by(0)
      expect(flash).to be_any
      expect(flash[:danger]).to eq "Please log in."
    end

    it "following" do
      get following_user_path(user)
      expect(response).to redirect_to login_url
    end

    it "followers" do
      get followers_user_path(user)
      expect(response).to redirect_to login_url
    end
  end

  describe "should redirect logged in as wrong user" do
    it "users#edit" do
      # 違うユーザーでログイン
      log_in_as(other_user)

      get edit_user_path(user)
      expect(response).to redirect_to root_url
      expect(flash).to_not be_any
    end

    it "users#update" do
      # 違うユーザーでログイン
      log_in_as(other_user)

      patch user_path(user), params: { user: { name: user.name,
                                               email: user.email } }
      expect(response).to redirect_to root_url
      expect(flash).to_not be_any
    end

    it "users#destroy" do
      admin_user = user
      not_admin_user = other_user

      # 非管理者ユーザーでログイン
      log_in_as(not_admin_user)
      expect {
        delete user_path(admin_user)
        expect(response).to redirect_to root_url
      }.to change(User, :count).by(0)
      expect(flash).to_not be_any
    end
  end

  describe "should not allow the admin atribute to be edited via the web" do
    it "inability to update admin rights" do
      log_in_as(other_user)
      expect(other_user.admin?).to be_falsey
      patch user_path(other_user), params: { user: { password: "password",
                                                     password_confirmation: "password",
                                                     admin: true } }
      expect(other_user.reload.admin?).to be_falsey
    end
  end

  describe "show only valid users" do
    it "activated user should be displayed" do
      get user_path(user)
      expect(response).to have_http_status(:success)
    end

    it "unactivated user should be redirect root_url" do
      get user_path(unactivated_user)
      expect(response).to redirect_to root_url
    end
  end
end
