class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def handle_parameter_missing(e)
    render json: {message: e.original_message}, status: :bad_request
  end

  def not_found(e)
    render json: {message: e.to_s}, status: :not_found
  end
end
