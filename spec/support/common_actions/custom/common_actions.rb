# frozen_string_literal: true

module CommonActions
  def fill_in_proposal
    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."
    fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
    responsible_name = "Name and surname of the person who makes this proposal"
    fill_in responsible_name, with: "Isabel Garcia" if page.has_field?(responsible_name, wait: 0)
    check "I agree to the Privacy Policy and the Terms and conditions of use"
  end
end
