module ElementsHelper


  # Translates a elementkey MISC_FILE:123 to a classkey: MISC_FILE
  def classkey(elementKey)
    classKey.split(':').first
  end

  # Translates a value to a nice visible value
  def valueParser(value)
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
    puts "date: #{dateString}, numeric value = #{numeric_value}"
    # Placeholder for empty date
    if numeric_value == -3600000 || numeric_value == 0
      return ""
    end
    date = Time.at(numeric_value / 1000)
    date.strftime("%d.%m.%Y")
  end

end
