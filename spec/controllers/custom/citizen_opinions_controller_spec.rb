require "rails_helper"

RSpec.describe CitizenOpinionsController do
  describe "GET #new" do
    before { get :new }
    
    it "returns http success" do  
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { build(:citizen_opinion).attributes }

    let(:invalid_attributes) do
      {
        topic: "",
        body: "",
        email: "invalid-email"
      }
    end

    context "with valid params" do
      it "creates a new citizen opinion and redirects" do
        expect do
          post :create, params: { citizen_opinion: valid_attributes }
        end.to change(CitizenOpinion, :count).by(1)

        expect(response).to redirect_to(new_citizen_opinion_path)
        expect(flash[:notice]).to be_present
      end

      it "sends notification and confirmation emails" do
        notification_mailer = double(deliver_later: true)
        confirmation_mailer = double(deliver_later: true)
        
        expect(CitizenOpinionMailer).to receive(:notification)
          .and_return(notification_mailer)
        expect(CitizenOpinionMailer).to receive(:confirmation)
          .and_return(confirmation_mailer)
        
        post :create, params: { citizen_opinion: valid_attributes }
      end
    end

    context "with invalid params" do
      before { post :create, params: { citizen_opinion: invalid_attributes } }
      
      it "does not create a new citizen opinion" do
        expect do
          post :create, params: { citizen_opinion: invalid_attributes }
        end.not_to change(CitizenOpinion, :count)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not send any emails" do
        expect(CitizenOpinionMailer).not_to receive(:notification)
        expect(CitizenOpinionMailer).not_to receive(:confirmation)
        
        post :create, params: { citizen_opinion: invalid_attributes }
      end
    end
  end
end
