class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

# Show a homepage for a singed_in user or for a unknown user
  def home

    if user_signed_in?
      @favorites = current_user.favorites
      @queries = current_user.queries
      # last used items?

      # load in another controller?
      render 'home'
    else
      render 'landing_page'
    end
  end

end
