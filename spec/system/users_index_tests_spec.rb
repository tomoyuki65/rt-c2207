require 'rails_helper'

RSpec.describe "UsersIndexTests", type: :system do

  before do
    @user = FactoryBot.create(:user)
    @non_admin = FactoryBot.create(:other_user)
    @unactivated_user = FactoryBot.create(:unactivated_user)

    60.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      if n <= 50
        FactoryBot.create(:user, name: name, email: email,
                                 password: password, password_confirmation: password,
                                 activated: true, activated_at: Time.zone.now)
      else
        FactoryBot.create(:user, name: name, email: email,
          password: password, password_confirmation: password)
      end
    end
  end

  scenario "index including pagination" do
    log_in_as(@user)
    visit users_path
    expect(page).to have_current_path users_path
    expect(page).to have_css ".pagination"
    expect(page.all(".pagination").count).to eq 2
    first_page_or_users = User.where(activated: true).paginate(page: 1).order("id")
    first_page_or_users.each do |user|
      expect(page).to have_link user.name
    end
  end

  # confirmのクリック処理のため、js: true でテストする
  scenario "index as admin including pagination and delete links", js: true do
    log_in_as(@user)
    expect(page).to have_current_path user_path(@user)
    click_link "Users"
    expect(page).to have_current_path users_path
    first_page_or_users = User.where(activated: true).paginate(page: 1).order("id")
    first_page_or_users.each do |user|
      expect(page).to have_link user.name
      unless user == @user
        # deleteボタンのclass名が存在する
        expect(page).to have_css ".button-#{user.id}"
        # deleteボタンをクリックし、confirmでOKする
        expect {
          page.accept_confirm do
            click_button "delete", match: :first
          end
          expect(page).to have_content "User deleted"
        }.to change(User, :count).by(-1)
        # deleteボタンのclass名が存在しない
        expect(page).to_not have_css ".button-#{user.id}"
      end
    end
  end

  scenario "index as non-admin" do
    log_in_as(@non_admin)
    click_link "Users"
    expect(page).to have_current_path users_path
    expect(page).to_not have_button "delete"
  end
end
