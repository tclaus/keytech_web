class ElementsController < ApplicationController
  before_action :authenticate_user!

  # GET /elements, need a query for index
  # GET /users.json
  def index
    logger.info "Index of elements"
  end

  # GET /elements/1
  # GET /users/1.json
  def show
    logger.info "Show one element (get by id):  #{params[:id]}"
    set_element
    puts "loaded element: #{@element}"

    # redirect to View?
    # redirect to <controller ? 

  end

  private

  def keytechKit
    current_user.keytechKit
  end

  def set_element
    # Load element from API, or cache
    @element = keytechKit.elements.find(params[:id])
  end

end
