require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:micropost) { FactoryBot.build(:micropost,
                                     content: "Lorem ipsum",
                                     user: user) }
  let(:first_micropost) { FactoryBot.create(:micropost,
                                            content: "first content",
                                            user: user) }
  let(:second_micropost) { FactoryBot.create(:micropost,
                                             content: "second content",
                                             user: user) }

  it "should be valid" do
    expect(micropost).to be_valid
  end

  it "user id should be present" do
    micropost.user_id = nil
    expect(micropost).to be_invalid
  end

  it "content should be present" do
    micropost.content = "   "
    expect(micropost).to be_invalid
  end

  it "content should be at most 140 characters" do
    micropost.content = "a" * 141
    expect(micropost).to be_invalid
  end

  it "order should be most recent first" do
    first_micropost
    second_micropost
    expect(Micropost.first).to eq second_micropost
  end

  it "associated microposts should be destroyed" do
    user.microposts.create!(content: "Lorem ipsum")
    expect {
      user.destroy
    }.to change(Micropost, :count).by(-1)
  end
end
