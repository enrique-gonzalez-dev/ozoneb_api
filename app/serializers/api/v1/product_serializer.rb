class Api::V1::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type, :categories, :components

  def categories
    object.categories.map do |category|
      {
        id: category.id,
        name: category.name
      }
    end
  end

  # Return components with their referenced object and quantity/unit
  # Expected shape: [{ item_component_id, component_type, component_id, component: { id, name, identifier, unit, type }, quantity, unit }]
  def components
    object.item_components.map do |ic|
      comp = ic.component
      component_payload = if comp
        # Choose a serializer dynamically based on component_type; fall back to compact InventoryItemSerializer
        serializer_name = "Api::V1::#{ic.component_type}Serializer"
        serializer_klass = serializer_name.safe_constantize || Api::V1::InventoryItemSerializer
        ActiveModelSerializers::SerializableResource.new(comp, serializer: serializer_klass).as_json
      else
        nil
      end

      {
        item_component_id: ic.id,
        component_type: ic.component_type,
        component_id: ic.component_id,
        component: component_payload,
        quantity: ic.quantity.to_s,
        unit: ic.unit,
        name: ic.component&.name
      }
    end
  end
end
