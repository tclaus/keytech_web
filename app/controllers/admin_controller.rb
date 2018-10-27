class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :isAdmin

  def index
    @users = User.all.order(:id)
    render 'admin/userlist'
  end

  private

  def isAdmin
    unless current_user.isAdmin
      # ä todo flash message
      redirect_to root_path
    end
  end
end
