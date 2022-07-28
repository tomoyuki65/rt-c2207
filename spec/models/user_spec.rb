require 'rails_helper'

RSpec.describe User, type: :model do

  before do
    @user = FactoryBot.build(:user)
  end

  it "should be valid" do
    expect(@user).to be_valid
  end

  it "name should be present" do
    @user.name = "     "
    expect(@user).to be_invalid
  end

  it "email should be present" do
    @user.email = "     "
    expect(@user).to be_invalid
  end

  it "name should not be too long" do
    @user.name = "a" * 51
    expect(@user).to be_invalid
  end

  it "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    expect(@user).to be_invalid
  end

  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example
                           foo@bar_baz.com foo@bar+bazl.com foo@bar..com]
    invalid_addresses.each do | invalid_address |
      @user.email = invalid_address
      expect(@user).to be_invalid
    end
  end

  it "email addresses should be unique" do
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    expect(duplicate_user).to be_invalid
  end

  it "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    expect(@user.reload.email).to eq mixed_case_email.downcase
  end

  it "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    expect(@user).to be_invalid
  end

  it "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    expect(@user).to be_invalid
  end
end
