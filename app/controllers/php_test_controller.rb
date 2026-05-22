class PhpTestController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_administrator
  skip_authorization_check

  def censo
    file = params["file"].to_s.gsub(/[^a-zA-Z0-9_\-.]/, "")
    @result = `php -f bin/#{file}`
  end

  private

    def verify_administrator
      unless current_user&.administrator?
        redirect_to root_path, alert: "No tienes permisos para acceder a esta página."
      end
    end
end
