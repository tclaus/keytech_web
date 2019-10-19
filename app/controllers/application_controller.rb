class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :set_csp

  def set_csp
    # Set all restrictions for content security
    response.headers['Content-Security-Policy'] =
      "frame-ancestors 'none';"\
      "default-src 'none';" \
      "script-src 'self' 'unsafe-eval' 'unsafe-inline' cdnjs.cloudflare.com;" \
      "img-src 'self' data:;" \
      "style-src 'self' 'unsafe-inline' cdnjs.cloudflare.com;" \
      "font-src  'self' fonts.gstatic.com;"\
      "child-src 'self' js.stripe.com;" \
      "connect-src 'self' api.stripe.com;"\
      "frame-src 'self' js.stripe.com;" \
      "form-action 'self';"\
      "base-uri 'self';"

    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
  end

  # Show hompage before logged in
  def home
    if user_signed_in?

      if current_user.connection_valid?
        @favorites = current_user.favorites
        @queries = current_user.queries
        @keytech_username = current_user.keytech_username
        # Load Dashboard async in javascript
        render 'home'
      else
        render 'invalid_login'
      end
    else

      # User is not signed in in platform
      render 'landing_page'
    end
  end

  def dashboard
    @dashboard_elements = load_dashboard_cached
    render layout: false
  end

  private

  # sets the localizaton from request Header
  def set_locale
    if current_user.blank?
      I18n.locale = valid_language
      logger.debug "* Locale set to '#{I18n.locale}'"
    else
      # TODO: Let user decide which language - to high prio in keytech environment
      I18n.locale = 'de' # current_user.language_id
    end
  end

  # Returns a valid language ID. Fall back to a default
  def valid_language
    locale = extract_locale_from_accept_language_header
    logger.debug "* Extracted Locale ID: #{locale}"
    if !locale.blank? &&
       (locale == 'de' ||
         locale == 'en')
      locale
    else
      DEFAULT_LANGUAGE
    end
  end

  # extracts the accept-language header
  def extract_locale_from_accept_language_header
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    logger.debug "* Accept-Language from header: #{accept_language}"
    return accept_language.scan(/^[a-z]{2}/).first if accept_language
  end

  def load_dashboard_cached
    Rails.cache.fetch("#{current_user.cache_key}/recent_activities", expires_in: 1.minutes) do
      load_dashboard_from_api
    end
  end

  # Executes query from api for recent changes
  # Loads recent changes and creations
  def load_dashboard_from_api
    logger.info 'Loading dashboard...'
    max_elements = 5
    username = current_user.keytech_username
    ms_from_epoch = 7.day.ago.to_i * 1000
    from_date = "/Date(#{ms_from_epoch})/"
    options = { fields: "created_by=#{username}:changed_at>#{from_date}", size: max_elements, sortBy: 'changed_at,desc' }

    self_created = keytechAPI.search.query(options)

    options = { fields: "created_by=#{username}:changed_at>#{from_date}",
                size: max_elements,
                sortBy: 'changed_at,desc' }
    self_changed = keytechAPI.search.query(options)
    logger.debug "Changed items: #{self_changed}"
    logger.debug "Created Items: #{self_created}"
    element_list = (self_created.elementList + self_changed.elementList)
    logger.info 'Finished loading dashboard'
    element_list.sort_by!(&:changedAt)
    element_list.reverse
  end

  def keytechAPI
    current_user.keytechAPI
  end
end
