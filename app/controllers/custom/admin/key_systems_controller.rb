class Admin::KeySystemsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @mail_status = check_mail_system
    @delayed_job_status = check_delayed_job_status
    @background_jobs = background_jobs
    @background_job_stats = background_job_stats(@background_jobs)
    @background_jobs.each do |job|
      job.handler = format_handler(job)
    end
    @delayed_job_logs = fetch_delayed_job_logs
    @recent_errors = fetch_recent_job_errors
  end

  private

    def check_mail_system
      if ActionMailer::Base.perform_deliveries
        { status: "operational",
          message: t("admin.key_systems.index.mail_system.operational"),
          icon: "icon-checkmark-circle" }
      else
        { status: "down",
          message: t("admin.key_systems.index.mail_system.down"),
          icon: "icon-x" }
      end
    rescue StandardError => e
      { status: "error",
        message: t("admin.key_systems.index.mail_system.error", error: e.message),
        icon: "icon-minus-square" }
    end

    def check_delayed_job_status
      test_job = Delayed::Job.enqueue(Delayed::PerformableMethod.new(TestJob.new, :perform, []))
      if test_job.persisted?
        status = { status: "operational",
                   message: t("admin.key_systems.index.background_job_system.operational"),
                   icon: "icon-checkmark-circle" }
      else
        status = { status: "down",
                   message: t("admin.key_systems.index.background_job_system.down"),
                   icon: "icon-x" }
      end
      Delayed::Job.find_by("handler ILIKE ?", "%TestJob%")&.destroy!
      status
    rescue StandardError => e
      { status: "error",
        message: t("admin.key_systems.index.background_job_system.error", error: e.message),
        icon: "icon-minus-square" }
    end

    def fetch_delayed_job_logs
      log_file_path = Rails.root.join("log", "delayed_job.log")
      logs = []

      if File.exist?(log_file_path)
        logs = File.readlines(log_file_path).reverse
      else
        logs << t("admin.key_systems.index.background_job_system.log_file_not_found")
      end

      logs
    rescue StandardError => e
      [t("admin.key_systems.index.background_job_system.log_file_not_found", error: e.message)]
    end

    def fetch_recent_job_errors
      log_file_path = Rails.root.join("log", "delayed_job.log")
      errors = []

      if File.exist?(log_file_path)
        File.readlines(log_file_path).reverse_each do |line|
          break if errors.size >= 5

          errors << line.strip if line.include?("ERROR")
        end
      else
        errors << t("admin.key_systems.index.background_job_system.log_file_not_found")
      end

      errors
    rescue StandardError => e
      [t("admin.key_systems.index.background_job_system.log_file_not_found", error: e.message)]
    end

    def format_handler(job)
      require "yaml"

      permitted_classes = [Symbol, Hash, Array, String, Mailer, Delayed::PerformableMailer,
                           Delayed::PerformableMethod, TestJob]

      handler_data = YAML.safe_load(job.handler, permitted_classes: permitted_classes)

      if handler_data&.is_a?(Object) && handler_data&.object && handler_data&.object&.to_s == "Mailer"
        object = handler_data.object
        method_name = handler_data.method_name
        email = handler_data.args&.first
        "#{object}: #{email}, Método: #{method_name}"
      else
        handler_data.class.to_s
      end
    end

    def background_jobs
      Delayed::Job.all
    end

    def background_job_stats(jobs)
      {
        all_delayed_jobs: jobs.count,
        failed_jobs: jobs.where.not(failed_at: nil).count,
        pending_jobs: jobs.where(failed_at: nil, locked_at: nil).count
      }
    end
end
