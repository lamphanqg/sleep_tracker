class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  private

  def handle_parameter_missing(e)
    render json: {message: e.original_message}, status: :bad_request
  end
end
