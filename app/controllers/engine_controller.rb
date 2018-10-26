require 'json'

class EngineController < ApplicationController
  before_action :authenticate_user!


    # Renders a simple data dialog
    def show_classes_dialog
      render 'elements/show_class_list', layout: "modal"
    end

    # returns a json with full classlist
    #
    def show_classes
      classes = Rails.cache.fetch("allClasses", expires_in: 1.hours) do
         keytechAPI.classes.loadAllClasses
      end

      #Filter only to files, office file and folders
      @classes  = []
      classes.each do |elementClass|
          if (elementClass.classKey.ends_with?("_WF") ||
              elementClass.classKey.ends_with?("_FD") ||
              elementClass.classKey.ends_with?("_FILE") ||
              elementClass.classKey.ends_with?("_WW") ||
              elementClass.classKey.ends_with?("_XL") ||
              elementClass.classKey.ends_with?("_PRJ"))
              if !elementClass.classKey.starts_with?("DEFAULT") && elementClass.isActive == true
                @classes.push elementClass
              end
          end
      end

      respond_to do |format|
          format.json{
            render json: @classes
          }
        end

    end

    def show_new_element_dialog

      classKey = params[:classkey]
      @classDefinition = getclassDefinition(classKey)
      @layout = getLayout(classKey)
      render 'elements/show_new_element', layout: "modal_edit_element"
    end

    def new_element
      # collect element data
      classKey = params[:classKey]
      element = keytechAPI.elements.newElement(params[:classKey])

      # Layout holds all controls to fill
      layout = getLayout(classKey)
      errors = [];
      layout.controls.each do |control|
        # Labels are the only control type a element can not use for data
        if control.controlType != "LABEL"

          key = control.attributeName
          value = params[control.attributeName]

          if !control.isNullable
            if value.blank?
              errors.push "Feld '#{control.displayname}' darf nicht leer sein. "
            end
          end

          element.keyValueList[key] = value
        end
      end

      if !errors.empty?
        puts "Errors occured: #{errors.inspect}"
        flash[:warning] = errors
        redirect_back(fallback_location: root_path)
        return
      end

      saved_element = keytechAPI.elements.save(element)
      # Save ok? If not create a warning and rebuild
      if saved_element.blank?
        logger.warn("Could not save element")
        flash[:warning] = "Konnte Element nicht anlegen."
        redirect_back(fallback_location: root_path)
        return
      else
        flash[:info] = "Element wurde angelegt."
        redirect_to element_show_path(id:saved_element.key)
        return
      end

    end

    def show_value_form
      # Load element
       @elementKey = params[:elementKey]
       @attribute = params[:attribute]
       @attributeType = params[:attributeType]
       @dataDictionaryID = params[:dataDictionaryID]

       @element = keytechAPI.elements.load(@elementKey, {"attributes": :all})
       @field_value = @element.keyValueList[@attribute]

       if @dataDictionaryID != "0"
         # Load DD Field
         @dataDefinition = getDataDictionaryDefinition(@dataDictionaryID)
         @data = getDataDictionaryData(@dataDictionaryID)
         render 'forms/dataDictionary_editor', layout: "attribute_form"
         return
       end

       if @attributeType == "text"
         render 'forms/text_editor', layout: "attribute_form"
       end

       if @attributeType == "memo"
         render 'forms/textarea_editor', layout: "attribute_form"
       end

       if @attributeType == "double"
         render 'forms/number_editor', layout: "attribute_form"
       end

       if @attributeType == "check"
         render 'forms/check_editor', layout: "attribute_form"
       end

       if @attributeType == "date"
         @field_value = helpers.editorValueParser(@field_value)
         render 'forms/date_editor', layout: "attribute_form"
       end

    end

    def update_value_form
      if params[:cancel] == 'true'
        redirect_back(fallback_location: root_path)
      else
        elementKey = params[:elementKey]
        attribute = params[:attribute]
        value = params[attribute]
        dataDictionaryJson = params[:datadictionary]
        dataDictionaryID = params[:datadictionary_id]

        # Nicht alle beliebige Attribute füllen!
        # TODO: mache eine Liste mit Attribute, die nicht gehen: name, acl, alle Systematribute
        # as_.. ??

        # TODO: Validate - isNullable, type?

        element = @element = keytechAPI.elements.newElement(elementKey)
        if dataDictionaryID.blank?
          element.keyValueList[attribute] = value
        else
          dataDefinition = getDataDictionaryDefinition(dataDictionaryID)
          dataDefinition.each do |definition|
            if !definition.toTargetAttribute.blank?
                dataDictionaryValues = JSON.parse(dataDictionaryJson)
                element.keyValueList[definition.toTargetAttribute] = dataDictionaryValues[definition.attribute.to_s]
            end
          end
        end

        updated_element = keytechAPI.elements.update(element)
        # Save ok? If not create a warning and rebuild
        if updated_element.blank?
          logger.warn("Could not update element")
          flash[:warning] = "Konnte Element nicht aktualisieren."
          redirect_back(fallback_location: root_path)
          return
        else
          flash[:info] = "Element wurde aktualisiert."
          redirect_to element_show_path(id:updated_element.key)
          return
        end
      end
    end

    def checkserver
      server_check_result = current_user.hasValidConnection?
      render :json => {available: server_check_result}
    end

private

    def getDataDictionaryDefinition(ddID)
       Rails.cache.fetch("/datadictionary/#{ddID}", expires_in: 1.hours) do
         keytechAPI.dataDictionaries.getDefinition(ddID)
       end
    end

    def getDataDictionaryData(ddID)
       Rails.cache.fetch("/datadictionary/#{ddID}/data", expires_in: 1.hours) do
         keytechAPI.dataDictionaries.getData(ddID)
       end
    end

    def getclassDefinition(classKey)
     Rails.cache.fetch("#{classKey}", expires_in: 1.hours) do
         keytechAPI.classes.load(classKey);
     end
    end

    def getLayout(classKey)
      Rails.cache.fetch("#{classKey}/main_layout", expires_in: 1.hours) do
       keytechAPI.layouts.main_layout(classKey)
     end
    end

    def keytechAPI
      current_user.keytechAPI
    end
end
