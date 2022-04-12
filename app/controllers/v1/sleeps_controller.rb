class V1::SleepsController < ApplicationController
  before_action :set_user, only: [:clock_in, :index]

  # POST /v1/users/1/sleeps/clock_in
  def clock_in
    last_sleep = @user.sleeps.order(:id).last
    clock_in_time = Time.zone.parse(clock_in_time_param)
    if clock_in_time.nil?
      res = {message: "cannot parse clock_in_time param"}
      return render json: res, status: :bad_request
    end

    if last_sleep.blank? || last_sleep.finished?
      sleep = @user.sleeps.new(created_at: clock_in_time)
    else
      sleep = last_sleep
      sleep.ended_at = clock_in_time
    end

    if sleep.save
      render json: sleep, status: :ok
    else
      render json: sleep.errors, status: :unprocessable_entity
    end
  end

  # GET /v1/users/1/sleeps
  def index
    @sleeps = @user.sleeps.order(created_at: :desc)
      .page(params[:page]).per(params[:per_page])
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def clock_in_time_param
    params.require(:clock_in_time)
  end
end
