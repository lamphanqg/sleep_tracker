class V1::SleepsController < ApplicationController
  # POST /v1/users/1/sleeps/clock_in
  def clock_in
    user = User.find(params[:user_id])
    last_sleep = user.sleeps.order(:id).last
    clock_in_time = Time.zone.parse(clock_in_time_param)
    if clock_in_time.nil?
      res = {message: "cannot parse clock_in_time param"}
      return render json: res, status: :bad_request
    end

    if last_sleep.blank? || last_sleep.finished?
      sleep = user.sleeps.new(created_at: clock_in_time)
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

  private

  def clock_in_time_param
    params.require(:clock_in_time)
  end
end
