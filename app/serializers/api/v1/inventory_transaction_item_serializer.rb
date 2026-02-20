# frozen_string_literal: true

class Api::V1::InventoryTransactionItemSerializer < ActiveModel::Serializer
  attributes :id, :quantity, :inventory_item

  def inventory_item
    {
      id: object.inventory_item.id,
      name: object.inventory_item.name,
      identifier: object.inventory_item.identifier,
      unit: object.inventory_item.unit,
      type: object.inventory_item.type
    }
  end
end
