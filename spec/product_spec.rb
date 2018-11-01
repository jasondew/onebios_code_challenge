RSpec.describe Product do
  it "stores a name, code, and cost in cents" do
    product = described_class.new(name: "Chips", code: "A1", cost_in_cents: 150)

    expect(product.name).to eq("Chips")
    expect(product.code).to eq("A1")
    expect(product.cost_in_cents).to eq(150)
  end
end
