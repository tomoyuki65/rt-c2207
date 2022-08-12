require 'rails_helper'

RSpec.describe "UsersLogins", type: :system do
  let(:user) { FactoryBot.create(:user) }
  
  scenario "login with invalid information" do
    visit login_path
    expect(page).to have_current_path login_path

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

    expect(page).to have_current_path user_path(user)
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

  scenario "password resets test" do
    visit login_path
    click_link "(forgot password)"
    expect(page).to have_current_path new_password_reset_path

    # メールアドレスが無効な場合
    fill_in "Email", with: ""
    click_button "Submit"
    expect(page).to have_selector "div.alert-danger",
                                  text: "Email address not found"

    # メールアドレスが有効な場合
    fill_in "Email", with: user.email
    click_button "Submit"
    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(page).to have_selector "div.alert-info",
                                  text: "Email sent with password reset instructions"
    expect(page).to have_current_path root_url

    # 最後に送信されたメールを取得
    mail = ActionMailer::Base.deliveries.last

    # メールからURLを抽出
    body = mail.body.encoded
    url = body[/http[^"]+\/password_resets\/[\w+-]+\/edit\?email=[\w+-]+\%40([a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.)+[a-zA-Z]{2,}/]
    
    visit url
    expect(page).to have_current_path url

    # 無効なパスワードとパスワード確認の場合
    fill_in "Password",     with: "foobaz"
    fill_in "Confirmation", with: "barquux"
    click_button "Update password"
    expect(page).to have_css "div#error_explanation"

    # パスワードが空の場合
    fill_in "Password",     with: ""
    fill_in "Confirmation", with: ""
    click_button "Update password"
    expect(page).to have_css "div#error_explanation"

    # 有効なパスワードとパスワード確認の場合
    fill_in "Password",     with: "foobaz"
    fill_in "Confirmation", with: "foobaz"
    click_button "Update password"
    expect(page).to have_current_path user_path(user)
    expect(page).to have_selector "div.alert-success",
                                  text: "Password has been reset."

    # ログイン状態の確認
    expect(page).to have_no_link "Log in"
    expect(page).to have_link "Account"
    expect(page).to have_link "Profile"
    expect(page).to have_link "Settings"
    expect(page).to have_button "Log out"
  end
end
