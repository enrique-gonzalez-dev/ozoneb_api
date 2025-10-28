class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor
  before_action :set_category, only: [:destroy, :update]

  def index
    items = apply_filters(Category)
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
      categories: ActiveModelSerializers::SerializableResource.new(paginated, each_serializer: Api::V1::CategorySerializer),
      meta: meta
    }
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: category, serializer: Api::V1::CategorySerializer, status: :created
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      render json: { message: 'Category deleted successfully' }, status: :ok
    else
      render json: { errors: @category.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, serializer: Api::V1::CategorySerializer, status: :ok
    else
      render json: { errors: @category.errors }, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def apply_filters(scope)
    scope = scope.all
    if params[:name].present?
      scope = scope.where('name ILIKE ?', "%#{params[:name]}%")
    end

    # Sorting
    if params[:sort].present?
      direction = params[:sort].start_with?('-') ? :desc : :asc
      column = params[:sort].sub(/^-/, '')
      if %w[name].include?(column)
        scope = scope.order(column => direction)
      end
    end

    scope
  end
end
