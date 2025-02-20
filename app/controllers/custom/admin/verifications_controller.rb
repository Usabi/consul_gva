load Rails.root.join('app', 'controllers', 'admin', 'verifications_controller.rb')

class Admin::VerificationsController
  def request_verification
    failed = false
    User.where(id: params[:user_ids]).each do |user|
      begin
        next unless user.residence_requested?

        now = Time.current
        failed = !user.update(residence_verified_at: now, verified_at: now)
      rescue Exception => e
        STDERR.puts ""
        STDERR.puts "****** ERROR setting residence_verified_at for user #{user.id}"
        STDERR.puts e.message
        STDERR.puts e.backtrace[0..9]
        STDERR.puts "****** /ERROR setting residence_verified_at"
        STDERR.puts ""
        redirect_to admin_users_path(filter: 'residence_requested'), alert: t('admin.verifications.update.flash.error')
        return
      end
    end
    if failed
      redirect_to admin_users_path(filter: 'residence_requested'), alert: t('admin.verifications.update.flash.failure')
    else
      redirect_to admin_users_path(filter: 'residence_requested'), notice: t('admin.verifications.update.flash.success')
    end
  end

end
