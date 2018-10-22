
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

      response.headers['X-Content-Type-Options'] = "nosniff"
      response.headers['X-Frame-Options'] = "DENY"
      response.headers['X-XSS-Protection'] = "1; mode=block"

  end

  # Show hompage before logged in
  def home

    if user_signed_in?

      if (current_user.hasValidConnection?)
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
private
  # sets the localizaton from request Header
  def set_locale
    if current_user.blank?
      I18n.locale = get_valid_language
      logger.debug "* Locale set to '#{I18n.locale}'"
    else
      # TODO: Let user decide which language - to high prio in keytech environment
      I18n.locale = 'de' # current_user.language_id
    end
  end

  # Returns a valid language ID. Fall back to a default
  def get_valid_language
    locale = extract_locale_from_accept_language_header
    logger.debug "* Extracted Locale ID: #{locale}"
    if !locale.blank? &&
      (locale == "de" ||
        locale == "en")
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
end
