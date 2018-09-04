class ElementsController < ApplicationController
  before_action :authenticate_user!

  # GET /elements, need a query for index
  # GET /users.json
  def index
    logger.info "Index of elements"
  end

  # Show single Element
  def show_editor
    load_element
    # redirect to a view
    if user_signed_in?
      # Add favorites and qieries
      load_my_keytech
      load_element_tabs
      @layout = keytechKit.layouts.main_layout(
        classkey(@element.key)
      )
      # load in another controller?
      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end

  end

  def show_links
    load_element

    # redirect to a view
    if user_signed_in?
      # Add favorites and qieries
      load_my_keytech
      load_element_tabs

      # load structure

      # load in another controller?
      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def thumbnail
    #TODO: Caching of images
    image = keytechKit.elements.thumbnail(params[:id])
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def preview
    #TODO: Caching of images
    image = keytechKit.elements.preview(params[:id])
    send_data image, type: image.content_type, disposition: 'inline'
  end

  private

  def load_my_keytech
    @favorites = current_user.favorites
    @queries = current_user.queries
  end

  def load_element_tabs
    @subareas = keytechKit.classes.classDefinition(classkey(@element.key)).availableSubareas
  end

  def classkey(elementKey)
    elementKey.split(':').first
  end

  def keytechKit
    current_user.keytechKit
  end

  def load_element
    # Load element from API, or cache
    @element = keytechKit.elements.find(params[:id], {"attributes":"all"})
  end

end
