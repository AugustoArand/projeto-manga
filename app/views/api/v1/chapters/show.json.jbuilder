json.id           @chapter.id
json.number       @chapter.number
json.title        @chapter.title
json.published_at @chapter.published_at
json.manga_id     @manga.id
json.manga_title  @manga.title

json.pages @pages do |page|
  json.id        page.id
  json.number    page.number
  json.image_url page.image.attached? ? url_for(page.image) : nil
end

json.next_chapter_id @next&.id
json.prev_chapter_id @prev&.id
