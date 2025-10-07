class Api::V1::HealthController < ApplicationController
  skip_before_action :authenticate_request, only: [ :index ]

  def index
    render json: {
      status: 'OK',
      message: 'Ozoneb API is running',
      timestamp: Time.current,
      version: '1.0.0'
    }
  end
end
