class ShortUrl < ApplicationRecord
  validates_each :url do |record, attr, value| 
    record.errors.add(attr, "must begin with http:// or https://") unless value.starts_with?("http://", "https://")
  end

  def initialize(attributes = {})
    if attributes
      @url = attributes[:url]
      self.sanitize_url
      if @url
        self.ensure_protocol_presence
        attributes[:url] = @url
      end
    end
    super(attributes)
  end

  # For a real commercial product, I would do much more extensive testing of 
  # this to avoid XSS, but that gets complicated quickly. This implementation 
  # will suffice for our purposes.
  # (see: https://www.owasp.org/index.php/XSS_Filter_Evasion_Cheat_Sheet)
  def sanitize_url
    anchor_start = "<a href=\""
    anchor_end = "\">.</a>"

    anchor = ActionController::Base.helpers.sanitize("#{anchor_start}#{@url}#{anchor_end}")
    @url = anchor[anchor_start.length .. -(anchor_end.length + 1)]
  end

  def ensure_protocol_presence
    @url = @url.prepend("http://") unless @url.starts_with?("http://", "https://")
  end

  # This character set contains no vowels so that no words will be generated, 
  # preventing the shortened url from being something like /fuck

  # The choice of 37 is arbitrary, but specifying a seed means that the shuffle 
  # will always give the same result. If the seed is changed, all previously 
  # shortened urls will stop working.
  SHORT_URL_CHARS = "0123456789bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ".chars.shuffle(random: Random.new(37))
  CHECKSUM_LEN = 2

  def short
    # There's no check here to see if a url already has a short version. Storage is cheap, and while 
    # I can't imagine what harm could come of it, there's no sense in freely telling anyone who asks 
    # whether a site has already been given a shortened url.
    short_url = self.class.encode(self.id)
    short_url << self.class.calc_simple_checksum(self.url)
  end

  def self.encode(n)
    base = SHORT_URL_CHARS.size

    output = ""
    while n > 0
      output.prepend(SHORT_URL_CHARS[n.modulo(base)])
      n /= base
    end
    output
  end

  def self.lengthen(short_url)
    return false unless self.validate_simply(short_url)

    url_id = self.decode(short_url[0..(-CHECKSUM_LEN-1)])
    url = self.find_by(id: url_id)&.url
    
    return false unless url

    self.validate_with_checksum(url, short_url) ? url : false
  end

  def self.validate_simply(short_url)
    short_url.size >= 1 + CHECKSUM_LEN && !short_url.chars.detect { |c| !SHORT_URL_CHARS.include?(c) }
  end

  def self.validate_with_checksum(url, short_url)
    self.calc_simple_checksum(url) == short_url[-CHECKSUM_LEN..-1]
  end

  def self.decode(s)
    base = SHORT_URL_CHARS.size

    i = 0
    s.each_char { |c| i = i * base + SHORT_URL_CHARS.index(c) }
    i
  end

  def self.calc_simple_checksum(url)
    # This isn't a particularly good method of creating a checksum, but it's simple, 
    # and its primary purpose is to keep shortened urls from being trivially discoverable.
    # Limiting it to two digits keeps shortened urls short, and using a large radix helps
    # reduce collisions and prevent brute-forcing. It is, however, in no way secure.
    self.encode(url.sum).rjust(CHECKSUM_LEN, "0")[-CHECKSUM_LEN..-1]
  end
end
