class JudgesController < ApplicationController

  def stats
    @stats = Judge.stats
  end

  def show
    @judge = Judge.find(params[:id])
  end

  def index
 @filterrific = initialize_filterrific(
      Judge,
      params[:filterrific],
      select_options: {
        sorted_by: Judge.options_for_sorted_by,
      },
      
    ) or return
    @judges= @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

end
