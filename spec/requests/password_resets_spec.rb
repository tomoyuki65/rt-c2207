require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  let(:user) { FactoryBot.create(:user) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  describe "password reset test" do
    it "get new_password_reset_path" do
      get new_password_reset_path
      expect(response).to have_http_status(200)
    end

    it "send email address" do
      get new_password_reset_path

      # メールアドレスが無効の場合
      post password_resets_path, params: { password_reset: { email: "" } }
      expect(response).to_not have_http_status(200)
      expect(flash[:danger]).to eq "Email address not found"
      
      # メールアドレスが有効の場合
      post password_resets_path, params: { password_reset: { email: user.email } }
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(flash[:info]).to eq "Email sent with password reset instructions"
      expect(response).to redirect_to root_url
    end

    it "password reset form test" do
      get new_password_reset_path
      post password_resets_path, params: { password_reset: { email: user.email } }

      # コントローラーのインスタンス変数の値を取得
      password_reset_user = controller.instance_variable_get("@user")
      expect(password_reset_user.reset_digest).to_not be_nil

      # メールアドレスが無効の場合
      get edit_password_reset_url(password_reset_user.reset_token,
                                  email: "")
      expect(response).to redirect_to root_url

      # 無効なユーザーの場合
      password_reset_user.toggle!(:activated)
      get edit_password_reset_url(password_reset_user.reset_token,
                                  email: password_reset_user.email)
      expect(response).to redirect_to root_url
      password_reset_user.toggle!(:activated)

      # メールアドレスが有効で、トークンが無効の場合
      get edit_password_reset_url("wrong token",
                                  email: password_reset_user.email)
      expect(response).to redirect_to root_url

      # メールアドレスもトークンも有効の場合
      get edit_password_reset_url(password_reset_user.reset_token,
                                  email: password_reset_user.email)
      expect(response).to have_http_status(200)
      expect(response.body).to include password_reset_user.email

      # 無効なパスワードとパスワード確認の場合
      patch password_reset_url(password_reset_user.reset_token),
            params: { email: password_reset_user.email,
                      user: { password: "foobaz",
                              password_confirmation: "barquux" } }
      expect(response.body).to include "error_explanation"

      # パスワードが空の場合
      patch password_reset_url(password_reset_user.reset_token),
            params: { email: password_reset_user.email,
                      user: { password: "",
                              password_confirmation: "" } }
      expect(response.body).to include "error_explanation"

      # 有効なパスワードとパスワード確認の場合
      patch password_reset_url(password_reset_user.reset_token),
            params: { email: password_reset_user.email,
                      user: { password: "foobaz",
                              password_confirmation: "foobaz" } }
      expect(logged_in?).to be_truthy
      expect(password_reset_user.reload.reset_digest).to be_nil
      expect(flash[:success]).to eq "Password has been reset."
      expect(response).to redirect_to password_reset_user
    end

    it "expired token" do
      get new_password_reset_path
      post password_resets_path, params: { password_reset: { email: user.email } }
      password_reset_user = controller.instance_variable_get("@user")

      # ユーザーのreset_sent_atを過去日時に更新
      password_reset_user.update_attribute(:reset_sent_at, 3.hours.ago)

      # パスワード再設定の期限切れテスト
      patch password_reset_url(password_reset_user.reset_token),
            params: { email: password_reset_user.email,
                      user: { password: "foobaz",
                              password_confirmation: "foobaz" } }
      expect(flash[:danger]).to eq "Password reset has expired."
      expect(response).to redirect_to new_password_reset_url
    end
  end
end
