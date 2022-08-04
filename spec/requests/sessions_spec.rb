require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /logout" do
    it "logout with valid" do
      # ログイン処理
      log_in_as(user)
      expect(response).to redirect_to user_path(user)

      # ログアウト処理
      delete logout_path
      expect(response).to redirect_to root_path

      # 2番目のウインドウでログアウトをクリックするユーザーをシミュレート
      delete logout_path
      expect(response).to redirect_to root_path
    end
  end

  describe "remember me" do
    it "login with remembering" do
      # ログイン処理（チェックボックスがON）
      log_in_as(user, remember_me: "1")
      expect(cookies[:remember_token]).to_not be_blank
    end

    it "login without remembering" do
      # ログイン処理（チェックボックスがON）
      log_in_as(user, remember_me: "1")

      # ログアウト処理
      delete logout_path

      # ログイン処理（チェックボックスがOFF）
      log_in_as(user, remember_me: "0")
      expect(cookies[:remember_token]).to be_blank
    end
  end
end
