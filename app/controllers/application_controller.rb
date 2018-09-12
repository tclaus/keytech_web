
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

# Show a homepage for a singed_in user or for a unknown user
  def home

    if user_signed_in?

      if (current_user.hasValidConnection)
        @favorites = current_user.favorites
        @queries = current_user.queries

        render 'home'
      else
        render 'invalid_login'
      end
    else

      # User is not signed in in platform
      render 'landing_page'
    end
  end

end
