module ElementsHelper


  # Translates a elementkey MISC_FILE:123 to a classkey: MISC_FILE
  def classkey(elementKey)
    classKey.split(':').first
  end
end
