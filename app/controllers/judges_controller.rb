class JudgesController < ApplicationController

  def stats
    @stats = Judge.stats
  end

  def index
    @filterrific = initialize_filterrific(
        Judge,
        params[:filterrific]
    ) or return
    @judges= @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end
  end

end
