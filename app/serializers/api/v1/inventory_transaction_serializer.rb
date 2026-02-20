# frozen_string_literal: true

class Api::V1::InventoryTransactionSerializer < ActiveModel::Serializer
  attributes :id, :transaction_type, :transaction_subtype, :note, :created_at, :updated_at, :user, :branch, :items

  def user
    {
      id: object.user.id,
      name: object.user.name,
      last_name: object.user.last_name,
      email: object.user.email
    }
  end

  def branch
    {
      id: object.branch.id,
      name: object.branch.name,
      address: object.branch.address
    }
  end

  def items
    object.inventory_transaction_items.map do |item|
      Api::V1::InventoryTransactionItemSerializer.new(item).as_json
    end
  end

  def transaction_type
    object.transaction_type
  end

  def transaction_subtype
    object.transaction_subtype
  end
end
