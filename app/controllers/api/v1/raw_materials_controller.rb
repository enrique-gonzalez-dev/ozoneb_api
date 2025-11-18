class Api::V1::RawMaterialsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor

  def index
    items = apply_filters(RawMaterial)
    page = (params[:page] || 1).to_i
    per_page = [(params[:per_page] || Kaminari.config.default_per_page).to_i, 100].min
    paginated = items.page(page).per(per_page)

    meta = {
      total_count: paginated.total_count,
      total_pages: paginated.total_pages,
      current_page: paginated.current_page,
      per_page: paginated.limit_value
    }

    response.set_header('X-Total-Count', paginated.total_count)
    response.set_header('X-Total-Pages', paginated.total_pages)

    render json: {
      raw_materials: ActiveModelSerializers::SerializableResource.new(paginated, each_serializer: Api::V1::RawMaterialSerializer),
      meta: meta
    }
  end

  private

  def apply_filters(scope)
    scope = scope.all

    if params[:category_id].present? && scope.respond_to?(:reflect_on_association) && scope.reflect_on_association(:categories)
      scope = scope.joins(:categories).where(categories: { id: params[:category_id] })
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
