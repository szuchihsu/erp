class HealthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    render json: { status: "ok", timestamp: Time.current }, status: :ok
  end
end
