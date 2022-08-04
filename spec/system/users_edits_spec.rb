require 'rails_helper'

RSpec.describe "UsersEdits", type: :system do
  let(:user) { FactoryBot.create(:user) }

  scenario "unsuccessful edit" do
    log_in_as(user)

    visit edit_user_path(user)
    expect(page).to have_current_path edit_user_path(user)

    fill_in "Name",         with: ""
    fill_in "Email",        with: "foo@invalid"
    fill_in "Password",     with: "foo"
    fill_in "Confirmation", with: "bar"
    click_button "Save changes"

    expect(page).to have_css "#error_explanation"
    expect(page).to have_css ".alert"
    expect(page).to have_css ".alert-danger"
    expect(page).to have_content "The form contains"
    expect(page).to have_content "errors"
    expect(page).to have_css ".field_with_errors"
  end

  scenario "successful edit with friendly forwarding" do
    # friendly forwardingの検証
    visit edit_user_path(user)
    log_in_as(user)
    expect(page).to have_current_path edit_user_path(user)

    # 更新の検証
    fill_in "Name",         with: "Foo Bar"
    fill_in "Email",        with: "foo@bar.com"
    fill_in "Password",     with: ""
    fill_in "Confirmation", with: ""
    click_button "Save changes"

    expect(page).to have_css ".alert"
    expect(page).to have_css ".alert-success"
    expect(page).to have_content "Profile updated"
    expect(page).to have_current_path user_path(user)
    user.reload
    expect(page).to have_selector "h1", text: user.name

    # ログアウト後のfriendly forwardingの検証
    find(".dropdown-toggle").click
    click_button "Log out"
    expect(page).to have_current_path root_url
    log_in_as(user)
    expect(page).to have_current_path user_path(user)
  end
end
