class Ringtone < ActiveRecord::Base
  validates :song, presence: true

  has_attached_file :source
  validates_attachment_content_type :source, :content_type =>  /\Aaudio\/(x-)?(mpeg|mp3|m4a|aac|mp2|wav|wma|ogg)/

  has_attached_file :ringtone,
                    :styles => { android: { format: :mp3 },
                                 iphone: { format: :m4r } },
                    :processors => [:audio]
  validates_attachment_content_type :ringtone, :content_type => /\Aaudio\/(x-)?(mpeg|mp3)/

  delegate :url, to: :ringtone

  after_commit :create_ringtone, on: :create


  def name
    [song, artist].compact.join(" - ")
  end

  def create_ringtone
    RingtoneCropWorker.perform_async(id)
  end
end
