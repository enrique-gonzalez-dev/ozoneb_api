class Api::V1::ContainerSerializer < ActiveModel::Serializer
  attributes :id, :name, :identifier, :unit, :type, :comment, :inventory

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
