class MediaService < ApplicationService

  def upload_media(image, folder_name)
    save_media(image, folder_name)
  end

  def upload_multiple_media(media, folder_name)
    if media.content_type.include?('image')
      folder_path = "#{folder_name}/images"
    elsif media.content_type.include?('video')
      folder_path = "#{folder_name}/videos"
    else
      folder_path = "#{folder_name}/audios"
    end
  
    if media.content_type.include?('image')
      save_media(media,  folder_path)
    else
      # movie = FFMPEG::Movie.new(tempfile_path)
      # movie.transcode(filename, { quality: 2 })
      # attachements << { filename: filename, io: File.open(filename), key: "#{path}/#{DateTime.now.to_i}_admin_#{filename}" }
      # File.delete(filename) if File.exist?(filename)
      save_media(media, folder_path, false)
    end
  end

  def upload_media_via_api(media, folder_name, user_name)
    if media['c_type'].include?('image')
      path = "#{folder_name}/images"
    elsif media['c_type'].include?('video')
      path = "#{folder_name}/videos"
    else
      path = "#{folder_name}/audios"
    end

    path = "staging/#{path}" unless Rails.env.production?
    filename = media['filename'].gsub(/:/, "-")

    return {
      io: StringIO.new(Base64.decode64(media['base64'])),
      content_type: media['c_type'],
      filename: filename,
      key: "#{path}/#{DateTime.now.to_i}_#{user_name}_#{filename}"
    }
  end

  def tempfile_path(image)
    "#{image.tempfile.inspect}".gsub(/#<Tempfile:/,'').gsub(/>/,'')
  end

  def save_media(media, upload_path, compress = true)
    filename = media.original_filename
    path = tempfile_path(media)
    key = "#{upload_path}/#{DateTime.now.to_i}_#{filename}"
    key = "staging/#{key}" unless Rails.env.production?
    file_path = path
    
    if compress
      file_path = MiniMagick::Image.open(path)
      file_path.quality '50'
    end

    if compress
      io = open(file_path.tempfile)
    else
      io = open(media.tempfile)
    end
    { filename: filename, io: io, key: key }
  end
end

