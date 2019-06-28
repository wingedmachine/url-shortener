class ShortUrlsController < ApplicationController
  def new
    @short_url = ShortUrl.new
  end

  def create
    if @short_url = ShortUrl.create(url: short_url_params[:url])
      flash[:shrink_amount] = "Your #{@short_url.url.length} character url has "\
        "been shrunk down to be only #{@short_url.short.length} characters!"
      flash[:short_url] = "#{request.base_url}/#{@short_url.short}"
    else
      flash.alert = @short_url.errors.full_messages.to_sentence
    end
    redirect_to root_path
  end

  def redirect
    @url = ShortUrl.lengthen(params[:shortened_url])
    @url ? (redirect_to @url) : (
      flash.alert = "Sorry, but we don't recognize that shortened url."
      redirect_to root_path
    )
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url)
  end
end
