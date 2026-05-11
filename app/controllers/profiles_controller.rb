class ProfilesController < ApplicationController
  def show
    @user = {
      name: "Kira Yamada",
      handle: "@kira_88",
      initials: "K",
      vip: true,
      member_since: "2024",
      level: 12,
      next_level: 13,
      xp_current: 2840,
      xp_needed: 4000,
      badge: "collector"
    }

    @stats = {
      favoritos: ReadingHistory.count,
      concluidos: 23,
      concluidos_mes: 3,
      paginas: 12847
    }

    @recent_covers = ReadingHistory.order(updated_at: :desc).first(5)
  end
end
