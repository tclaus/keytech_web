class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

# Show a homepage for a singed_in user or for a unknown user
  def home

    if user_signed_in?
      @favorites = current_user.favorites
      @queries = current_user.queries
      # last used items?

      # If url is like /<elementkey> - then show element details
      # If  url is like /search?query=123&params..  => Show query-results (in modal screen? )
      #


      # load in another controller?
      render 'home'
    else
      render 'landing_page'
    end
  end

end
