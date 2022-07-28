require 'rails_helper'

RSpec.describe "SiteLayouts", type: :system do

  # レイアウトのリンクに対するテスト
  scenario "layout links" do
    visit root_path
    expect(page).to have_current_path "/"
    expect(page).to have_link "RT-C2207 App", href: root_path
    expect(page).to have_link "Home",         href: root_path
    expect(page).to have_link "Help",         href: help_path
    expect(page).to have_link "About",        href: about_path
    expect(page).to have_link "Contact",      href: contact_path
    visit contact_path
    expect(page).to have_title full_title("Contact")
    visit signup_path
    expect(page).to have_title full_title("Sign up")
  end
end
