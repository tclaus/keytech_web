module ApplicationHelper

  # default page title
  def page_title
    'PLM-Web'
  end

  def meta_tag(tag, text)
    content_for :"meta_#{tag}", text[0..100]
  end

  # Sets meta tags in page header
  def yield_meta_tag(tag, default_text = '')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end

end
