require 'rails_helper'

RSpec.describe "UsersProfiles", type: :system do
  before do
    @user = FactoryBot.create(:user)

    FactoryBot.create(:micropost,
                      content: "I just ate an orange!",
                      created_at: 10.minutes.ago,
                      user: @user)
    
    FactoryBot.create(:micropost,
                      content: "Check out the @tauday site by @mhartl: https://tauday.com",
                      created_at: 3.years.ago,
                      user: @user)

    FactoryBot.create(:micropost,
                      content: "Sad cats are sad: https://youtu.be/PKffm2uI4dk",
                      created_at: 2.hours.ago,
                      user: @user)

    FactoryBot.create(:micropost,
                      content: "Writing a short test",
                      created_at: Time.zone.now,
                      user: @user)

    30.times do |n|
      FactoryBot.create(:micropost,
                        content: Faker::Lorem.sentence(word_count: 5),
                        created_at: 42.days.ago,
                        user: @user)
    end
  end

  scenario "profile display" do
    visit user_path(@user)
    expect(page).to have_current_path user_path(@user)
    expect(page).to have_title full_title(@user.name)
    expect(page).to have_selector "h1", text: @user.name
    expect(page).to have_css "h1>img.gravatar"
    expect(page).to have_selector "h3", text: "Microposts (#{@user.microposts.count})"
    expect(page.all(".pagination").count).to eq 1
    @user.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_content micropost.content
    end
  end
end
