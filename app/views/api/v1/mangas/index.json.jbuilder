json.mangas @mangas do |manga|
  json.id         manga.id
  json.title      manga.title
  json.author     manga.author
  json.genre      manga.genre
  json.status     manga.status
  json.rating     manga.rating
  json.cover_url  manga.cover.attached? ? url_for(manga.cover) : nil
  json.created_at manga.created_at
end
