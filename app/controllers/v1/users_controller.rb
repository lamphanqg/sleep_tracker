class V1::UsersController < ApplicationController
  before_action :set_user, only: [:follow, :unfollow, :friends]
  before_action :set_following_user, only: [:follow, :unfollow]

  def follow
    @user.follow(@following_user)
    head :ok
  end

  def unfollow
    @user.unfollow(@following_user)
    head :ok
  end

  def friends
    @friends = User.friends_of(@user).order(:id)
      .page(params[:page]).per(params[:per_page])
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    return if @user.present?

    res = {message: "user not found"}
    render json: res, status: :not_found
  end

  def set_following_user
    @following_user = User.find_by(id: params[:following_id])
    return if @following_user.present?

    res = {message: "following user not found"}
    render json: res, status: :not_found
  end
end
