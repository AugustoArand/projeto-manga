json.tag_name @tag_name

json.mangas @mangas do |manga|
  json.id          manga[:id]
  json.title       manga[:title]
  json.cover_url   manga[:cover_url]
  json.status      manga[:status]
  json.tags        manga[:tags]
  json.author      manga[:author]
  json.description manga[:description]
end
