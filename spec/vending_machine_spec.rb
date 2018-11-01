RSpec.describe VendingMachine do
  let(:product_provider) { double "product provider" }
  let(:change_provider) { double "change provider" }

  let(:chips) { Product.new name: "chips", code: "A1", cost_in_cents: 150 }
  let(:candy) { Product.new name: "candy", code: "B2", cost_in_cents: 75 }

  def build(product_counts={ chips => 2, candy => 2 })
    described_class.new product_counts: product_counts,
                        product_provider: product_provider,
                        change_provider: change_provider
  end

  before do
    allow(product_provider).to receive(:call)
    allow(change_provider).to receive(:call)
  end

  describe "#available_products" do
    it "returns the list of products that are available" do
      expect(build(chips => 1, candy => 0).available_products).to eq([chips])
    end

    it "returns an empty list when there are no products available" do
      expect(build(candy => 0).available_products).to be_empty
    end
  end

  describe "#restock" do
    it "adds non-previously-existing products to the available product list" do
      machine = build({})
      machine.restock(chips => 2)

      expect(machine.available_products).to eq([chips])
    end

    it "increments the available count for an existing product" do
      machine = build(chips => 1, candy => 0)
      machine.restock(candy => 1)

      expect(machine.available_products).to eq([chips, candy])
    end
  end

  describe "#dispense_product" do
    let(:initial_balance) { 500 }
    let(:machine) do
      build(chips => 4, candy => 2).tap do |machine|
        machine.add_funds initial_balance
      end
    end

    it "dispenses product if product and funds are available" do
      expect(product_provider).to receive(:call).with(chips)

      machine.dispense_product chips.code
    end

    it "deducts the cost of the dispensed product" do
      expect(change_provider).
        to receive(:call).
        with(initial_balance - candy.cost_in_cents)

      machine.dispense_product candy.code
    end

    it "won't dispense out-of-stock products" do
      2.times { machine.dispense_product candy.code }

      expect(product_provider).to receive(:call).never

      machine.dispense_product candy.code
    end

    it "gives an error when attempting to dispense an out-of-stock product" do
      3.times {
        machine.dispense_product candy.code
        machine.add_funds candy.cost_in_cents
      }

      expect(machine.error_code).to eq(:product_unavailable)
    end

    it "won't dispense when there aren't enough funds" do
      3.times { machine.dispense_product chips.code }

      expect {|block| machine.dispense_product chips.code, &block }.
        to_not yield_control
    end

    it "gives an error code when there aren't enough funds" do
      4.times { machine.dispense_product chips.code }

      expect(machine.error_code).to eq(:insufficient_funds)
    end
  end

  describe "#dispense_change" do
    let(:machine) { build }

    it "dispenses the current balance" do
      machine.add_funds 75

      expect(change_provider).to receive(:call).with(75)

      machine.dispense_change
    end
  end

  describe "#add_funds" do
    let(:machine) { build chips => 1}

    it "adds funds to the current balance" do
      machine.add_funds 75
      machine.add_funds 75

      machine.dispense_product chips.code

      expect(machine.error_code).to be_nil
    end
  end
end
