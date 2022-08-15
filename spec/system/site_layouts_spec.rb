require 'rails_helper'

RSpec.describe "SiteLayouts", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }
  let(:third_user) { FactoryBot.create(:third_user) }

  # レイアウトのリンクに対するテスト
  scenario "layout links" do
    visit root_path
    expect(page).to have_current_path root_path
    expect(page).to have_link "RT-C2207 App",      href: root_path
    expect(page).to have_link "Home",              href: root_path
    expect(page).to have_link "Help",              href: help_path
    expect(page).to have_link "About",             href: about_path
    expect(page).to have_link "Contact",           href: contact_path
    expect(page).to have_link "Log in",            href: login_path
    expect(page).to have_link "メールアドレスで登録", href: signup_path
    expect(page).to have_link "ログイン",           href: login_path

    click_link "Help"
    expect(page).to have_current_path help_path
    expect(page).to have_title full_title("Help")

    click_link "Log in"
    expect(page).to have_current_path login_path
    expect(page).to have_title full_title("Log in")

    click_link "About"
    expect(page).to have_current_path about_path
    expect(page).to have_title full_title("About")

    click_link "Contact"
    expect(page).to have_current_path contact_path
    expect(page).to have_title full_title("Contact")

    click_link "メールアドレスで登録"
    expect(page).to have_current_path signup_path
    expect(page).to have_title full_title("Sign up")

    click_link "ログイン"
    expect(page).to have_current_path login_path
    expect(page).to have_title full_title("Log in")

    # ログインした場合
    log_in_as(user)
    expect(page).to have_no_link "Log in"
    expect(page).to have_no_link "メールアドレスで登録"
    expect(page).to have_no_link "ログイン"
    expect(page).to have_link "Account"
    expect(page).to have_link "Profile"
    expect(page).to have_link "Settings"
    expect(page).to have_button "Log out"
  end

  # homeに表示されるマイクロポスト
  scenario "micropost on Home page" do
    10.times do |n|
      FactoryBot.create(:micropost,
                        content: "user micropost-#{n}",
                        user: user)
    end

    20.times do |n|
      FactoryBot.create(:micropost,
                        content: "other_user micropost-#{n}",
                        user: other_user)
    end

    20.times do |n|
      FactoryBot.create(:micropost,
                        content: "third_user micropost-#{n}",
                        user: third_user)
    end

    visit root_path
    expect(page).to have_current_path root_path

    Micropost.limit(30).each do |micropost|
      expect(page).to have_link micropost.user.name
      expect(page).to have_content micropost.content
    end
  end
end
