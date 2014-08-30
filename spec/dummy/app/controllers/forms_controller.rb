class FormsController < ActionController::Base

  def forms
    @error = session[:error]
  end

end
