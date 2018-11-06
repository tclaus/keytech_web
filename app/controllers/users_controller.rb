class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  def edit_keytech_settings; end

  def update_keytech_settings
    current_user.update_attributes(keytech_params)
    if !current_user.hasValidConnection?
      redirect_to keytech_settings_path, alert: 'keytech URL, Benutzername oder Passwort falsch'
    else
      redirect_to keytech_settings_path, notice: 'Gespeichert'
    end
  end

  def set_keytech_demo_server
    current_user.keytech_url = ENV['KEYTECH_URL']
    current_user.keytech_username = ENV['KEYTECH_USERNAME']
    current_user.keytech_password = ENV['KEYTECH_PASSWORD']
    current_user.save

    redirect_to keytech_settings_path
  end

  # DELETE /users/1
  def destroy
    user = User.find(params[:id])
    if user.id == current_user.id
      flash[:alert] = 'Sie können sich nicht selber löschen'
    else
      user.destroy
    end

    redirect_back fallback_location: admin_path
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def keytech_params
    params.require(:user).permit(:keytech_url, :keytech_username, :keytech_password)
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
