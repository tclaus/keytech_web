module ElementsHelper
  def displayNameForClass(classKey)
    if classKey.casecmp('default_mi').zero?
      return 'Artikel' # TODO: translate
    end

    Rails.cache.fetch("#{classKey}/displayname", expires_in: 12.hours) do
      classDefinition = current_user.keytechAPI.classes.load(classKey)
      classDefinition.displayname
    end
  end

  # Translates a elementkey MISC_FILE:123 to a classkey: MISC_FILE
  def classKey(elementKey)
    elementKey.split(':').first
  end

  # Returns a String value of "DO","MI" or "FD" to indicate that the elementkey refers to a Document, MasterItem or is a Folder
  def classType(elementKey)
    classKey = self.classKey(elementKey)
    return 'MI' if classKey.upcase.end_with?('_MI')

    return 'FD' if classKey.end_with?('_FD', '_WF')

    'DO'
  end

  def editorValueParser(value)
    parseValue(value)
  end

  # Translates a value to a nice visible value
  def listerValueParser(element, attribute_name)
    # Check well known attributes
    return element.createdByLong if attribute_name == 'created_by'

    return element.changedByLong if attribute_name == 'changed_by'

    return element.displayname if attribute_name == 'displayname'

    if attribute_name == 'classname'
      return displayNameForClass(classKey(element.key))
    end

    # Check key value
    value = element.keyValueList[attribute_name]

    parseValue(value)
  end

  def findValue; end

  def parseValue(value)
    # {/Date(-3600000)/ => "-"
    if value.is_a? String
      return dateParser(value) if value.downcase.starts_with?('/date')
    end

    if value.is_a? String
      value.strip
    else
      value
    end
  end

  # Returns a german localized datetime
  def dateParser(dateString)
    # /Date(-3600000)/
    # /Date(1407103200000)/

    # get numeric value
    numeric_value = dateString[6..-3].to_i
    # Placeholder for empty date
    return '' if numeric_value == -3_600_000 || numeric_value == 0

    date = Time.at(numeric_value / 1000)
    date.strftime('%d.%m.%Y')
  end
end
