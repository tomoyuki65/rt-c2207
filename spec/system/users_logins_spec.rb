require 'rails_helper'

RSpec.describe "UsersLogins", type: :system do
  let(:user) { FactoryBot.create(:user) }
  
  scenario "login with invalid information" do
    visit login_path
    expect(page).to have_current_path "/login"

    fill_in "Email",    with: ""
    fill_in "Password", with: ""
    click_button "Log in"

    expect(page).to have_css ".alert"
    expect(page).to have_css ".alert-danger"
    expect(page).to have_selector "div.alert-danger",
                                  text: "Invalid email/password combination"
    visit root_path
    expect(page).to_not have_css ".alert"
    expect(page).to_not have_css ".alert-danger"
    expect(page).to_not have_selector "div.alert-danger",
                                      text: "Invalid email/password combination"
    
    # メールアドレスは正しいが、パスワードが間違っている場合
    visit login_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "invalid"
    click_button "Log in"

    expect(page).to have_css ".alert"
    expect(page).to have_css ".alert-danger"
    expect(page).to have_selector "div.alert-danger",
                                  text: "Invalid email/password combination"
  end

  scenario "login with valid information followed by logout" do
    log_in_as(user)

    expect(page).to have_current_path user_path(user.id)
    expect(page).to have_no_link "Log in"
    expect(page).to have_link "Account"
    expect(page).to have_link "Profile"
    expect(page).to have_link "Settings"
    expect(page).to have_button "Log out"

    # ログアウトの確認
    find(".dropdown-toggle").click
    click_button "Log out"
    expect(page).to have_current_path root_url
    expect(page).to have_link "Log in"
  end
end
