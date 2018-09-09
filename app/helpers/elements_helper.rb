
module ElementsHelper


  def displayNameForClass(classKey)
    # Cache for classkey
    classDefinition = current_user.keytechKit.classes.load(classKey)
    classDefinition.displayname
  end

  # Translates a elementkey MISC_FILE:123 to a classkey: MISC_FILE
  def classkey(elementKey)
    classKey.split(':').first
  end

  def editorValueParser(value)
    parseValue(value)
  end

  # Translates a value to a nice visible value
  def listerValueParser(element, attribute_name)

    # Check well known attributes
    if attribute_name == "created_by"
      return element.createdByLong
    end

    if attribute_name == "changed_by"
      return element.changedByLong
    end

    if attribute_name == "displayname"
      return element.displayname
    end

    if attribute_name == "classname"
      return element.classDisplayName
    end

    # Check key value
    value = element.keyValueList[attribute_name]

    parseValue(value)
  end

  def findValue()
  end


  def parseValue(value)
    #{/Date(-3600000)/ => "-"
    if value.is_a? String
      if value.downcase.starts_with?('/date')
        return dateParser(value)
      end
    end
    value
  end

 # Returns a german localized datetime
  def dateParser(dateString)
    # /Date(-3600000)/
    # /Date(1407103200000)/

    # get numeric value
    numeric_value = dateString[6..-3].to_i
    # Placeholder for empty date
    if numeric_value == -3600000 || numeric_value == 0
      return ""
    end
    date = Time.at(numeric_value / 1000)
    date.strftime("%d.%m.%Y")
  end

end
