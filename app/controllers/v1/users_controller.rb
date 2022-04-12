class V1::UsersController < ApplicationController
  def follow
    user = User.find_by(id: params[:id])
    if user.nil?
      res = {message: "user not found"}
      return render json: res, status: :not_found
    end

    following_user = User.find_by(id: params[:following_id])
    if following_user.nil?
      res = {message: "following user not found"}
      return render json: res, status: :not_found
    end

    user.follow(following_user)
    head :ok
  end
end
