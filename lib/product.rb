class Product
  attr_reader :name, :code, :cost_in_cents

  def initialize(name:, code:, cost_in_cents:)
    @name, @code, @cost_in_cents = name, code, cost_in_cents
  end
end
