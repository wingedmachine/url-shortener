class ShortUrl < ApplicationRecord
  # This character set contains no vowels so that no words will be generated, 
  # preventing the shortened url from being something like /fuck
  SHORT_URL_CHARS = "0123456789bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ".chars

  def encode
    encode_index
    add_checksum
  end

  def decode
    remove_checksum
    decode_index
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

  def self.decode_index
  end
end
