# Handles manga draft creation and cover upload via MangaDex API.
# All methods require a valid Bearer token.
#
# Note: created manga start as "draft" and require staff approval.
class MangadexMangaService
  COVER_TYPES    = %w[image/jpeg image/png image/gif].freeze
  MAX_COVER_SIZE = 10.megabytes

  MangaError = Class.new(StandardError)

  def initialize(token)
    @token = token
  end

  # Create a manga draft.
  # attrs:
  #   title:              String (pt-br preferred)
  #   alt_titles:         Array of { lang => title } hashes
  #   description:        String
  #   original_language:  "ja" | "ko" | "zh" etc.
  #   status:             "ongoing" | "completed" | "hiatus" | "cancelled"
  #   year:               Integer
  #   content_rating:     "safe" | "suggestive" | "erotica" | "pornographic"
  #   tags:               Array of tag UUIDs
  def create_draft(attrs)
    body = build_manga_body(attrs)
    result = MangadexService.send(:post, "/manga", body, token: @token)
    raise MangaError, extract_error(result) if error?(result)
    result["data"]
  end

  # Upload a cover image for an existing manga.
  # file   — ActionDispatch::Http::UploadedFile
  # volume — String or nil ("1", "2" …)
  def upload_cover(manga_id, file, volume: nil)
    raise MangaError, "Unsupported cover format" unless COVER_TYPES.include?(file.content_type)
    raise MangaError, "Cover exceeds 10 MB limit"  if file.size > MAX_COVER_SIZE

    payload = [{ name: file.original_filename, data: file.read, content_type: file.content_type }]

    # The /cover endpoint also accepts volume as a form field
    result = MangadexService.send(:post_multipart, "/cover/#{manga_id}", payload, token: @token)
    raise MangaError, extract_error(result) if error?(result)
    result["data"]
  end

  # List manga drafts pending submission for the authenticated user.
  def list_drafts
    result = MangadexService.send(:get, "/manga/draft", {
      "includes[]" => %w[author cover_art],
      "limit"      => 20
    }, token: @token)
    return [] if error?(result)
    (result["data"] || [])
  end

  # Submit a draft for staff review.
  def submit_draft(manga_id, version)
    result = MangadexService.send(:post, "/manga/draft/#{manga_id}/commit",
      { version: version },
      token: @token
    )
    raise MangaError, extract_error(result) if error?(result)
    result["data"]
  end

  private

  def build_manga_body(attrs)
    {
      title:            { "pt-br" => attrs[:title] }.compact,
      altTitles:        attrs[:alt_titles] || [],
      description:      { "pt-br" => attrs[:description] }.compact,
      originalLanguage: attrs[:original_language] || "ja",
      status:           attrs[:status] || "ongoing",
      year:             attrs[:year],
      contentRating:    attrs[:content_rating] || "safe",
      tags:             attrs[:tags] || []
    }.compact
  end

  def error?(result)
    result.nil? || result["error"].present? || result["result"] == "error"
  end

  def extract_error(result)
    return "Request failed" if result.nil?
    errors = result.dig("errors")
    return errors.map { |e| e["detail"] }.join(", ") if errors.is_a?(Array) && errors.any?
    result["error"] || result["message"] || "Manga API error"
  end
end
