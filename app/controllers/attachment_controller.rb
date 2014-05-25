# The simplest thing that could possibly work.
class Attachment < ActiveRecord::Base
  before_save :store_metadata, :if => :store_file?
  after_save :store_file, :if => :store_file?

  # Virtual attribute that stores the uploaded tempfile
  attr_accessor :uploaded_file

  private

  def initialize a
    :uploaded_file = a
  end

  def store_metadata
    self.original_filename  = uploaded_file.original_filename
    self.size               = uploaded_file.size
    self.content_type       = uploaded_file.content_type
    self.filename           = Digest::SHA1.hexdigest(Time.now.to_s) + self.original_filename
  end

  def store_file
    File.open(file_storage_location, "w") {|f| f.write uploaded_file.read }
  end

  def store_file?
    !uploaded_file == nil
  end

  def file_storage_location
    File.join(Rails.root, 'public', 'attachments', self.filename)
  end
end