class ImagesController < ApplicationController
  def new
    @image = Image.new
  end

  def create
    swf_uploaded_data = params[:Filedata]

    @image = Image.find_by_image_file_name(swf_uploaded_data.original_filename)

    unless @image
      swf_uploaded_data.content_type = MIME::Types.type_for(swf_uploaded_data.original_filename)
      @image = Image.identify_and_new(swf_uploaded_data)
      @image.save!
    end

    render(:text => @image.authenticated_image_url(:thumbnail))
  end

  def index
    @dates = Image.creation_dates
    @dates_with_recent_upload = Image.creation_dates_with_latest_upload
  end

  def list_by_date
    @date = Date.parse(params[:date])
    @dates = Image.creation_dates
    @dates_with_recent_upload = Image.creation_dates_with_latest_upload
    @images = Image.image_created_on(@date).recent_first
    @show_buttons = (params[:buttons] == 'true')
  end

  def show
    @image = Image.find(params[:id])
  end

  def destroy
    @image_id = params[:id]
    image = Image.find(@image_id)

    list_url = images_by_date_path(:date => image.image_creation_date.strftime('%F'))

    image.image.destroy
    image.image.clear
    image.delete

    if request.xhr?
      render
    else
      redirect_to(list_url)
    end
  end

  def rotate
    @image = Image.find(params[:id])
    rotation = params[:deg].to_f
    rotation ||= 90

    @image.rotate!(rotation)
  end
end
