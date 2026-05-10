# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.

require "open-uri"

puts "🌱 Seeding manga database..."

Manga.destroy_all

mangas_data = [
  {
    title: "Demon Slayer",
    author: "Koyoharu Gotouge",
    description: "Tanjiro Kamado, tendo sua família massacrada por um demônio, junta-se aos Pilares para vingar sua família e curar sua irmã transformada em demônio.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/8/8b/Kimetsu_no_Yaiba_volume_1.png",
    genre: "Ação",
    status: "Completo",
    rating: 9.2
  },
  {
    title: "Jujutsu Kaisen",
    author: "Gege Akutami",
    description: "Yuji Itadori, um garoto de ensino médio extraordinariamente apto, se une a uma organização secreta de Feiticeiros de Jujutsu após engolir um dedo maldito.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/5/5b/Jujutsu_Kaisen_volume_1.png",
    genre: "Ação",
    status: "Em andamento",
    rating: 9.0
  },
  {
    title: "One Piece",
    author: "Eiichiro Oda",
    description: "Monkey D. Luffy e seus piratas exploram o Grand Line em busca do tesouro definitivo, o 'One Piece', para se tornar o próximo Rei dos Piratas.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/d/d6/One_Piece_volume_1.png",
    genre: "Aventura",
    status: "Em andamento",
    rating: 9.5
  },
  {
    title: "Attack on Titan",
    author: "Hajime Isayama",
    description: "Eren Yeager e seus amigos de infância lutam pela sobrevivência da humanidade contra gigantescos humanoídeos que devoram pessoas.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/b/bc/Shingeki_no_Kyojin_volume_1.png",
    genre: "Suspense",
    status: "Completo",
    rating: 9.3
  },
  {
    title: "My Hero Academia",
    author: "Kōhei Horikoshi",
    description: "Izuku Midoriya nasce sem habilidades em um mundo onde superpoderes são a norma, mas sonha em se tornar um super-herói de qualquer jeito.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/b/b6/Boku_No_Hero_Academia_volume_1.png",
    genre: "Ação",
    status: "Completo",
    rating: 8.8
  },
  {
    title: "Chainsaw Man",
    author: "Tatsuki Fujimoto",
    description: "Denji tem uma vida miserável até se fundir com seu demônio-motosserra, Pochita, tornando-se o Homem-Motosserra.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/5/5c/Chainsaw_Man_volume_1.png",
    genre: "Ação",
    status: "Em andamento",
    rating: 9.1
  },
  {
    title: "Naruto",
    author: "Masashi Kishimoto",
    description: "Naruto Uzumaki é um jovem ninja que busca reconhecimento dos seus pares e sonha em se tornar o Hokage, o líder da sua vila.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/b/b0/Naruto_vol1_capa.jpg",
    genre: "Aventura",
    status: "Completo",
    rating: 9.0
  },
  {
    title: "Tokyo Ghoul",
    author: "Sui Ishida",
    description: "Ken Kaneki sobrevive a um encontro com um ghoul e acaba se tornando um ser híbrido, forçado a se adaptar à sombria sociedade dos ghouls.",
    cover_url: "https://upload.wikimedia.org/wikipedia/pt/6/6b/Tokyo_Ghoul_volume_1.png",
    genre: "Horror",
    status: "Completo",
    rating: 8.9
  }
]

# Páginas de exemplo (placeholder público)
sample_page_urls = [
  "https://placehold.co/800x1200/1a1a2e/E040FB?text=Pagina+1&font=playfair-display",
  "https://placehold.co/800x1200/1a1a2e/00E5FF?text=Pagina+2&font=playfair-display",
  "https://placehold.co/800x1200/1a1a2e/E040FB?text=Pagina+3&font=playfair-display",
  "https://placehold.co/800x1200/1a1a2e/00E5FF?text=Pagina+4&font=playfair-display",
  "https://placehold.co/800x1200/1a1a2e/E040FB?text=Pagina+5&font=playfair-display"
]

mangas_data.each do |manga_data|
  cover_url = manga_data.delete(:cover_url)
  manga = Manga.create!(manga_data)

  # Anexar capa via Active Storage (baixa da URL remota)
  if cover_url.present?
    begin
      filename = File.basename(URI.parse(cover_url).path)
      downloaded = URI.open(cover_url, "User-Agent" => "Mozilla/5.0 MangaApp/1.0")
      manga.cover.attach(io: downloaded, filename: filename)
      puts "  ✓ Criado: #{manga.title} (capa anexada)"
    rescue => e
      puts "  ✓ Criado: #{manga.title} (capa não disponível: #{e.message})"
    end
  else
    puts "  ✓ Criado: #{manga.title}"
  end

  # Criar 3 capítulos por mangá
  3.times do |chapter_num|
    chapter = manga.chapters.create!(
      number: chapter_num + 1,
      title: [ "O Início", "A Jornada Começa", "Aliados e Inimigos" ][chapter_num],
      published_at: (30 - chapter_num * 7).days.ago
    )

    # 5 páginas por capítulo — anexar imagens via Active Storage
    sample_page_urls.each_with_index do |url, page_num|
      page = chapter.pages.create!(number: page_num + 1)
      begin
        downloaded = URI.open(url, "User-Agent" => "Mozilla/5.0 MangaApp/1.0")
        page.image.attach(io: downloaded, filename: "page_#{page_num + 1}.png", content_type: "image/png")
      rescue => e
        # Página criada sem imagem; o leitor usará o fallback de placeholder
      end
    end
  end
end

puts "\n✅ Seed concluído! #{Manga.count} mangás criados com #{Chapter.count} capítulos e #{Page.count} páginas."
