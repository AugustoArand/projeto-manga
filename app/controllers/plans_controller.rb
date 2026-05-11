class PlansController < ApplicationController
  def show
    @plans = [
      { id: :mensal,  label: "Mensal",  price: "14,90", period: "/mês",   note: nil,            tag: nil,             popular: false },
      { id: :anual,   label: "Anual",   price: "9,90",  period: "/mês",   note: "economize 33%", tag: "mais escolhido", popular: true  },
      { id: :vitalicio, label: "Vitalício", price: "299", period: "",     note: "pague uma vez", tag: nil,             popular: false }
    ]
  end
end
