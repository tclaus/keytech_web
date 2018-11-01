require 'fileutils'

class FileuploadController < ApplicationController
  def file_upload
    # Check for parameter where to attachment
    # Only masterfiles can be uploadedBytes
    # check and directly stream to api

    element_key = params[:elementKey]
    files = params[:files]
    tempfile = files.tempfile

    # put this in a background thread!
    logger.info "Upload masterfile for: #{element_key} to keytech API started"
    masterfile_result = keytechAPI.files.uploadMasterFile(element_key, tempfile, files.original_filename)
    tempfile.rewind
    logger.info "Upload masterfile complete! #{masterfile_result.inspect}"

    # create image thumbnail
    create_thumbnail_result = create_image_thumbnail(tempfile)
    tempfile.rewind
    if create_thumbnail_result[:success]
      logger.info "Upload preview file"
      thumbnail_result = keytechAPI.files.uploadQuickPreviewFile(element_key, create_thumbnail_result[:filename], files.original_filename)
      logger.info "Thumbnail upload result: #{thumbnail_result.inspect}"
      # Invalid cache!
    end

    # Set an answer that image is loaded
    render(json: to_fileupload(masterfile_result, files.original_filename), content_type: request.format)
  end

  # TODO: get valid response here!
  def to_fileupload(result, filename)
    {
        success: result[:success],
        error: result[:error],
        name: filename
    }
  end

  private

  # Creates and stores a tumbnail tempfile for image types
  def create_image_thumbnail(image_file)
    file_data = image_file.read
    if Lizard::Image.is_image?(file_data)
      logger.debug ' Image detected'
      image = Lizard::Image.new(file_data)
      thumbnail_data = image.resize(800, 600)

      basename = File.basename(image_file.path)
      temp_filename = Rails.root.join("tmp/thumbnail-#{basename}")
      File.open(temp_filename, 'wb') do |f|
        f.write(thumbnail_data.data)
      end

      logger.debug " Created a thumbnail. Filename: #{temp_filename}"
      { success: true, filename: temp_filename }
    else
      logger.info ' This is no image filetype. Can not create a thumbnail'
      { success: false, error: 'this is not an image file' }
    end
  end

  def keytechAPI
    current_user.keytechAPI
  end
end
