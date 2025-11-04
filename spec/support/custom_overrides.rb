# frozen_string_literal: true

# This file ensures custom overrides are loaded after the base definitions
# It re-loads custom files to override methods defined in common_actions.rb
# Using 'load' instead of 'require' to force re-execution even if already loaded
Dir["./spec/support/common_actions/custom/*.rb"].each { |f| load f }
