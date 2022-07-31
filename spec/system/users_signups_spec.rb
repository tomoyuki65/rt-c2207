require 'rails_helper'

RSpec.describe "UsersSignups", type: :system do
  let(:user) { FactoryBot.build(:user) }

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

  scenario "valid signup infomation" do
    visit signup_path
    expect(page).to have_current_path "/signup"

    # フォームの送信が成功した場合
    expect {
      fill_in "Name",         with: user.name
      fill_in "Email",        with: user.email
      fill_in "Password",     with: user.password
      fill_in "Confirmation", with: user.password_confirmation
      click_button "Create my account"

      expect(page).to have_css ".alert"
      expect(page).to have_css ".alert-success"
      expect(page).to have_content "Welcome to the Micropost App with Rails7"

      user_id = User.find_by(email: user.email)
      expect(page).to have_current_path user_path(user_id)
    }.to change(User, :count).by(1)

    # ログイン状態の確認
    expect(page).to have_no_link "Log in"
    expect(page).to have_link "Account"
    expect(page).to have_link "Profile"
    expect(page).to have_link "Settings"
    expect(page).to have_button "Log out"
  end
end
