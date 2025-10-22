class Api::V1::BranchesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_or_supervisor

  def index
    branches = Branch.all
    render json: branches, each_serializer: Api::V1::BranchSerializer
  end

  def show
    branch = Branch.find(params[:id])
    render json: branch, serializer: Api::V1::BranchSerializer
  end

  def create
    branch = Branch.new(branch_params)
    if branch.save
      render json: branch, status: :created
    else
      render json: { errors: branch.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def branch_params
    params.require(:branch).permit(:name, :branch_type)
  end
end
