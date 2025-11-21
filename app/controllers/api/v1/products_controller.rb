class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor

  def index
    items = apply_filters(Product)
    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || Kaminari.config.default_per_page).to_i, 100].min
    paginated = items.page(page).per(per_page)

    meta = {
      total_count: paginated.total_count,
      total_pages: paginated.total_pages,
      current_page: paginated.current_page,
      per_page: paginated.limit_value
    }

    branches_to_show = user_branches_to_show

    render json: {
      products: ActiveModelSerializers::SerializableResource.new(
        paginated, 
        each_serializer: Api::V1::ProductSerializer,
        branches_to_show: branches_to_show
      ),
      meta: meta
    }
  end

  private

  def apply_filters(scope)
    # Eager-load categories and item_components + their polymorphic component to avoid N+1.
    # Use `preload` for the polymorphic association to prevent ActiveRecord converting
    # the includes into an eager_load (JOIN) which raises
    # ActiveRecord::EagerLoadPolymorphicError for polymorphic associations.
    scope = scope.includes(:categories)
    scope = scope.preload(item_components: :component)
    # Preload inventory_item_branches with branch to avoid N+1 queries
    scope = scope.preload(inventory_item_branches: :branch)

    # Support filtering by one or many category ids. Accepts:
    # - ?category_ids=1,2,3
    # - ?category_ids[]=1&category_ids[]=2
    # - ?category_id=1 (backwards-compatible single id)
    category_param = params[:category_ids] || params[:category_id]
    if category_param.present?
      ids = category_param.is_a?(String) ? category_param.split(',') : Array(category_param)
      scope = scope.joins(:categories).where(categories: { id: ids }).distinct
    end
    if params[:name].present?
      scope = scope.where('name ILIKE ? OR identifier ILIKE ?', "%#{params[:name]}%", "%#{params[:name]}%")
    end

    # Sorting
    if params[:sort].present?
      direction = params[:sort].start_with?('-') ? :desc : :asc
      column = params[:sort].sub(/^-/, '')
      if %w[name identifier].include?(column)
        scope = scope.order(column => direction)
      end
    end

    scope
  end
end
