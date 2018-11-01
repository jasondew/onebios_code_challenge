require "product_inventory"

class VendingMachine
  attr_reader :product_inventory, :product_provider, :change_provider, :error_code

  def initialize(product_counts: {},
                 product_provider: ->(product) { },
                 change_provider:  ->(cents)   { })
    @product_inventory = ProductInventory.new(product_counts)
    @product_provider = product_provider
    @change_provider = change_provider
    @balance_in_cents = 0
    @error_code = nil
  end

  def available_products
    product_inventory.all_available
  end

  def restock(incoming_product_counts)
    product_inventory.add incoming_product_counts
  end

  def dispense_product(product_code)
    if (product = product_inventory.find_available_product_by_code product_code)
      if funds_available?(product.cost_in_cents)
        conduct_transaction product
      else
        @error_code = :insufficient_funds
      end
    else
      @error_code = :product_unavailable
    end
  end

  def add_funds(cents)
    @balance_in_cents += cents
  end

  def dispense_change
    change_provider.call @balance_in_cents
    @balance_in_cents = 0
  end

  private

  def funds_available?(cents)
    @balance_in_cents >= cents
  end

  def deduct_cost(product)
    @balance_in_cents -= product.cost_in_cents
  end

  def conduct_transaction(product)
    deduct_cost product
    product_inventory.remove product
    product_provider.call product
    dispense_change
  end
end
