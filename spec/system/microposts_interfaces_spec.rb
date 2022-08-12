require 'rails_helper'

RSpec.describe "MicropostsInterfaces", type: :system do
  let(:other_user) { FactoryBot.create(:other_user) }

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

  scenario "pagination appears on static_pages/home" do
    log_in_as(@user)
    click_link "Home"
    expect(page).to have_current_path root_path
    expect(page.all(".pagination").count).to eq 1
    expect(page).to have_selector "input[type=file]"
    expect(page).to have_css "#micropost_image"
  end

  scenario "invalid send" do
    log_in_as(@user)
    click_link "Home"
    expect {
      fill_in "micropost[content]", with: ""
      click_button "Post"
    }.to change(Micropost, :count).by(0)
    expect(page).to have_css "#error_explanation"
    expect(page).to have_link "Next →", href: "/?page=2"
  end

  scenario "valid send" do
    log_in_as(@user)
    click_link "Home"
    expect {
      @content = "This micropost really ties the room together"
      fill_in "micropost[content]", with: @content
      attach_file "micropost[image]", "spec/files/test-image.png"
      click_button "Post"
    }.to change(Micropost, :count).by(1)
    expect(page).to have_current_path root_url
    expect(page).to have_selector "div.alert-success",
                                  text: "Micropost created!"
    expect(page).to have_content @content
    expect(page).to have_selector "img[src$='test-image.png']"
  end

  scenario "delete micropost", js: true do
    log_in_as(@user)

    # static_pages/homeにアクセス
    click_link "Home"
    expect(page).to have_button "delete"

    @user.feed.paginate(page: 1).each do |micropost|
      if micropost.user_id == @user.id
        expect(page).to have_css "button.button-#{micropost.id}"
      end
    end

     # static_pages/homeにあるdeleteボタンからマイクロポストを削除
    first_micropost = @user.feed.paginate(page: 1).where(user_id: @user.id).first
    expect(page).to have_css "button.button-#{first_micropost.id}"
    expect {
      page.accept_confirm do
        click_button "delete", match: :first
      end
      expect(page).to have_content "Micropost deleted"
    }.to change(Micropost, :count).by(-1)
    expect(page).to_not have_css "button.button-#{first_micropost.id}"

    # users/showにアクセス
    visit user_path(@user)
    expect(page).to have_button "delete"

    @user.microposts.paginate(page: 1).each do |micropost|
      expect(page).to have_css "button.button-#{micropost.id}"
    end

    # users/showにあるdeleteボタンからマイクロポストを削除
    first_micropost = @user.microposts.paginate(page: 1).first
    expect(page).to have_css "button.button-#{first_micropost.id}"
    expect {
      page.accept_confirm do
        click_button "delete", match: :first
      end
      expect(page).to have_content "Micropost deleted"
    }.to change(Micropost, :count).by(-1)
    expect(page).to_not have_css "button.button-#{first_micropost.id}"
  end

  scenario "no delete link on the wrong user's profile" do
    log_in_as(other_user)
    visit user_path(@user)
    expect(page).to have_no_button "delete"
  end

  scenario "micropost sidebar count" do
    log_in_as(@user)
    click_link "Home"
    expect(page).to have_selector "span", text: "#{@user.microposts.count} microposts"
    
    # ログアウト
    find(".dropdown-toggle").click
    click_button "Log out"
    expect(page).to have_current_path root_url
    expect(page).to have_link "Log in"

    # まだマイクロポストを投稿していないユーザーでログイン
    log_in_as(other_user)
    click_link "Home"
    expect(page).to have_selector "span", text: "0 microposts"

    # 1件目のマイクロポストを投稿
    fill_in "micropost[content]", with: "A micropost"
    click_button "Post"
    expect(page).to have_selector "span", text: "1 micropost"
  end
end
