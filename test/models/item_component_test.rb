require 'test_helper'

class ItemComponentTest < ActiveSupport::TestCase
  test 'valid item_component and associations' do
    product = Product.create!(name: 'P1', identifier: 'p1-#{SecureRandom.hex(4)}', unit: 'pcs')
    label = Label.create!(name: 'L1', identifier: 'l1-#{SecureRandom.hex(4)}', unit: 'pcs')

  ic = ItemComponent.create!(owner: product, component: label, quantity: 2)

  assert_equal product, ic.owner
  assert_equal label, ic.component
  assert_includes product.labels, label
  # unit should be taken from the component
  assert_equal label.unit, ic.unit
  end

  test 'quantity must be non negative' do
    product = Product.create!(name: 'P2', identifier: 'p2-#{SecureRandom.hex(4)}', unit: 'pcs')
    label = Label.create!(name: 'L2', identifier: 'l2-#{SecureRandom.hex(4)}', unit: 'pcs')

  ic = ItemComponent.new(owner: product, component: label, quantity: -1)
    assert_not ic.valid?
    assert_includes ic.errors[:quantity], 'must be greater than or equal to 0'
  end
end
