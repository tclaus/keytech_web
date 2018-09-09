class ElementsController < ApplicationController
  before_action :authenticate_user!

  # GET /elements, need a query for index
  # GET /users.json
  def index
    logger.info "Index of elements"
  end

  # Show single Element
  def show_editor
    # redirect to a view
    if user_signed_in?

      load_element
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

  # Show structured Links
  def show_links

    # redirect to a view
    if user_signed_in?
      # Add favorites and qieries
      load_element("none")
      load_my_keytech
      load_element_tabs
      @layout = keytechKit.layouts.global_lister_layout
      @elements = keytechKit.elements.structure(params[:id], {"attributes":"all"})
      simplifyKeyValueList(@elements)

      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def show_whereused
    # redirect to a view
    if user_signed_in?
      # Add favorites and qieries
      load_element("none")
      load_my_keytech
      load_element_tabs
      @layout = keytechKit.layouts.global_lister_layout
      @elements = keytechKit.elements.whereused(params[:id], {"attributes":"all"})
      simplifyKeyValueList(@elements)

      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def show_notes
    # redirect to a view
    if user_signed_in?

      load_element("none")
      load_my_keytech
      load_element_tabs
      @notes = keytechKit.notes.load(@element.key)
      # load in another controller?
      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end

  end

  def search
    if user_signed_in?

      @layout = keytechKit.layouts.global_lister_layout
      options = {groupBy:"classkey", classes: params[:classes]}
      @searchResponseHeader = find_element_by_search(params[:q], options)
      @elements = @searchResponseHeader.elementList

      # load in another controller?
      render 'keytech/_search_results'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def masterfile
    # Load masterfile from elementID
    masterfilename = keytechKit.files.masterfilename(params[:id])
    files = keytechKit.files.loadMasterfile(params[:id])
    send_data files, type: files.content_type, disposition: 'attachment', filename: masterfilename
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

  # Removes the prefix as_do__,  as_sdo__ .. from keys in keyValueList.
  def simplifyKeyValueList(elements)
    # remove everything till the double unerline
    elements.each do |element|
      element.keyValueList.transform_keys! do |key|
          index = key.index('__')
          if index != nil
            key.slice(index + 2,key.length)
          else
            key
          end
      end

    end
  end

  def load_my_keytech
    @favorites = current_user.favorites
    @queries = current_user.queries
  end

  def load_element_tabs
    # Cache subareas for elementkey
    @subareas = keytechKit.classes.load(classkey(@element.key)).availableSubareas
    @hasMasterfile = keytechKit.files.hasMasterfile(@element.key)
  end

  def classkey(elementKey)
    elementKey.split(':').first
  end

  def keytechKit
    current_user.keytechKit
  end

  def find_element_by_search(searchText, options)
    # Fake masses of elements?
     keytechKit.search.query(searchText,options)
  end

  def load_element(attributes = "all")
    # Load element from API, or cache
    @element = keytechKit.elements.load(params[:id], {"attributes":attributes})
  end

end
