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

    render json: {
      products: ActiveModelSerializers::SerializableResource.new(paginated, each_serializer: Api::V1::ProductSerializer),
      meta: meta
    }
  end

  private

  def apply_filters(scope)
    scope = scope.includes(:categories)
    # Support filtering by one or many category ids. Accepts:
    # - ?category_ids=1,2,3
    # - ?category_ids[]=1&category_ids[]=2
    # - ?category_id=1 (backwards-compatible single id)
    category_param = params[:category_ids] || params[:category_id]
    if category_param.present?
      ids = category_param.is_a?(String) ? category_param.split(',') : Array(category_param)
      ids = ids.map(&:to_i).reject(&:zero?)
      scope = scope.joins(:categories).where(categories: { id: ids }).distinct
    end
    if params[:name].present?
      scope = scope.where('name ILIKE ?', "%#{params[:name]}%")
    end
    if params[:identifier].present?
      scope = scope.where('identifier ILIKE ?', "%#{params[:identifier]}%")
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
