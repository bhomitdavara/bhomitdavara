class ApplicationController < ActionController::Base
  include ExceptionHandling
  include Pagy::Backend
  before_action :assign_env_variables

  def assign_env_variables
    gon.host = ENV['HOST']
  end

  def index
    render_404
  end
end
