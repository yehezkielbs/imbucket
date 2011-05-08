module Paperclip
  class Rotator < Thumbnail
    def transformation_command
      if rotate_command
        # having the "super" at the end ensures that your thumbnails are allways "inside the limits of your styles"
        rotate_command + super
      else
        super
      end
    end

    def rotate_command
      target = @attachment.instance
      if target.rotating?
        [convert_options = "-rotate #{target.rotation}"]
      end
    end
  end
end
