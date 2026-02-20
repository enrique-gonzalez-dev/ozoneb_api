# frozen_string_literal: true

class Api::V1::InventoryTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor
  before_action :set_inventory_transaction, only: [:show, :update, :destroy]

  # GET /api/v1/inventory_transactions
  def index
    @inventory_transactions = InventoryTransaction.includes(:user, :branch, :inventory_transaction_items, :inventory_items)
                                                  .recent
                                                  .page(params[:page])
                                                  .per(params[:per_page] || 25)

    # Apply filters if provided
    @inventory_transactions = @inventory_transactions.by_type(params[:transaction_type]) if params[:transaction_type].present?
    @inventory_transactions = @inventory_transactions.by_user(params[:user_id]) if params[:user_id].present?
    @inventory_transactions = @inventory_transactions.by_branch(params[:branch_id]) if params[:branch_id].present?

    render json: {
      inventory_transactions: @inventory_transactions.map { |t| Api::V1::InventoryTransactionSerializer.new(t).as_json },
      meta: {
        current_page: @inventory_transactions.current_page,
        total_pages: @inventory_transactions.total_pages,
        total_count: @inventory_transactions.total_count
      }
    }
  end

  # GET /api/v1/inventory_transactions/:id
  def show
    render json: Api::V1::InventoryTransactionSerializer.new(@inventory_transaction).as_json
  end

  # POST /api/v1/inventory_transactions
  def create
    @inventory_transaction = InventoryTransaction.new(inventory_transaction_params)
    @inventory_transaction.user = current_user

    # Set destination_branch_id for transfers (from params, not persisted)
    if params.dig(:inventory_transaction, :destination_branch_id).present?
      @inventory_transaction.destination_branch_id = params[:inventory_transaction][:destination_branch_id]
    end

    begin
      InventoryTransaction.transaction do
        @inventory_transaction.save!
      end

      render json: Api::V1::InventoryTransactionSerializer.new(@inventory_transaction).as_json, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/inventory_transactions/:id
  def update
    # TODO: Implement update with proper inventory reversal logic
    render json: { error: 'Update not yet implemented for transactions with automatic inventory changes' }, status: :not_implemented
  end

  # DELETE /api/v1/inventory_transactions/:id
  def destroy
    # TODO: Implement delete with proper inventory reversal logic
    render json: { error: 'Delete not yet implemented for transactions with automatic inventory changes' }, status: :not_implemented
  end

  private

  def set_inventory_transaction
    @inventory_transaction = InventoryTransaction.includes(:inventory_transaction_items, :inventory_items, :user, :branch)
                                                  .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Inventory transaction not found' }, status: :not_found
  end

  def inventory_transaction_params
    params.require(:inventory_transaction).permit(
      :transaction_type,
      :transaction_subtype,
      :note,
      :branch_id,
      inventory_transaction_items_attributes: [:id, :inventory_item_id, :quantity, :_destroy]
    )
  end
end
