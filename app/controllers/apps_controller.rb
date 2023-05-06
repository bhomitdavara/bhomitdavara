class AppsController < ApplicationController
  layout false
  def about
    @content = About.first.text
  end

  def policy
    @content = Policy.first.text
  end

  def terms; end
end