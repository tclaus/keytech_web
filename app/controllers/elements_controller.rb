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
      transform_element_fields(@element)
      if !@element.nil?
        load_element_tabs
        @layout = keytechAPI.layouts.main_layout(helpers.class_key(@element.key))
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
        @elements = keytechAPI.element_handler.structure(params[:id], attributes: 'lister')
        simplify_key_value_list(@elements)
        transform_elements_fields(@elements)
        sort_elements
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
        @elements = keytechAPI.element_handler.whereused(params[:id], attributes: 'all')
        simplify_key_value_list(@elements)
        transform_elements_fields(@elements)
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
    if user_signed_in?
      load_my_keytech
      load_element('none')
      if !@element.nil?
        load_element_tabs
        @notes = keytechAPI.element_handler.note_handler.load(@element.key)
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
        @mails = keytechAPI.element_handler.mails(@element.key)
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
        @elements = keytechAPI.element_handler.billOfMaterial(params[:id], attributes: 'lister')
        sort_elements
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
      options = { q: params[:q],
                  byQuery: params[:byquery],
                  groupBy: 'classkey',
                  classes: params[:classes],
                  attributes: 'lister',
                  sortBy: sort_by }

      @search_response_header = keytechAPI.search.query(options)
      sort_groupby_values(@search_response_header.groupBy)

      @elements = @search_response_header.elementList
      transform_elements_fields(@elements)
      simplify_key_value_list(@elements)
      # TODO: Load in another controller?
      render 'keytech/_search_results'
    else
      # 404 not found?
      render 'application/landing_page'
    end
  end

  def masterfile
    # Load masterfile from elementID
    file_handler = keytechAPI.element_handler.file_handler
    masterfilename = file_handler.masterfile_name(params[:id])
    files = file_handler.load_masterfile(params[:id])
    send_data files, type: files.content_type, disposition: 'attachment', filename: masterfilename
  end

  def thumbnail
    element_key = params[:id]
    image = keytechAPI.element_handler.thumbnail(element_key)
    # response.headers['Cache-Control'] = 'public, max-age=3600'
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def preview
    element_key = params[:id]
    image = keytechAPI.element_handler.preview(element_key)
    # response.headers['Cache-Control'] = 'public, max-age=3600'
    send_data image, type: image.content_type, disposition: 'inline'
  end

  def destroy
    if user_signed_in?
      # rescue where used, if any
      whereused = keytechAPI.element_handler.whereused(params[:id], attributes: 'none')

      result = keytechAPI.element_handler.delete(params[:id])
      if result.success?
        flash[:info] = 'Element wurde gelöscht.'
      else
        logger.warn "Element #{params[:id]} can not be deleted. Server message: '#{result.headers['x-errordescription']}'"
        flash[:error] = 'Konnte nicht gelöscht werden. Ihnen fehlen möglicherweise die Berechtigungen.'
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

  # Changes index Values from distinct fields to display values on some
  # element types
  def transform_elements_fields(elements)
    # keytech does not send layout data with data dictioniers for switched types
    # TASK_MAF / MAIL_WF
    # MailCategories,
    # TaskCategories
    # TaskConditions
    # TaskStatus
    # TaskPriority
    # MailPriority
    elements.each do |element|
      class_key = helpers.class_key(element.key)

      if ['TASK_WF', 'MAIL_WF'].include?(class_key)
        transform_element_fields(element)
      end
    end
  end

  def transform_element_fields(element)
    unless element.nil?
      element.keyValueList.each do |key, value|
        transform_status(element, key, value) if key == 'as_sfd__status'
        transform_category(element, key, value) if key == 'as_sfd__category'
        transform_priority(element, key, value) if key == 'as_sfd__priority'
      end
    end
  end

  def transform_status(element, key, value)
    if helpers.class_key(element.key) == 'TASK_WF'
      data = data_dictionary('TaskStatus') # sets 'data'
      data.each do |status_value|
        if status_value['statusvalue'] == value
          element.keyValueList[key] = status_value['status']
        end
      end
    end
  end

  def transform_category(element, key, value)
    data = if helpers.class_key(element.key) == 'TASK_WF'
             data_dictionary('TaskCategories')
           else
             data_dictionary('MailCategories')
           end
    element.keyValueList[key] = ''
    data.each do |task_value|
      if task_value['categoryvalue'] == value
        element.keyValueList[key] = task_value['category']
      end
    end
  end

  def transform_priority(element, key, value)
    data = if helpers.class_key(element.key) == 'TASK_WF'
             data_dictionary('TaskCategories') # sets 'data'
           else
             data_dictionary('MailCategories') # sets 'data'
           end
    element.keyValueList[key] = ''
    data.each do |task_value|
      if task_value['priorityvalue'] == value
        element.keyValueList[key] = task_value['priority']
      end
    end
  end

  # Removes the prefix as_do__,  as_sdo__ .. from all keys in keyValueList.
  #
  def simplify_key_value_list(elements)
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

  def data_dictionary(datadictionary)
    Rails.cache.fetch("#{current_user.cache_key}/#{datadictionary}", expires_in: 1.hours) do
      keytechAPI.data_dictionary_handler.getData(datadictionary)
    end
  end

  def load_bom_layout
    @layout = Rails.cache.fetch("#{current_user.cache_key}/bom_lister_layout", expires_in: 1.hours) do
      keytechAPI.layouts.bom_lister_layout
    end
  end

  def load_element_tabs
    @subareas = Rails.cache.fetch("#{current_user.cache_key}/#{@element.key}/subareas", expires_in: 1.hours) do
      @subareas = keytechAPI.classes.load(helpers.class_key(@element.key)).availableSubareas
    end

    @hasMasterfile = keytechAPI.element_handler.file_handler.masterfile?(@element.key)
    if @hasMasterfile == true
      @masterfileInfo = keytechAPI.element_handler.file_handler.masterfile_info(@element.key)
    end
  end

  # Loads the element. Can set @element to nil
  def load_element(attributes = 'all')
    # If ID.startWith BOM - then load Article (default_mi)
    element_key = params[:id]
    logger.debug "Load element with key: #{element_key}"
    @element = keytechAPI.element_handler.load(element_key, attributes: attributes)
  end

  def sort_groupby_values(group_by)
    group_by.values = Hash[group_by.values.sort_by { |_k, v| -v }].to_h unless group_by.nil?
  end

  def sort_elements
    column = params[:column]
    direction = params[:direction]

    if direction == 'desc'
      @elements.sort! { |a, b| element_compare(column, a, b) }
    else
      @elements.sort! { |a, b| element_compare(column, b, a) }
    end
  end

  def element_compare(column, first, second)
    # Check well known attributes
    return first.createdByLong <=> second.createdByLong if column == 'created_by'
    return first.changedByLong <=> second.changedByLong if column == 'changed_by'
    return first.displayname <=> second.displayname if column == 'displayname'

    if column == 'classname'
      first_class_key = helpers.class_key(first.key)
      second_class_key = helpers.class_key(second.key)
      return helpers.class_displayname(first_class_key) <=> helpers.class_displayname(second_class_key)
    end

    # Check key value
    valueA = first.keyValueList[column]
    valueB = second.keyValueList[column]
    valueA = '' if valueA.nil?
    valueB = '' if valueB.nil?
    valueA <=> valueB
  end
end
