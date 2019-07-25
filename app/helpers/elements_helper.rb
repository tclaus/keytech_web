module ElementsHelper

  def keytechAPI
    current_user.keytechAPI
  end

  def class_displayname(class_key)
    return 'Artikel' if class_key.casecmp('default_mi').zero?

    Rails.cache.fetch("#{class_key}/displayname", expires_in: 12.hours) do
      class_definition = current_user.keytechAPI.classes.load(class_key)
      class_definition.displayname
    end
  end

  # Translates a elementkey MISC_FILE:123 to a classkey: MISC_FILE
  def class_key(element_key)
    element_key.split(':').first
  end

  # Returns a String value of "DO","MI" or "FD" to indicate that the elementkey
  # refers to a Document, MasterItem or is a Folder
  def class_type(element_key)
    class_key = class_key(element_key)
    return 'MI' if class_key.upcase.end_with?('_MI')

    return 'FD' if class_key.upcase.end_with?('_FD', '_WF')

    'DO'
  end

  # Translates a value to a nice visible value
  def listerValueParser(element, attribute_name)
    # Check well known attributes
    return element.createdByLong if attribute_name == 'created_by'

    return element.changedByLong if attribute_name == 'changed_by'

    return element.displayname if attribute_name == 'displayname'

    if attribute_name == 'classname'
      return class_displayname(class_key(element.key))
    end

    # Check key value
    value = element.keyValueList[attribute_name]

    parse_value(value)
  end

  def parse_value(value)
    # {/Date(-3600000)/ => "-"
    if value.is_a? String
      return parse_date(value) if value.downcase.starts_with?('/date')
    end

    if value.is_a? String
      value.strip
    else
      value
    end
  end

  # Returns a german localized datetime
  def parse_date(date_str)
    # /Date(-3600000)/
    # /Date(1407103200000)/

    # get numeric value
    numeric_value = date_str[6..-3].to_i
    # Placeholder for empty date
    return '' if numeric_value == -3_600_000 || numeric_value == 0

    date = Time.at(numeric_value / 1000)
    date.strftime('%d.%m.%Y')
  end
end
