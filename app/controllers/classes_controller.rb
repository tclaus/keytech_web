class ClassesController < ApplicationController
  before_action :authenticate_user!

  def class_list
    # Load classes
    classes = keytechAPI.classes
    @classlist = classes.loadAllClasses
  end

end
