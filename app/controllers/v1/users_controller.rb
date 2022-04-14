class V1::UsersController < ApplicationController
  before_action :set_user, only: [:follow, :unfollow]
  before_action :set_following_user, only: [:follow, :unfollow]

  def follow
    @user.follow(@following_user)
    head :ok
  end

  def unfollow
    @user.unfollow(@following_user)
    head :ok
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      res = {message: "user not found"}
      return render json: res, status: :not_found
    end
  end

  def set_following_user
    @following_user = User.find_by(id: params[:following_id])
    if @following_user.nil?
      res = {message: "following user not found"}
      return render json: res, status: :not_found
    end
  end
end
