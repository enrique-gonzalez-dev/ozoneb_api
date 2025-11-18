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
        permitted = inventory_item_params.except(:type, :components)
        @inventory_item.update!(permitted)
        # replace components atomically if provided
        if params.dig(:inventory_item, :components).present?
          @inventory_item.replace_components(params[:inventory_item][:components])
        end
      end
      render json: @inventory_item
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
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

  # Permit typical inventory item attributes. Include `type` to support STI
  # subclasses (Product, Label, ProductBase, Container, RawMaterial) when needed.
  def inventory_item_params
    params.require(:inventory_item).permit(:name, :identifier, :unit, :quantity, :location, :price, :sku, :description, :type, category_ids: [], components: [:id, :quantity])
  end

  # Components management delegated to InventoryItem#replace_components
end
