require 'rails_helper'

RSpec.describe "UsersIndexTests", type: :system do

  before do
    @user = FactoryBot.create(:user)
    @non_admin = FactoryBot.create(:other_user)

    50.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      FactoryBot.create(:user, name: name, email: email,
                               password: password, password_confirmation: password)
    end
  end

  scenario "index including pagination" do
    log_in_as(@user)
    visit users_path
    expect(page).to have_current_path users_path
    expect(page).to have_css ".pagination"
    expect(page.all(".pagination").count).to eq 2
    User.paginate(page: 1).each do |user|
      expect(page).to have_link user.name
    end
  end

  scenario "index as admin including pagination and delete links" do
    log_in_as(@user)
    visit users_path
    first_page_or_users = User.paginate(page: 1)
    first_page_or_users.each do |user|
      expect(page).to have_link user.name
      unless user == @user
        expect(page).to have_selector "button##{user.id}", text: "delete"
        expect {
          find("button##{user.id}").click
        }.to change(User, :count).by(-1)
      end
    end
  end

  scenario "index as non-admin" do
    log_in_as(@non_admin)
    visit users_path
    expect(page).to_not have_button "delete"
  end
end
