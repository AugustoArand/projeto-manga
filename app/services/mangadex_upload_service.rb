require "securerandom"

# Manages the MangaDex chapter upload session lifecycle.
# All methods require a valid Bearer token from MangadexAuthService.
#
# Flow:
#   1. active_session? — verify no open session (returns session or nil)
#   2. begin_session   — start session with manga_id + group_ids
#   3. add_pages       — upload image files (up to 10 per call, 500 per session)
#   4. delete_page     — remove a specific page by file_id (optional)
#   5. commit          — finalize with chapter metadata + ordered page_ids
class MangadexUploadService
  ALLOWED_TYPES   = %w[image/jpeg image/png image/gif].freeze
  MAX_FILE_SIZE   = 20.megabytes
  MAX_PER_REQUEST = 10
  MAX_PER_SESSION = 500

  UploadError = Class.new(StandardError)

  def initialize(token)
    @token = token
  end

  # Returns existing session data or nil if none is active.
  def active_session
    result = MangadexService.send(:get, "/upload", {}, token: @token)
    return nil if result.nil? || result["error"]
    result["data"]
  end

  # Creates a new upload session.
  # manga_id  — UUID of the manga
  # group_ids — Array of scanlation group UUIDs (can be empty)
  def begin_session(manga_id, group_ids = [])
    result = MangadexService.send(:post, "/upload/begin",
      { manga: manga_id, groups: group_ids },
      token: @token
    )
    raise UploadError, extract_error(result) if error?(result)
    result.dig("data", "id")
  end

  # Upload image files to an existing session.
  # files — Array of ActionDispatch::Http::UploadedFile (from multipart form)
  # Returns array of uploaded file IDs for use in commit page_order.
  def add_pages(session_id, files)
    raise UploadError, "Too many files (max #{MAX_PER_REQUEST} per request)" if files.size > MAX_PER_REQUEST

    files.each do |f|
      raise UploadError, "#{f.original_filename}: unsupported format" unless ALLOWED_TYPES.include?(f.content_type)
      raise UploadError, "#{f.original_filename}: exceeds 20 MB limit"  if f.size > MAX_FILE_SIZE
    end

    payload = files.map do |f|
      { name: f.original_filename, data: f.read, content_type: f.content_type }
    end

    result = MangadexService.send(:post_multipart, "/upload/#{session_id}", payload, token: @token)
    raise UploadError, extract_error(result) if error?(result)

    (result["data"] || []).map { |item| item["id"] }
  end

  # Remove a specific page from the session before committing.
  def delete_page(session_id, file_id)
    result = MangadexService.send(:delete, "/upload/#{session_id}/#{file_id}", token: @token)
    raise UploadError, extract_error(result) if error?(result)
    true
  end

  # Finalize and publish the chapter.
  # chapter_draft — { volume:, chapter:, title:, translated_language: }
  # page_order    — Array of file_ids in reading order
  def commit(session_id, chapter_draft, page_order)
    body = {
      chapterDraft: {
        volume:            chapter_draft[:volume],
        chapter:           chapter_draft[:chapter],
        title:             chapter_draft[:title],
        translatedLanguage: chapter_draft[:translated_language] || "pt-br"
      },
      pageOrder: page_order
    }
    result = MangadexService.send(:post, "/upload/#{session_id}/commit", body, token: @token)
    raise UploadError, extract_error(result) if error?(result)
    result.dig("data", "id")  # returns the new chapter UUID
  end

  # Abandon an open session without publishing.
  def abandon_session(session_id)
    MangadexService.send(:delete, "/upload/#{session_id}", token: @token)
  end

  private

  def error?(result)
    result.nil? || result["error"].present? || result["result"] == "error"
  end

  def extract_error(result)
    return "Request failed" if result.nil?
    errors = result.dig("errors")
    return errors.map { |e| e["detail"] }.join(", ") if errors.is_a?(Array) && errors.any?
    result["error"] || result["message"] || "Upload error"
  end
end
