class FileuploadController < ApplicationController
  def file_upload
    # Check for parameter where to attachment
    # Only masterfiles can be uploadedBytes
    # check and directly stream to api

    element_key = params[:elementKey]
    files = params[:files]

    puts "Upload for: #{element_key} to keytech API started"
    result = keytechAPI.files.uploadMasterFile(element_key, files.tempfile, files.original_filename)
    puts "Upload complete! #{result.inspect}"

    render(json: to_fileupload(files.original_filename), content_type: request.format)
  end

  # TODO: get valid response here!
  def to_fileupload(attachment_name)
    {
      files: [
        {
          id:   42,
          name: attachment_name
        }
      ]
    }
  end

  private
  def keytechAPI
    current_user.keytechAPI
  end
end
