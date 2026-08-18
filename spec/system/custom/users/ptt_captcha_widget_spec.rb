require "rails_helper"

describe "PTT captcha widget (JavaScript)" do
  let(:captcha_id) { "TEST-CAPTCHA-ID-001" }

  let(:stub_front_js_url) do
    script = "window.getCaptchaValue = function() { return 'STUBBED-CAPTCHA-VALUE'; };"
    "data:text/javascript,#{ERB::Util.url_encode(script)}"
  end

  before do
    allow(PttCaptcha.configuration).to receive(:app_id).and_return("TEST-APP")
    allow(PttCaptchaApi).to receive(:create_captcha).and_return(captcha_id)
    allow(PttCaptchaApi).to receive(:front_js_url).and_return(stub_front_js_url)
  end

  scenario "fills the hidden field with the widget value and submits the form" do
    user = create(:user, email: "citizen@consul.org", password: "12345678")
    allow(PttCaptchaApi).to receive(:validate_captcha).with(captcha_id, "STUBBED-CAPTCHA-VALUE").and_return(true)

    visit new_user_session_path

    expect(page).to have_css("[data-captcha-id='#{captcha_id}']", visible: :all)

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password
    click_button "Enter"

    expect(page).to have_content("You have been signed in successfully")
    expect(PttCaptchaApi).to have_received(:validate_captcha).with(captcha_id, "STUBBED-CAPTCHA-VALUE")
  end

  scenario "blocks sign in when the widget value fails validation" do
    user = create(:user, email: "citizen@consul.org", password: "12345678")
    allow(PttCaptchaApi).to receive(:validate_captcha).and_return(false)

    visit new_user_session_path
    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password
    click_button "Enter"

    expect(page).to have_no_content("You have been signed in successfully")
    expect(page).to have_current_path(new_user_session_path)
  end
end
