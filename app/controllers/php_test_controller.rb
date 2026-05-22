class PhpTestController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_administrator
  skip_authorization_check

  def censo
    file = params["file"].to_s.gsub(/[^a-zA-Z0-9_\-.]/, "")
    script_path = Rails.root.join("bin", file)

    unless script_path.to_s.start_with?(Rails.root.join("bin").to_s) && File.file?(script_path)
      render plain: "Script no encontrado.", status: :not_found
      return
    end

    @result = `php -f #{Shellwords.escape(script_path.to_s)}`
  end

  private

    def verify_administrator
      unless current_user&.administrator?
        redirect_to root_path, alert: "No tienes permisos para acceder a esta página."
      end
    end
end
