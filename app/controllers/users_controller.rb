class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def edit_keytech_settings
  end

  def update_keytech_settings
    puts "Update settings #{params}"
    current_user.update_attributes(keytech_params)

    redirect_to keytech_settings_path, notice: 'Saved...'
  end

  def set_keytech_demo_server
    current_user.cryptedKeytechUrl("https://demo.keytech.de") #todo: use environment
    current_user.cryptedKeytechUser("jgrant")
    current_user.cryptedKeytechPassword("")
    current_user.save

    redirect_to keytech_settings_path
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
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
