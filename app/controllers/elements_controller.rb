class ElementsController < ApplicationController
  before_action :authenticate_user!

  # GET /elements, need a query for index
  # GET /users.json
  def index
    logger.info 'Index of elements'
  end

  # Show single Element
  def show_editor
    # redirect to a view
    if user_signed_in?

      load_my_keytech
      load_element
      if !@element.nil?
        load_element_tabs
        @layout = keytechAPI.layouts.main_layout(
          classkey(@element.key)
        )
      else
        flash_element_not_found
      end
      render 'application/home'
    else
      render 'application/landing_page'
    end
  end

  # Show structured Links
  def show_links
    # redirect to a view
    if user_signed_in?

      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        load_lister_layout
        @elements = keytechAPI.elements.structure(params[:id], attributes: 'lister')
        simplifyKeyValueList(@elements)

        print_element_list
        sort_elements
        print_element_list
        # byebug
        # keytech does not sort structures

      else
        flash_element_not_found
      end
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
      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        load_lister_layout
        @elements = keytechAPI.elements.whereused(params[:id], attributes: 'all')
        simplifyKeyValueList(@elements)
        sort_elements
      else
        flash_element_not_found
      end
      render 'application/home'
    else
      render 'application/landing_page'
    end
  end

  def show_notes
    # redirect to a view
    if user_signed_in?
      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        @notes = keytechAPI.notes.load(@element.key)
      else
        flash_element_not_found
      end
      render 'application/home'
    else
      render 'application/landing_page'
    end
  end

  def show_mails
    # redirect to a view
    if user_signed_in?
      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        @mails = keytechAPI.elements.mails(@element.key)
      else
        flash_element_not_found
      end
      render 'application/home'
    else
      render 'application/landing_page'
    end
  end

  def show_status
    load_my_keytech
    load_element('none')
    if !@element.nil?
      load_element_tabs
    else
      flash_element_not_found
    end
    render 'application/home'
  end

  def show_bom
    # redirect to a view
    if user_signed_in?
      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        load_bom_layout
        @elements = keytechAPI.elements.billOfMaterial(params[:id], attributes: 'lister')

        print_element_list
        sort_elements
        print_element_list

      else
        flash_element_not_found
      end
      render 'application/home'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def search
    if user_signed_in?
      # sortby=name desc
      sort_by = "#{params[:column]},#{params[:direction]}"

      @layout = load_lister_layout
      options =    { q: params[:q],
               byQuery: params[:byquery],
               groupBy: 'classkey',
               classes: params[:classes],
            attributes: 'lister',
                sortBy: sort_by }

      @searchResponseHeader = keytechAPI.search.query(options)

      sort_groupBy_values(@searchResponseHeader.groupBy)

      puts "Groups: #{@searchResponseHeader.groupBy.inspect}"
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
    masterfilename = keytechAPI.files.masterfile_name(params[:id])
    files = keytechAPI.files.load_masterfile(params[:id])
    send_data files, type: files.content_type, disposition: 'attachment', filename: masterfilename
  end

  def thumbnail
    element_key = params[:id]
    image = keytechAPI.elements.thumbnail(element_key)
    # response.headers['Cache-Control'] = 'public, max-age=3600'
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def preview
    element_key = params[:id]
    image = keytechAPI.elements.preview(element_key)
    # response.headers['Cache-Control'] = 'public, max-age=3600'
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def destroy
    if user_signed_in?
      # rescue where used, if any
      whereused = keytechAPI.elements.whereused(params[:id], { attributes: 'none' })

      result = keytechAPI.elements.delete(params[:id])
      if result.success?
        flash[:info] = "Element wurde gelöscht."
      else
        logger.warn "Element #{params[:id]} can not be deleted. Server message: '#{result.headers['x-errordescription']}'"
        flash[:error] = "Konnte nicht gelöscht werden. Ihnen fehlen möglicherweise die Berechtigungen."
      end
    end

    if !whereused.blank?
      redirect_to "/element/#{whereused[0].key}"
    else
      redirect_back fallback_location: admin_path
    end
  end

  private

  def flash_element_not_found
    # After delete there is no element!
    # flash[:warning] = "Ein Element mit dieser Nummer wurde nicht gefunden"
  end

  # Removes the prefix as_do__,  as_sdo__ .. from all keys in keyValueList.
  #
  def simplifyKeyValueList(elements)
    # remove everything form right to left till the double unerline
    elements.each do |element|
      element.keyValueList.transform_keys! do |key|
        index = key.index('__')
        if !index.nil?
          key.slice(index + 2, key.length)
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
    @layout = Rails.cache.fetch("#{current_user.cache_key}/global_lister_layout", expires_in: 1.hours) do
      keytechAPI.layouts.global_lister_layout
    end
  end

  def load_bom_layout
    @layout = Rails.cache.fetch("#{current_user.cache_key}/bom_lister_layout", expires_in: 1.hours) do
      keytechAPI.layouts.bom_lister_layout
    end
  end

  def load_element_tabs
    @subareas = Rails.cache.fetch("#{current_user.cache_key}/#{@element.key}/subareas", expires_in: 1.hours) do
      @subareas = keytechAPI.classes.load(classkey(@element.key)).availableSubareas
    end

    @hasMasterfile = keytechAPI.files.has_masterfile(@element.key)
    if @hasMasterfile == true
      @masterfileInfo = keytechAPI.files.masterfile_info(@element.key)
    end
  end

  def classkey(element_key)
    element_key.split(':').first
  end

  # Loads the element. Can set @element to nil
  def load_element(attributes = 'all')
    # If ID.startWith BOM - then load Article (default_mi)
    element_key = params[:id]
    puts "Load element with key: #{element_key}"
    @element = keytechAPI.elements.load(element_key, attributes: attributes)
    puts "Laded Element = #{@element.inspect}"
  end

  def keytechAPI
    current_user.keytechAPI
  end

  def print_element_list
    @elements.each do |element|
      puts element.key.to_s
    end
  end

  def sort_groupBy_values(group_by)
    if !group_by.nil?
      Hash[group_by.values.sort_by { |_k, v| -v }].to_h
    end
  end

  def sort_elements
    column = params[:column]
    direction = params[:direction]

    if direction == 'desc'
      puts 'Sort desc'
      @elements.sort! { |a, b| element_compare(column, a, b) }
    else
      puts 'Sort asc'
      @elements.sort! { |a, b| element_compare(column, b, a) }
    end
  end

  def element_compare(column, a, b)
    # Check well known attributes
    return a.createdByLong <=> b.createdByLong if column == 'created_by'

    return a.changedByLong <=> b.changedByLong if column == 'changed_by'

    return a.displayname <=> b.displayname if column == 'displayname'

    if column == 'classname'
      return helpers.displayNameForClass(helpers.classKey(a.key)) <=> helpers.displayNameForClass(helpers.classKey(b.key))
    end

    # Check key value
    valueA = a.keyValueList[column]
    valueB = b.keyValueList[column]
    valueA = '' if valueA.nil?
    valueB = '' if valueB.nil?
    valueA <=> valueB
  end

  def dateParser(dateString)
    # /Date(-3600000)/
    # /Date(1407103200000)/

    # get numeric value
    numeric_value = dateString[6..-3].to_i
    # Placeholder for empty date
    return '' if numeric_value == -3_600_000 || numeric_value.zero?

    Time.at(numeric_value / 1000)
  end
end
