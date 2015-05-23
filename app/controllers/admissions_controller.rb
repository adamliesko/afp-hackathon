class AdmissionsController < ApplicationController

  def index
  @filterrific = initialize_filterrific(
    Admission,
    params[:filterrific]
  ) or return
  @students = @filterrific.find.page(params[:page])

  respond_to do |format|
    format.html
    format.js
  end
  end

end
