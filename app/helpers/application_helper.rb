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

  def sort_column
    params[:column]
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  # Sort links for tables
  def sort_link(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    icon = sort_direction == 'asc' ? 'fas fa-caret-up' : 'fas fa-caret-down'
    icon = column == sort_column ? icon : ''

    parameter = params.permit(:id, :q, :classes, :byquery, :column, :direction).merge(column: column, direction: direction)
    link_to "#{title} <i class='#{icon}'></i>".html_safe,  parameter
  end
end
