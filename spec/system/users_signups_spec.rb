require 'rails_helper'

RSpec.describe "UsersSignups", type: :system do
  let(:user) { FactoryBot.build(:user, activated: false, activated_at: nil) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  scenario "invalid signup infomation" do
    visit signup_path
    expect(page).to have_current_path "/signup"

    # フォームの送信でエラーの場合
    expect {
      fill_in "Name",         with: ""
      fill_in "Email",        with: "user@invalid"
      fill_in "Password",     with: "foo"
      fill_in "Confirmation", with: "bar"
      click_button "Create my account"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_css ".alert"
      expect(page).to have_css ".alert-danger"
      expect(page).to have_content "The form contains"
      expect(page).to have_content "errors"
      expect(page).to have_css ".field_with_errors"
    }.to change(User, :count).by(0)
  end

  scenario "valid signup infomation with account activation" do
    visit signup_path
    expect(page).to have_current_path signup_path

    # フォームの送信が成功した場合
    expect {
      fill_in "Name",         with: user.name
      fill_in "Email",        with: user.email
      fill_in "Password",     with: user.password
      fill_in "Confirmation", with: user.password_confirmation
      click_button "Create my account"

      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(page).to have_content "Please check your email to activate your account."
      expect(page).to have_current_path root_url
    }.to change(User, :count).by(1)

    # 登録されたユーザーが有効化されていないこと
    registered_user = User.find_by(email: user.email)
    expect(registered_user.activated?).to be_falsey

    # 有効化していない状態でログインした場合
    visit login_path
    expect(page).to have_current_path login_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
    expect(page).to have_current_path root_url
    expect(page).to have_css ".alert"
    expect(page).to have_css ".alert-warning"
    message  = "Account not activated. "
    message += "Check your email for the activation link."
    expect(page).to have_content message

    # 有効化した状態でログインした場合
    registered_user.update_attribute(:activated,    true)
    registered_user.update_attribute(:activated_at, Time.zone.now)
    visit login_path
    expect(page).to have_current_path login_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"
    expect(page).to have_current_path user_path(registered_user)

    # ログイン状態の確認
    expect(page).to have_no_link "Log in"
    expect(page).to have_link "Account"
    expect(page).to have_link "Profile"
    expect(page).to have_link "Settings"
    expect(page).to have_button "Log out"
  end
end
