class Api::V1::InventoryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor
  before_action :set_inventory_item, only: [:update, :destroy]

  # POST /api/v1/inventory_items
  def create
    # Force type from routing defaults when provided to avoid clients creating arbitrary types
    attrs = inventory_item_params.to_h
    attrs[:type] = params[:type] if params[:type].present?
    item = InventoryItem.new(attrs)
    assign_categories(item) if attrs[:type] == 'Product' && attrs[:category_ids].present?

    begin
      InventoryItem.transaction do
        item.save!
        # attach components atomically if provided
        if params.dig(:inventory_item, :components).present?
          item.replace_components(params[:inventory_item][:components])
        end
      end
      render json: item, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/inventory_items/:id
  def update
    # Prevent changing `type` on update. If route provides `type`, ensure it matches existing record.
    if params[:type].present? && @inventory_item.type != params[:type]
      return render json: { error: 'Type mismatch' }, status: :unprocessable_entity
    end

    assign_categories(@inventory_item) if @inventory_item.type == 'Product'

    begin
      InventoryItem.transaction do
        # components is handled separately by `process_components` below
        permitted = inventory_item_params.except(:type, :components, :inventory)
        @inventory_item.update!(permitted)
        # replace components atomically if provided
        if params.dig(:inventory_item, :components).present?
          @inventory_item.replace_components(params[:inventory_item][:components])
        end
        # update inventory_item_branch data if provided
        if params.dig(:inventory_item, :inventory).present?
          update_inventory_item_branches
        end
      end
      render json: @inventory_item
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: 'Branch not found' }, status: :not_found
    end
  end

  # DELETE /api/v1/inventory_items/:id
  def destroy
    begin
      InventoryItem.transaction do
        # remove join rows directly to avoid callbacks/NULLs that violate DB constraints
        # Delete any join rows that reference this item (either as owner or as component).
        # Some rows in older data may have inconsistent polymorphic type values
        # (e.g. 'InventoryItem' instead of the concrete subclass). Delete by id only
        # to ensure no leftover rows cause callbacks that try to nullify columns.
        ItemComponent.where(owner_id: @inventory_item.id).delete_all
        ItemComponent.where(component_id: @inventory_item.id).delete_all
        @inventory_item.destroy!
      end
      render json: { message: 'InventoryItem deleted successfully' }, status: :ok
    rescue ActiveRecord::RecordNotDestroyed => e
      render json: { errors: e.record ? e.record.errors.full_messages : [e.message] }, status: :unprocessable_entity
    rescue => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def set_inventory_item
    @inventory_item = InventoryItem.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'InventoryItem not found' }, status: :not_found
  end

  def assign_categories(item)
    category_ids = inventory_item_params[:category_ids] || []
    categories = Category.where(id: category_ids)
    item.categories = categories
  end

  def update_inventory_item_branches
    inventory_data = params[:inventory_item][:inventory]
    inventory_array = Array(inventory_data)

    inventory_array.each do |inv_params|
      branch_id = inv_params[:branch] || inv_params['branch']
      next unless branch_id.present?

      branch = Branch.find(branch_id)
      inventory_item_branch = @inventory_item.inventory_item_branches.find_or_initialize_by(branch: branch)

      branch_params = {}
      branch_params[:stock] = inv_params[:stock] || inv_params['stock'] if (inv_params[:stock] || inv_params['stock']).present?
      branch_params[:safe_stock] = inv_params[:safe_stock] || inv_params['safe_stock'] if (inv_params[:safe_stock] || inv_params['safe_stock']).present?
      branch_params[:time_to_warning] = inv_params[:time_to_warning] || inv_params['time_to_warning'] if (inv_params[:time_to_warning] || inv_params['time_to_warning']).present?
      branch_params[:entry] = inv_params[:entry] || inv_params['entry'] if (inv_params[:entry] || inv_params['entry']).present?
      branch_params[:output] = inv_params[:output] || inv_params['output'] if (inv_params[:output] || inv_params['output']).present?

      inventory_item_branch.update!(branch_params) if branch_params.any?
    end
  end

  # Permit typical inventory item attributes. Include `type` to support STI
  # subclasses (Product, Label, ProductBase, Container, RawMaterial) when needed.
  def inventory_item_params
    params.require(:inventory_item).permit(
      :name, :identifier, :unit, :quantity, :location, :price, :sku, :description, :type,
      category_ids: [],
      components: [:id, :quantity],
      inventory: [[:branch, :stock, :safe_stock, :time_to_warning, :entry, :output]]
    )
  end

  # Components management delegated to InventoryItem#replace_components
end
