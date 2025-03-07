require "rails_helper"

describe Admin::Legislation::ProposalsController do
  before { sign_in(create(:administrator).user) }

  let(:legislation_process) { create(:legislation_process, end_date: Date.current - 1.day) }

  it "download excel file test" do
    create(:legislation_question, process: legislation_process, title: "Question 1")

    get :summary, params: { process_id: legislation_process, format: :xlsx }

    expect(response).to be_successful
  end
end
