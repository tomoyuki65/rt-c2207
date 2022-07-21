# RSpecのドライバ設定
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :headless_chrome
  end
end

# Docker環境用のドライバ設定を追加
Capybara.register_driver :headless_chrome do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << "--headless"
    opts.args << "--disable-gpu"
    opts.args << "--no-sandbox"
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
