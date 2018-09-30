
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

private

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
