class Api::V1::ProductBaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment, :components

  # Return composition for ProductBase: item_components with nested component payload
  def components
    object.item_components.map do |ic|
      comp = ic.component
      component_payload = if comp
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
        unit: ic.unit
      }
    end
  end
end
