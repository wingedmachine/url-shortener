class ShortUrl < ApplicationRecord
  # This character set contains no vowels so that no words will be generated, 
  # preventing the shortened url from being something like /fuck
  SHORT_URL_CHARS = "0123456789bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ".chars

  def encode
    self.class.encode_index(self.index)
    get_checksum(self.url)
  end

  def decode
    remove_checksum
    self.class.decode_index
  end

  def self.encode_index(n)
    base = SHORT_URL_CHARS.size

    output = ""
    while n > 0
      output.prepend(SHORT_URL_CHARS[n.modulo(base)])
      n /= base
    end
    output
  end

  def self.decode_index(s)
    base = SHORT_URL_CHARS.size
    
    i = 0
    s.each_char { |c| i = i * base + SHORT_URL_CHARS.index(c) }
    i
  end
end
