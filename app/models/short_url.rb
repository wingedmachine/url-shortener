class ShortUrl < ApplicationRecord
  # This character set contains no vowels so that no words will be generated, 
  # preventing the shortened url from being something like /fuck
  SHORT_URL_CHARS = "0123456789bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ".chars
  CHECKSUM_LEN = 2

  def self.shorten(url_id)
    # There's no check here to see if a url already has a short version. This
    # was a conscious trade-off of decreased efficiency for increased user privacy
    short_url = self.encode(url_id)
    short_url << self.calc_simple_checksum(self.find_by(id: url_id).url)
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
    url_id = self.decode(short_url[0..(-CHECKSUM_LEN-1)])
    url = self.find_by(id: url_id)&.url
    
    return false unless url

    self.calc_simple_checksum(url) == short_url[-CHECKSUM_LEN..-1] ? url : false
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
