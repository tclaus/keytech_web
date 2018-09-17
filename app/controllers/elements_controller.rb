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
      @layout = keytechAPI.layouts.main_layout(
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
      load_lister_layout

      @elements = keytechAPI.elements.structure(params[:id], {"attributes":"all"})
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
      load_lister_layout

      @elements = keytechAPI.elements.whereused(params[:id], {"attributes":"all"})
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
      @notes = keytechAPI.notes.load(@element.key)
      # load in another controller?
      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def show_status
    load_element("none")
    load_my_keytech
    load_element_tabs

    render 'application/home'
  end

  def show_bom
    # redirect to a view
    if user_signed_in?
      load_element("none")
      load_my_keytech
      load_element_tabs
      load_bom_layout

      @elements = keytechAPI.elements.billOfMaterial(params[:id], {"attributes":"lister"})

      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def show_messages
    load_element("none")
    load_my_keytech
    load_element_tabs

    render 'application/home'
  end

  def search
    if user_signed_in?

      @layout = keytechAPI.layouts.global_lister_layout
      options = {groupBy:"classkey", classes: params[:classes], attributes:"lister"}
      @searchResponseHeader = find_element_by_search(params[:q], options)
      @elements = @searchResponseHeader.elementList
      simplifyKeyValueList(@elements)
      # load in another controller?
      render 'keytech/_search_results'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def masterfile
    # Load masterfile from elementID
    masterfilename = keytechAPI.files.masterfilename(params[:id])
    files = keytechAPI.files.loadMasterfile(params[:id])
    send_data files, type: files.content_type, disposition: 'attachment', filename: masterfilename
  end

  def thumbnail
    elementKey = params[:id]
    image = keytechAPI.elements.thumbnail(elementKey)
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def preview
    elementKey = params[:id]
    image = keytechAPI.elements.preview(elementKey)
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

  def load_lister_layout
    @layout = Rails.cache.fetch("global_lister_layout", expires_in: 1.hours) do
      keytechAPI.layouts.global_lister_layout
    end
  end

  def load_bom_layout
    @layout = Rails.cache.fetch("bom_lister_layout", expires_in: 1.hours) do
      keytechAPI.layouts.bom_lister_layout
    end
  end

  def load_element_tabs
    @subareas = Rails.cache.fetch("#{@element.key}/subareas", expires_in: 1.hours) do
        @subareas = keytechAPI.classes.load(classkey(@element.key)).availableSubareas
    end

    @hasMasterfile = keytechAPI.files.hasMasterfile(@element.key)
    if @hasMasterfile == true
      @masterfileInfo = keytechAPI.files.masterfileInfo(@element.key)
    end
  end

  def classkey(elementKey)
    elementKey.split(':').first
  end

  def find_element_by_search(searchText, options)
    # Fake masses of elements?
     keytechAPI.search.query(searchText,options)
  end

  def load_element(attributes = "all")
    @element = keytechAPI.elements.load(params[:id], {"attributes":attributes})
  end

  def keytechAPI
    current_user.keytechAPI
  end
end
