require "capybara/rspec"
require "selenium/webdriver"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument "--headless"
    opts.add_argument "--no-sandbox"
    opts.add_argument "--disable-dev-shm-usage"
    opts.add_argument "--window-size=1200,800"
  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.configure do |config|
  config.default_driver = :headless_chrome
  config.javascript_driver = :headless_chrome
  config.server = :puma, { Silent: true }
  config.default_max_wait_time = 10
  config.exact = true
  config.enable_aria_label = true
  config.disable_animation = true

  if ENV["TEST_ENV_NUMBER"]
    port = 9887 + ENV["TEST_ENV_NUMBER"].to_i
    config.server_port = port
    config.app_host = "http://127.0.0.1:#{port}"
  else
    config.app_host = "http://127.0.0.1"
  end
end
