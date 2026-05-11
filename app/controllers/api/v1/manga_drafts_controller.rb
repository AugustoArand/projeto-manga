module Api
  module V1
    class MangaDraftsController < BaseController
      before_action :require_token
      before_action :manga_service

      def index
        drafts = @svc.list_drafts
        render json: drafts
      end

      def create
        attrs = {
          title:             params.require(:title),
          alt_titles:        params[:alt_titles] || [],
          description:       params[:description],
          original_language: params.fetch(:original_language, "ja"),
          status:            params.fetch(:status, "ongoing"),
          year:              params[:year]&.to_i,
          content_rating:    params.fetch(:content_rating, "safe"),
          tags:              Array(params[:tags])
        }
        draft = @svc.create_draft(attrs)
        render json: draft, status: :created
      rescue MangadexMangaService::MangaError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def upload_cover
        file = params.require(:cover)
        unless file.respond_to?(:content_type)
          return render json: { error: "Invalid file" }, status: :bad_request
        end
        cover = @svc.upload_cover(params[:id], file, volume: params[:volume])
        render json: cover, status: :created
      rescue MangadexMangaService::MangaError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def submit
        result = @svc.submit_draft(params[:id], params.require(:version).to_i)
        render json: result
      rescue MangadexMangaService::MangaError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def require_token
        @token = request.headers["Authorization"]&.delete_prefix("Bearer ")
        render json: { error: "Authorization token required" }, status: :unauthorized if @token.blank?
      end

      def manga_service
        @svc = MangadexMangaService.new(@token)
      end
    end
  end
end
