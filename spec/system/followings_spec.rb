require 'rails_helper'

RSpec.describe "Followings", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:other_user) }
  let(:third_user) { FactoryBot.create(:third_user) }
  let(:micropost_1) { FactoryBot.create(:micropost,
                                        content: "user micropost",
                                        user: user) }
  let(:micropost_2) { FactoryBot.create(:micropost,
                                        content: "other_user micropost",
                                        user: other_user) }
  let(:micropost_3) { FactoryBot.create(:micropost,
                                        content: "third_user micropost",
                                        user: third_user) }

  before do
    FactoryBot.create(:relationship,
                      follower_id: user.id,
                      followed_id: other_user.id)

    FactoryBot.create(:relationship,
                      follower_id: user.id,
                      followed_id: third_user.id)

    FactoryBot.create(:relationship,
                      follower_id: other_user.id,
                      followed_id: user.id)

    FactoryBot.create(:relationship,
                      follower_id: third_user.id,
                      followed_id: user.id)
  end

  scenario "following page" do
    log_in_as(user)
    click_link "following"
    expect(page).to have_current_path following_user_path(user)
    expect(user.following.empty?).to be_falsey
    expect(page).to have_selector "strong#following", text: user.following.count.to_s
    user_following = user.following.paginate(page: 1).order("relationships.created_at DESC")
    user_following.each do |following_user|
      expect(page).to have_link following_user.name, href: user_path(following_user)
    end
  end

  scenario "followers page" do
    log_in_as(user)
    click_link "followers"
    expect(page).to have_current_path followers_user_path(user)
    expect(user.followers.empty?).to be_falsey
    expect(page).to have_selector "strong#followers", text: user.followers.count.to_s
    user_followers = user.followers.paginate(page: 1).order("relationships.created_at DESC")
    user_followers.each do |followers_user|
      expect(page).to have_link followers_user.name, href: user_path(followers_user)
    end
  end

  scenario "should follow", js: true do
    log_in_as(other_user)
    click_link "Users"
    expect(page).to have_current_path users_path
    expect(page).to have_link third_user.name, href: user_path(third_user)

    # third_userのページにアクセス
    click_link third_user.name
    expect(page).to have_current_path user_path(third_user)
    expect(page).to have_button "Follow"
    expect(page).to have_selector "strong#following", text: "1"
    expect(page).to have_selector "strong#followers", text: "1"
    expect(other_user.following.count).to eq 1
    expect(other_user.followers.count).to eq 1

    # Followボタンをクリック
    expect {
      click_button "Follow"
      expect(page).to have_button "Unfollow"
    }.to change(Relationship, :count).by(1)
    expect(page).to have_selector "strong#following", text: "1"
    expect(page).to have_selector "strong#followers", text: "2"
    expect(other_user.following.count).to eq 2
    expect(other_user.followers.count).to eq 1
  end

  scenario "should unfollow", js: true  do
    log_in_as(user)
    expect(page).to have_link "following"
    click_link "following"
    expect(page).to have_current_path following_user_path(user)
    expect(page).to have_link other_user.name, href: user_path(other_user)

    # other_userのページにアクセス
    click_link other_user.name, match: :first
    expect(page).to have_current_path user_path(other_user)
    expect(page).to have_button "Unfollow"
    expect(page).to have_selector "strong#following", text: "1"
    expect(page).to have_selector "strong#followers", text: "1"
    expect(user.following.count).to eq 2
    expect(user.followers.count).to eq 2

    # Unfollowボタンをクリック
    expect {
      click_button "Unfollow"
      expect(page).to have_button "Follow"
    }.to change(Relationship, :count).by(-1)
    expect(page).to have_selector "strong#following", text: "1"
    expect(page).to have_selector "strong#followers", text: "0"
    expect(user.following.count).to eq 1
    expect(user.followers.count).to eq 2
  end

  scenario "feed on Home page" do
    micropost_1
    micropost_2
    micropost_3

    log_in_as(user)
    click_link "Home"
    expect(page).to have_current_path root_path
    user.feed.paginate(page: 1).each do |micropost|
      expect(page).to have_content micropost.content
    end
  end
end
