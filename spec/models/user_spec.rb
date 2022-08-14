require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:user_1) { FactoryBot.create(:user) }
  let(:user_2) { FactoryBot.create(:other_user) }
  let(:user_3) { FactoryBot.create(:third_user) }
  let(:micropost_1) { FactoryBot.create(:micropost,
                                        content: "user_1 micropost",
                                        user: user_1) }
  let(:micropost_2) { FactoryBot.create(:micropost,
                                        content: "user_2 micropost",
                                        user: user_2) }
  let(:micropost_3) { FactoryBot.create(:micropost,
                                        content: "user_3 micropost",
                                        user: user_3) }

  it "should be valid" do
    expect(user).to be_valid
  end

  it "name should be present" do
    user.name = "     "
    expect(user).to be_invalid
  end

  it "email should be present" do
    user.email = "     "
    expect(user).to be_invalid
  end

  it "name should not be too long" do
    user.name = "a" * 51
    expect(user).to be_invalid
  end

  it "email should not be too long" do
    user.email = "a" * 244 + "@example.com"
    expect(user).to be_invalid
  end

  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example
                           foo@bar_baz.com foo@bar+bazl.com foo@bar..com]
    invalid_addresses.each do | invalid_address |
      user.email = invalid_address
      expect(user).to be_invalid
    end
  end

  it "email addresses should be unique" do
    user.save
    duplicate_user = user.dup
    duplicate_user.email = user.email.upcase
    expect(duplicate_user).to be_invalid
  end

  it "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    user.email = mixed_case_email
    user.save
    expect(user.reload.email).to eq mixed_case_email.downcase
  end

  it "password should be present (nonblank)" do
    user.password = user.password_confirmation = " " * 6
    expect(user).to be_invalid
  end

  it "password should have a minimum length" do
    user.password = user.password_confirmation = "a" * 5
    expect(user).to be_invalid
  end

  it "authenticated? should return false for a user with nil digest" do
    expect(user.authenticated?(:remember, "")).to be_falsey
  end

  it "should follow and unfollow a user" do
    expect(user_1.following?(user_2)).to be_falsey
    user_1.follow(user_2)
    expect(user_1.following?(user_2)).to be_truthy
    expect(user_2.followers.include?(user_1)).to be_truthy
    user_1.unfollow(user_2)
    expect(user_1.following?(user_2)).to be_falsey
  end

  it "feed should have the right posts" do
    micropost_1
    micropost_2
    micropost_3
    user_1.follow(user_3)

    # フォローしているユーザーの投稿を確認
    user_3.microposts.each do |post_following|
      expect(user_1.feed.include?(post_following)).to be_truthy
    end

    # 自分自身の投稿を確認
    user_1.microposts.each do |post_self|
      expect(user_1.feed.include?(post_self)).to be_truthy
    end

    # フォローしていないユーザーの投稿を確認
    user_2.microposts.each do |post_unfollowed|
      expect(user_1.feed.include?(post_unfollowed)).to be_falsey
    end
  end
end
