require "simplecov"

ENV["RAILS_ENV"] ||= "test"

if ENV["TEST_COVERAGE"] && !ENV["TEST_COVERAGE"].empty?
  SimpleCov.start "rails" do
    enable_coverage :branch

    add_filter "/spec/"
    add_filter "/config/"
    add_filter "/vendor/"

    add_group "Controllers", "app/controllers"
    add_group "Models", "app/models"
    add_group "Helpers", "app/helpers"
    add_group "Libraries", "lib"

    if ENV["TEST_ENV_NUMBER"]
      coverage_dir "coverage/#{ENV["TEST_ENV_NUMBER"]}"
    end

    use_merging true
    merge_timeout 3600

    SimpleCov.at_exit do
      SimpleCov.result.format! if ParallelTests.number_of_running_processes <= 1

      SimpleCov.collate Dir["coverage/.resultset*.json"], "rails" do
        SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
      end
    end
  end
end

RSpec.configure do |config|
  # Add the :consul tag to tests which make sense in the original
  # version of CONSUL DEMOCRACY but don"t make sense in your application
  # due to the custom changes you"ve implemented.
  #
  # Using this tag will help maintaining the test suite when doing custom
  # changes and when upgrading to a newer version of CONSUL DEMOCRACY
  config.filter_run_excluding consul: true
  config.example_status_persistence_file_path = "tmp/examples.txt"
  config.silence_filter_announcements = true if ENV["TEST_ENV_NUMBER"]

  if ENV["TEST_ENV_NUMBER"]
    config.around do |example|
      example.run
    ensure
      if ENV["TEST_COVERAGE"]
        SimpleCov.result.format!
      end
    end
  end

  Capybara.server_port = 9887 + ENV["TEST_ENV_NUMBER"].to_i if ENV["TEST_ENV_NUMBER"]
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
