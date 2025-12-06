# frozen_string_literal: true

# Concern to add automatic logging to ActiveRecord models
#
# Usage:
#   class Invoice < ApplicationRecord
#     include Loggable
#   end
#
# This will automatically log to MongoDB:
# - Record creation
# - Record updates
# - Record deletion
#
module Loggable
  extend ActiveSupport::Concern

  included do
    # Callbacks for automatic logging
    after_create :log_creation
    after_update :log_update
    after_destroy :log_deletion

    # Attribute to store current user
    attr_accessor :current_user

    # Attribute for additional metadata
    attr_accessor :log_metadata
  end

  private

  # Logs record creation
  def log_creation
    ActivityLog.log_create(
      self,
      user: current_user,
      metadata: build_metadata
    )
  rescue StandardError => e
    Rails.logger.error("Error logging creation: #{e.message}")
  end

  # Logs record update
  def log_update
    ActivityLog.log_update(
      self,
      user: current_user,
      metadata: build_metadata
    )
  rescue StandardError => e
    Rails.logger.error("Error logging update: #{e.message}")
  end

  # Logs record deletion
  def log_deletion
    ActivityLog.log_delete(
      self,
      user: current_user,
      metadata: build_metadata
    )
  rescue StandardError => e
    Rails.logger.error("Error logging deletion: #{e.message}")
  end

  # Builds metadata hash for the log
  def build_metadata
    metadata = log_metadata || {}

    # Add request info if available via Current
    if defined?(Current)
      metadata[:request_id] = Current.request_id if Current.respond_to?(:request_id)
      metadata[:user_agent] = Current.user_agent if Current.respond_to?(:user_agent)
      metadata[:ip_address] = Current.ip_address if Current.respond_to?(:ip_address)
    end

    metadata
  end

  # Public methods

  module ClassMethods
    # Get log history for this model
    def activity_logs
      ActivityLog.where(loggable_type: name)
    end

    # Get recent logs for this model
    def recent_activity(limit = 10)
      activity_logs.recent.limit(limit)
    end
  end

  # Get log history for this instance
  def activity_logs
    ActivityLog.history_for(self)
  end

  # Log a custom action
  def log_custom_action(description, metadata: {})
    ActivityLog.log_custom(
      self.class.name,
      id,
      description,
      user: current_user,
      metadata: metadata.merge(build_metadata)
    )
  end
end
