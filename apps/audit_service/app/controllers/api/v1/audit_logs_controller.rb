module Api
  module V1
    class AuditLogsController < ApplicationController
      include Authenticable

      # GET /api/v1/audit_logs?page=1&per_page=20
      skip_before_action :authenticate_request!, only: [:create]

      # POST /api/v1/audit_logs
      def create
        log = AuditLog.new(params.permit(:action, :entity, :entity_id, :performed_by, :ip_address, :status))
        
        # Permit dynamic details hash
        log.details = params[:details].permit!.to_h if params[:details].present?

        if log.save
          render json: { data: log }, status: :created
        else
          render json: { errors: log.errors.full_messages }, status: :unprocessable_content
        end
      end

      # GET /api/v1/audit_logs?page=1&per_page=20
      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 20

        # Limit per_page to max 100 to prevent abuse
        per_page = [per_page.to_i, 100].min

        # Get paginated logs, sorted by most recent first
        logs = AuditLog.desc(:created_at)
                       .skip((page.to_i - 1) * per_page)
                       .limit(per_page)

        total_count = AuditLog.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          data: logs,
          meta: {
            current_page: page.to_i,
            per_page: per_page.to_i,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      # GET /api/v1/audit_logs/:id
      def show
        log = AuditLog.find(params[:id])
        render json: { data: log }, status: :ok
      rescue Mongoid::Errors::DocumentNotFound
        render json: { error: 'Audit log not found' }, status: :not_found
      end

      # GET /api/v1/audit_logs/by_entity?entity=Client&entity_id=1
      def by_entity
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        per_page = [per_page.to_i, 100].min

        query = AuditLog.where(entity: params[:entity])

        if params[:entity_id].present?
          eid = params[:entity_id]
          # Search in root entity_id OR inside details.id (handling string/int types)
          query = query.any_of(
            { entity_id: eid },
            { 'details.id' => eid },
            { 'details.id' => eid.to_i }
          )
        end

        logs = query.desc(:created_at)
                    .skip((page.to_i - 1) * per_page)
                    .limit(per_page)

        total_count = query.count
        total_pages = (total_count.to_f / per_page).ceil

        render json: {
          data: logs,
          meta: {
            current_page: page.to_i,
            per_page: per_page.to_i,
            total_count: total_count,
            total_pages: total_pages,
            filters: {
              entity: params[:entity],
              entity_id: params[:entity_id]
            }
          }
        }
      end
    end
  end
end
