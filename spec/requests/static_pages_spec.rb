require 'rails_helper'

RSpec.describe "StaticPages", type: :request do

  before do
    @base_title = "Micropost App with Rails7"
  end

  describe "GET / (home)" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
      assert_select "title", @base_title
    end
  end

  describe "GET /help" do
    it "returns http success" do
      get help_path
      expect(response).to have_http_status(:success)
      assert_select "title", text: "Help | #{@base_title }"
    end
  end

  describe "GET /about" do
    it "returns http success" do
      get about_path
      expect(response).to have_http_status(:success)
      assert_select "title", text: "About | #{@base_title }"
    end
  end

  describe "GET /contact" do
    it "returns http success" do
      get contact_path
      expect(response).to have_http_status(:success)
      assert_select "title", text: "Contact | #{@base_title }"
    end
  end
end
