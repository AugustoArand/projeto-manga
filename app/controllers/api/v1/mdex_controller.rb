module Api
  module V1
    # Proxy endpoints for MangaDex content (manga detail + chapter reading).
    # These are read-only and do not require authentication.
    class MdexController < BaseController
      # GET /api/v1/mdex/manga/:id
      # Returns manga detail + paginated chapter list from MangaDex.
      def manga
        manga = MangadexService.manga_detail(params[:id])
        return render json: { error: "Manga not found" }, status: :not_found unless manga

        lang   = params.fetch(:lang, "pt-br")
        offset = params.fetch(:offset, 0).to_i
        chapters = MangadexService.manga_chapters(params[:id], lang: lang, offset: offset)

        render json: {
          id:           manga[:id],
          title:        manga[:title],
          description:  manga[:description],
          status:       manga[:status],
          year:         manga[:year],
          author:       manga[:author],
          cover_url:    manga[:cover_url],
          tags:         manga[:tags],
          last_chapter: manga[:last_chapter],
          chapters:     chapters.map { |ch|
            {
              id:        ch[:id],
              chapter:   ch[:chapter],
              title:     ch[:title],
              volume:    ch[:volume],
              pages:     ch[:pages],
              published: ch[:published],
              lang:      ch[:lang],
              group:     ch[:group]
            }
          }
        }
      end

      # GET /api/v1/mdex/search?query=...
      def search
        query   = params[:query].to_s.strip
        results = MangadexService.search(query)
        render json: { mangas: results }
      end

      # GET /api/v1/mdex/chapter/:id
      # Returns ordered page image URLs for a MangaDex chapter.
      # Accepts ?data_saver=true for compressed images.
      def chapter
        data_saver = params[:data_saver] == "true"
        result     = MangadexService.chapter_pages(params[:id], data_saver: data_saver)

        return render json: { error: "Chapter not found" }, status: :not_found unless result

        render json: {
          chapter_id: result[:chapter_id],
          pages:      result[:pages]
        }
      end
    end
  end
end
