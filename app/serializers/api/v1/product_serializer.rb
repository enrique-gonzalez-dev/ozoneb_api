class Api::V1::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :comment, :unit, :type, :categories, :components, :inventory

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
