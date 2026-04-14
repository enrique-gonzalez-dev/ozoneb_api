class Api::V1::RawMaterialSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment, :components, :inventory

  # Return components with their referenced object and quantity/unit
  def components
    ItemComponent.where(owner_id: object.id, owner_type: object.class.to_s).map do |ic|
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

  # Return inventory_item_branches filtered by user's branches_to_show
  def inventory
    branches_to_show = instance_options[:branches_to_show] || []
    return [] if branches_to_show.empty?

    object.inventory_item_branches.select { |iib| branches_to_show.include?(iib.branch_id) }.map do |iib|
      {
        id: iib.id,
        branch_id: iib.branch_id,
        branch_name: iib.branch.name,
        stock: iib.stock,
        safe_stock: iib.safe_stock,
        time_to_warning: iib.time_to_warning,
        entry: iib.entry,
        output: iib.output
      }
    end
  end
end
