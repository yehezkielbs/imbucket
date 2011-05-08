class Image < ActiveRecord::Base
  has_attached_file(
    :image,
    :styles => {
      :thumbnail => '80x60>',
      :small  => '320x240>',
      :medium => '800x600>'
    },
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :s3_permissions => :private,
    :path => ':id/:style/:filename',
    :s3_protocol => 'https',
    :processors => [:rotator]
  )

  attr_accessor :rotation, :rotate

  before_create :set_defaults

  validates_presence_of :image_creation_date, :image_file_name
  validates_presence_of :image_file_name

  def rotate!(degrees = 90)
    self.rotation ||= 0
    self.rotation += degrees
    self.rotation -= 360 if self.rotation >= 360
    self.rotation += 360 if self.rotation <= -360

    self.rotate = true
    self.image.reprocess!
    self.save
  end

  def rotating?
    !self.rotation.nil? and self.rotate
  end

  def authenticated_image_url(style = nil, expires_in = 30.minutes)
    AWS::S3::S3Object.url_for(
      image.path(style || image.default_style),
      image.bucket_name,
      :expires_in => expires_in,
      :use_ssl => image.s3_protocol == 'https'
    )
  end

  def self.identify_and_new uploaded_image
    params = {:image => uploaded_image}

    exif = EXIFR::JPEG.new(uploaded_image.tempfile.path)
    params[:image_creation_date] = exif.respond_to?(:date_time) ? exif.date_time : Time.now

    new(params)
  end

  def self.creation_dates
    image_creation_dates.map do |image|
      image.image_creation_date.to_date
    end.sort {|a,b| b <=> a }
  end

  def self.creation_dates_with_latest_upload
    now = DateTime.now
    image_creation_dates.image_uploaded_between(now - 1, now).map do |image|
      image.image_creation_date.to_date
    end
  end

  scope :image_created_on, lambda { |date|
    date_only = date.to_date
    where('image_creation_date between ? and ?', date_only, (date_only + 1))
  }

  scope :image_uploaded_between, lambda { |start_date, end_date|
    start_date_only = start_date.to_date
    end_date_only = end_date.to_date
    where('created_at between ? and ?', start_date_only, (end_date_only + 1))
  }

  scope :image_creation_dates, lambda {
    select('DISTINCT(DATE(image_creation_date)) as image_creation_date')
  }

  scope :recent_first, lambda {
    order('image_creation_date DESC')
  }

  private

  def set_defaults
    self.rotation ||= 0
  end
end
