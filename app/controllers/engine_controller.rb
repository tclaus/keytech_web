require 'json'

class EngineController < ApplicationController
  before_action :authenticate_user!

  # Renders a simple data dialog
  def show_classes_dialog
    render 'elements/show_class_list', layout: 'modal'
  end

  # Renders a simple data dialog
  def show_new_note_dialog
    load_note_types(params[:element_key])
    @element_key = params[:element_key]
    render 'elements/new_note_dialog', layout: 'modal_edit_element'
  end

  def delete_note
    logger.info "Delete Note! #{params[:id]}"
    note = keytech_note_handler.create('', params[:element_key])
    note.id = params[:id]
    keytech_note_handler.remove(note)
  end

  # Adds a new note to element
  def create_new_note
    note_type = params[:note_type][:note_type_id]
    new_note = keytech_note_handler.create(note_type, params[:element_key])
    new_note.subject = params[:subject]
    new_note.text = params[:body]
    response = keytech_note_handler.save(new_note)
    if response[:success] == true
      flash[:info] = 'Notiz wurde angelegt'
    else
      flash[:error] = "Notiz konnte nicht angelegt werden: #{response[:error]}"
    end
    redirect_to "/element/#{params[:element_key]}/notes"
  end

  # returns a json with full classlist
  #
  def show_classes
    classes = Rails.cache.fetch("#{current_user.cache_key}/allClasses", expires_in: 1.hours) do
      keytechAPI.classes.loadAllClasses
    end

    # Filter only to files, office file and folders, ignore all CAD-related  types
    @classes = []
    classes.each do |element_class|
      next unless element_class.classKey.ends_with?('_WF') ||
                  element_class.classKey.ends_with?('_FD') ||
                  element_class.classKey.ends_with?('_FILE') ||
                  element_class.classKey.ends_with?('_WW') ||
                  element_class.classKey.ends_with?('_XL') ||
                  element_class.classKey.ends_with?('_PRJ')

      if !element_class.classKey.starts_with?('DEFAULT') && element_class.isActive
        @classes.push element_class
      end
    end

    response.headers['Cache-Control'] = 'public, max-age=60'
    respond_to do |format|
      format.json do
        render json: @classes
      end
    end
  end

  def show_new_element_dialog
    class_key = params[:classkey]
    @class_definition = getClassDefinition(class_key)
    @layout = getLayout(class_key)
    render 'elements/show_new_element', layout: 'modal_edit_element'
  end

  # Create and stores a new element
  def new_element
    # collect element data
    class_key = params[:classKey]
    element = keytechAPI.element_handler.new_element(class_key)

    # Layout holds all controls to fill
    layout = getLayout(class_key)
    errors = []
    layout.controls.each do |control|
      # Labels are the only control type a element can not use for data
      next unless control.controlType != 'LABEL'

      key = control.attributeName
      value = params[control.attributeName]

      unless control.isNullable
        if value.blank?
          errors.push "Feld '#{control.displayname}' darf nicht leer sein. "
        end
      end

      element.keyValueList[key] = value
    end

    unless errors.empty?
      logger.error "Errors occured: #{errors.inspect}"
      flash[:warning] = errors
      return redirect_back(fallback_location: root_path)
    end

    saved_element = keytechAPI.element_handler.save(element)
    # Save ok? If not create a warning and rebuild
    logger.info "New element saved: #{saved_element.key}"
    if saved_element.blank?
      logger.warn('Could not save element')
      flash[:warning] = 'Konnte Element nicht anlegen.'
      redirect_back(fallback_location: root_path)
    else
      flash[:info] = 'Element wurde angelegt.'
      redirect_to show_element_path(id: saved_element.key)
    end
  end

  def show_value_form
    # Load element
    data_dictionary_id = params[:dataDictionaryID]
    @element_key = params[:elementKey]
    @attribute = params[:attribute]

    if data_dictionary_id != '0'
      # Give layout, if elementkey was set
      return render_data_dictionary(data_dictionary_id, !@element_key.nil?)
    end

    @element_key = params[:elementKey]
    @attribute_type = params[:attributeType]
    @element = keytechAPI.element_handler.load(@element_key, attributes: 'all')
    @field_value = @element.keyValueList[@attribute]

    render_attribute_field
  end

  def render_attribute_field
    if @attribute_type == 'text'
      render 'forms/text_editor', layout: 'attribute_form'
    end

    if @attribute_type == 'memo'
      render 'forms/textarea_editor', layout: 'attribute_form'
    end

    if @attribute_type == 'double'
      render 'forms/number_editor', layout: 'attribute_form'
    end

    if @attribute_type == 'integer'
      render 'forms/integer_editor', layout: 'attribute_form'
    end

    if @attribute_type == 'check'
      render 'forms/check_editor', layout: 'attribute_form'
    end

    if @attribute_type == 'date'
      @field_value = helpers.parse_value(@field_value)
      render 'forms/date_editor', layout: 'attribute_form'
    end
  end

  def update_value_form
    if params[:cancel] == 'true'
      redirect_back(fallback_location: root_path)
    else
      element_key = params[:elementKey]
      attribute = params[:attribute]
      value = params[attribute]
      data_dictionary_json = params['datadictionary_field_' + attribute]
      data_dictionary_id = params[:datadictionary_id]

      element = keytechAPI.element_handler.new_element(element_key)
      if data_dictionary_id.blank?
        element.keyValueList[attribute] = value
      else
        update_data_dictionary_field(element, data_dictionary_id, data_dictionary_json)
      end

      updated_element = keytechAPI.element_handler.update(element)

      show_updated_element(updated_element)
    end
  end

  def checkserver
    # TODO: Check oly of logged in
    server_check_result = current_user.connection_valid?
    render json: { available: server_check_result }
  end

  private

  def show_updated_element(element)
    if element.blank?
      logger.warn('Could not update element')
      flash[:warning] = 'Konnte Element nicht aktualisieren.'
      redirect_back(fallback_location: root_path)
    else
      flash[:info] = 'Element wurde aktualisiert.'
      redirect_to show_element_path(id: element.key)
    end
  end

  def update_data_dictionary_field(element, data_dictionary_id, data_dictionary_json)
    data_definition = getDataDictionaryDefinition(data_dictionary_id)
    data_definition.each do |definition|
      unless definition.toTargetAttribute.blank?
        values = JSON.parse(data_dictionary_json)
        element.keyValueList[definition.toTargetAttribute] = values[definition.attribute.to_s]
      end
    end
  end

  def render_data_dictionary(dd_id, with_layout, search_text: '')
    @data_definition = getDataDictionaryDefinition(dd_id)
    @data = getDataDictionaryData(dd_id)
    @data_dictionary_id = dd_id
    # response.headers['Cache-Control'] = 'public, max-age=3600'
    if with_layout
      render 'forms/dataDictionary_editor', layout: 'attribute_form'
    else
      render 'forms/dataDictionary_editor', layout: false
    end
  end

  def getDataDictionaryDefinition(ddID)
    Rails.cache.fetch("#{current_user.cache_key}/datadictionary/#{ddID}", expires_in: 1.hours) do
      keytechAPI.data_dictionary_handler.getDefinition(ddID)
    end
  end

  def getDataDictionaryData(ddID)
    Rails.cache.fetch("#{current_user.cache_key}/datadictionary/#{ddID}/data", expires_in: 1.hours) do
      keytechAPI.data_dictionary_handler.getData(ddID)
    end
  end

  def getClassDefinition(class_key)
    Rails.cache.fetch("#{current_user.cache_key}/#{class_key}", expires_in: 1.hours) do
      keytechAPI.classes.load(class_key)
    end
  end

  def getLayout(class_key)
    Rails.cache.fetch("#{current_user.cache_key}/#{class_key}/main_layout", expires_in: 1.hours) do
      keytechAPI.layouts.main_layout(class_key)
    end
  end

  def load_note_types(element_key)
    @note_types = Rails.cache.fetch("#{current_user.cache_key}/#{element_key}/notetypes", expires_in: 1.hours) do
      # TODO: load Notetypes be element permissions
      @note_types = keytech_note_handler.load_note_types
    end
  end

  def keytech_note_handler
    keytechAPI.element_handler.note_handler
  end

  def keytechAPI
    current_user.keytechAPI
  end
end
