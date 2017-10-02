class ImagesController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :image, through: :commoner

  def create
    sdfs
    @image = Image.new(image_params)
    @image.commoner = @commoner
    respond_to do |format|
      if @image.save
        format.json { render 'show' }
      else
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @image.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def image_params
    params.require(:image).permit(:picture)
  end
end
