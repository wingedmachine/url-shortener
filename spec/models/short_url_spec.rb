require 'test_helper'

RSpec.describe ShortUrl do
  before(:all) do
    @source = ShortUrl.create!(url: "https://github.com/wingedmachine/url-shortener")
  end

  after(:all) do
    @source.destroy
  end

  it "encodes" do
    expect(ShortUrl.encode(1)).to eq("K")
    expect(ShortUrl.encode(49)).to eq("h")
    expect(ShortUrl.encode(50)).to eq("KZ")
    expect(ShortUrl.encode(147904)).to eq("K4FP")
  end

  it "decodes" do
    expect(ShortUrl.decode("1")).to eq(12)
    expect(ShortUrl.decode("Z")).to eq(0)
    expect(ShortUrl.decode("10")).to eq(603)
    expect(ShortUrl.decode("1984")).to eq(1514359)
  end

  it "calculates checksums" do
    expect(ShortUrl.calc_simple_checksum(@source.url)).to eq("pZ")
  end

  it "shortens" do
    expect(ShortUrl.shorten(@source.id)).to eq(ShortUrl.encode(@source.id) + ShortUrl.calc_simple_checksum(@source.url))
  end

  it "lengthens" do
    expect(ShortUrl.lengthen(ShortUrl.shorten(@source.id))).to eq(@source.url)
  end

  it "returns false when attempting to lengthen an invalid short url" do
    expect(ShortUrl.lengthen("1")).to eq(false) #too short
    expect(ShortUrl.lengthen("ball")).to eq(false) #invalid character "a"
    expect(ShortUrl.lengthen("bell")).to eq(false) #invalid character "e"
    expect(ShortUrl.lengthen("bill")).to eq(false) #invalid character "i"
    expect(ShortUrl.lengthen("bowl")).to eq(false) #invalid character "o"
    expect(ShortUrl.lengthen("bull")).to eq(false) #invalid character "u"
    expect(ShortUrl.lengthen("syzygy")).to eq(false) #invalid character "y"
    expect(ShortUrl.lengthen("qwrt.jpg")).to eq(false) #invalid character "."
    expect(ShortUrl.lengthen("mnbv/lkj")).to eq(false) #invalid character "/"
  end
end