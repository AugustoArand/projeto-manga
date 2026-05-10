json.id          @manga.id
json.title       @manga.title
json.author      @manga.author
json.description @manga.description
json.genre       @manga.genre
json.status      @manga.status
json.rating      @manga.rating
json.cover_url   @manga.cover.attached? ? url_for(@manga.cover) : nil
json.created_at  @manga.created_at

json.chapters @chapters do |chapter|
  json.id           chapter.id
  json.number       chapter.number
  json.title        chapter.title
  json.published_at chapter.published_at
end
