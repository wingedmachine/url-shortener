class ShortUrlsController < ApplicationController
  def new
    @short_url = ShortUrl.new
  end

  def create
  end

  def redirect
    @url = ShortUrl.lengthen(params[:shortened_url])
    @url ? (redirect_to @url) : (render "new")
  end
end
