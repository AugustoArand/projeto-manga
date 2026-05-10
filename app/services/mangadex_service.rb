require "net/http"
require "json"
require "uri"

class MangadexService
  BASE_URL = "https://api.mangadex.org".freeze
  COVER_BASE = "https://uploads.mangadex.org/covers".freeze
  CACHE_TTL = 15.minutes

  class << self
    # ── Mangás populares (por followedCount) ──
    def popular(limit: 10)
      Rails.cache.fetch("mangadex:popular:#{limit}", expires_in: CACHE_TTL) do
        params = {
          "limit" => limit,
          "order[followedCount]" => "desc",
          "includes[]" => %w[cover_art author],
          "availableTranslatedLanguage[]" => "pt-br",
          "contentRating[]" => %w[safe suggestive]
        }
        data = get("/manga", params)
        parse_manga_list(data)
      end
    rescue => e
      Rails.logger.error("[MangaDex] popular error: #{e.message}")
      []
    end

    # ── Últimos lançamentos (capítulos recentes) ──
    def latest_chapters(limit: 15, lang: "pt-br")
      Rails.cache.fetch("mangadex:latest:#{limit}:#{lang}", expires_in: CACHE_TTL) do
        params = {
          "limit" => limit,
          "order[publishAt]" => "desc",
          "translatedLanguage[]" => lang,
          "includes[]" => %w[manga scanlation_group]
        }
        data = get("/chapter", params)
        parse_chapter_list(data)
      end
    rescue => e
      Rails.logger.error("[MangaDex] latest_chapters error: #{e.message}")
      []
    end

    # ── Mangás por tag/gênero ──
    def by_tag(tag_ids, limit: 10)
      tag_ids = Array(tag_ids)
      cache_key = "mangadex:by_tag:#{tag_ids.sort.join(',')}:#{limit}"
      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        params = {
          "limit" => limit,
          "order[followedCount]" => "desc",
          "includes[]" => %w[cover_art author],
          "includedTags[]" => tag_ids,
          "contentRating[]" => %w[safe suggestive]
        }
        data = get("/manga", params)
        parse_manga_list(data)
      end
    rescue => e
      Rails.logger.error("[MangaDex] by_tag error: #{e.message}")
      []
    end

    # ── Todas as tags (gêneros/temas) ──
    def tags
      Rails.cache.fetch("mangadex:tags", expires_in: 1.hour) do
        data = get("/manga/tag", {})
        return [] unless data && data["data"]

        data["data"].map do |tag|
          {
            id: tag["id"],
            name: dig_localized(tag.dig("attributes", "name")),
            group: tag.dig("attributes", "group"),
            description: dig_localized(tag.dig("attributes", "description"))
          }
        end.sort_by { |t| t[:name].to_s }
      end
    rescue => e
      Rails.logger.error("[MangaDex] tags error: #{e.message}")
      []
    end

    # ── Tags filtradas só de genre ──
    def genre_tags
      tags.select { |t| t[:group] == "genre" }
    end

    # ── Tags filtradas só de theme ──
    def theme_tags
      tags.select { |t| t[:group] == "theme" }
    end

    # ── Detalhes de um mangá ──
    def manga_detail(manga_id)
      Rails.cache.fetch("mangadex:manga:#{manga_id}", expires_in: CACHE_TTL) do
        params = { "includes[]" => %w[cover_art author artist] }
        data = get("/manga/#{manga_id}", params)
        return nil unless data && data["data"]

        parse_manga(data["data"])
      end
    rescue => e
      Rails.logger.error("[MangaDex] manga_detail error: #{e.message}")
      nil
    end

    # ── URL da capa ──
    def cover_url(manga_id, cover_filename, size: "512")
      return nil unless cover_filename.present?
      "#{COVER_BASE}/#{manga_id}/#{cover_filename}.#{size}.jpg"
    end

    # ── Recomendações baseadas nos gêneros do histórico ──
    def recommendations(limit: 10)
      top_genres = ReadingHistory.top_genres(3)
      return popular(limit: limit) if top_genres.empty?

      # Buscar tag IDs que correspondem aos gêneros do histórico
      all_tags = tags
      matching_tag_ids = all_tags.select { |t|
        top_genres.any? { |g| t[:name]&.downcase&.include?(g.downcase) }
      }.map { |t| t[:id] }

      return popular(limit: limit) if matching_tag_ids.empty?

      by_tag(matching_tag_ids.first(3), limit: limit)
    rescue => e
      Rails.logger.error("[MangaDex] recommendations error: #{e.message}")
      popular(limit: limit)
    end

    private

    def get(path, params)
      uri = URI("#{BASE_URL}#{path}")
      # Build query string handling arrays properly
      query_parts = []
      params.each do |key, value|
        if value.is_a?(Array)
          value.each { |v| query_parts << "#{CGI.escape(key)}=#{CGI.escape(v.to_s)}" }
        else
          query_parts << "#{CGI.escape(key)}=#{CGI.escape(value.to_s)}"
        end
      end
      uri.query = query_parts.join("&") unless query_parts.empty?

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "MangaVerse/1.0"
      request["Accept"] = "application/json"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
        http.request(request)
      end

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        Rails.logger.warn("[MangaDex] HTTP #{response.code}: #{response.message} for #{path}")
        nil
      end
    end

    def parse_manga_list(data)
      return [] unless data && data["data"]
      data["data"].map { |m| parse_manga(m) }.compact
    end

    def parse_manga(manga_data)
      attrs = manga_data["attributes"] || {}
      relationships = manga_data["relationships"] || []

      # Find cover art
      cover_rel = relationships.find { |r| r["type"] == "cover_art" }
      cover_filename = cover_rel&.dig("attributes", "fileName")

      # Find author
      author_rel = relationships.find { |r| r["type"] == "author" }
      author_name = author_rel&.dig("attributes", "name")

      # Extract manga_id from relationships for cover URL
      manga_id = manga_data["id"]

      {
        id: manga_id,
        title: dig_localized(attrs["title"]),
        alt_titles: (attrs["altTitles"] || []).map { |t| dig_localized(t) }.compact,
        description: dig_localized(attrs["description"]),
        status: attrs["status"],
        year: attrs["year"],
        content_rating: attrs["contentRating"],
        tags: (attrs["tags"] || []).map { |t| dig_localized(t.dig("attributes", "name")) }.compact,
        author: author_name,
        cover_url: cover_url(manga_id, cover_filename),
        cover_filename: cover_filename,
        last_chapter: attrs["lastChapter"],
        last_volume: attrs["lastVolume"]
      }
    end

    def parse_chapter_list(data)
      return [] unless data && data["data"]

      data["data"].map do |ch|
        attrs = ch["attributes"] || {}
        relationships = ch["relationships"] || []

        manga_rel = relationships.find { |r| r["type"] == "manga" }
        group_rel = relationships.find { |r| r["type"] == "scanlation_group" }

        manga_id = manga_rel&.dig("id")
        manga_title = dig_localized(manga_rel&.dig("attributes", "title")) if manga_rel&.dig("attributes")

        {
          id: ch["id"],
          chapter: attrs["chapter"],
          title: attrs["title"],
          volume: attrs["volume"],
          pages: attrs["pages"],
          published_at: attrs["publishAt"],
          language: attrs["translatedLanguage"],
          manga_id: manga_id,
          manga_title: manga_title,
          group_name: group_rel&.dig("attributes", "name")
        }
      end.compact
    end

    def dig_localized(hash)
      return nil unless hash.is_a?(Hash)
      hash["pt-br"] || hash["pt"] || hash["en"] || hash["ja-ro"] || hash.values.first
    end
  end
end
