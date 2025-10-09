class CitizenOpinionsController < ApplicationController
  skip_authorization_check
  
  def new
    @citizen_opinion = CitizenOpinion.new
  end

  def create
    @citizen_opinion = CitizenOpinion.new(citizen_opinion_params)
    
    if @citizen_opinion.save
      CitizenOpinionMailer.notification(@citizen_opinion).deliver_later
      CitizenOpinionMailer.confirmation(@citizen_opinion).deliver_later
      flash[:notice] = t("citizen_opinions.success.title")
      redirect_to new_citizen_opinion_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def citizen_opinion_params
    params.require(:citizen_opinion).permit(
      :topic, 
      :name,
      :phone, 
      :subject,
      :body,
      :email
    )
  end
end
