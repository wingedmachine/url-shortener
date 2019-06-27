class ShortUrlsController < ApplicationController
  def new
  end

  def create
  end

  def redirect
    @url = ShortUrl.lengthen(params[:shortened_url])
    render "new" unless @url

    puts @url
  end
end
