require "product"

class ProductInventory
  attr_reader :product_counts

  def initialize(product_counts={})
    @product_counts = product_counts
  end

  def find_available_product_by_code(code)
    all_available.detect {|product| product.code == code }
  end

  def all_available
    product_counts.select {|product, count| count.nonzero? }.keys
  end

  def available?(product)
    (count = product_counts[product]) and count.nonzero?
  end

  def add(incoming_product_counts)
    product_counts.merge!(incoming_product_counts) do |key, old_value, new_value|
      old_value + new_value
    end
  end

  def remove(product)
    if available?(product)
      product_counts[product] -= 1
    else
      raise "Attempting to remove an unavailable product: #{product}"
    end
  end
end
