module Api
  module V1
    class UploadController < BaseController
      before_action :require_token
      before_action :upload_service

      def session
        data = @svc.active_session
        if data
          render json: { active: true, session: data }
        else
          render json: { active: false }
        end
      end

      def begin
        manga_id  = params.require(:manga_id)
        group_ids = Array(params[:group_ids])
        session_id = @svc.begin_session(manga_id, group_ids)
        render json: { session_id: session_id }, status: :created
      rescue MangadexUploadService::UploadError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def add_pages
        files = params[:files]
        return render json: { error: "No files provided" }, status: :bad_request if files.blank?

        file_ids = @svc.add_pages(params[:session_id], Array(files))
        render json: { file_ids: file_ids }, status: :created
      rescue MangadexUploadService::UploadError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def delete_page
        @svc.delete_page(params[:session_id], params[:file_id])
        render json: { deleted: true }
      rescue MangadexUploadService::UploadError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def commit
        draft = {
          volume:             params[:volume],
          chapter:            params.require(:chapter),
          title:              params[:title],
          translated_language: params.fetch(:translated_language, "pt-br")
        }
        page_order = params.require(:page_order)

        chapter_id = @svc.commit(params[:session_id], draft, page_order)
        render json: { chapter_id: chapter_id }, status: :created
      rescue MangadexUploadService::UploadError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def abandon
        @svc.abandon_session(params[:session_id])
        render json: { abandoned: true }
      end

      private

      def require_token
        @token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        render json: { error: "Authorization token required" }, status: :unauthorized if @token.blank?
      end

      def upload_service
        @svc = MangadexUploadService.new(@token)
      end
    end
  end
end
