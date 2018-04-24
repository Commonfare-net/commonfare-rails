class ImagesController < ApplicationController
  load_and_authorize_resource :commoner
  load_and_authorize_resource :image, through: :commoner

  def create
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

  # def destroy
  #   @image.update(to_be_deleted: true) if @image.removed_from_all_locales?
  #   respond_to do |format|
  #     format.json { head :no_content }
  #   end
  # end

  private

  def image_params
    params.require(:image).permit(:picture, :imageable_id, :imageable_type)
  end
end
