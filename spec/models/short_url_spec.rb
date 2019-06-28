require 'test_helper'

RSpec.describe ShortUrl do
  before(:all) do
    @source = ShortUrl.create!(url: "https://github.com/wingedmachine/url-shortener")
  end

  after(:all) do
    ShortUrl.destroy_all
  end

  it "ensures url begins with http or https" do
    expect(ShortUrl.new(url: "http://test1").url).to eq("http://test1")
    expect(ShortUrl.new(url: "https://test2").url).to eq("https://test2")
    expect(ShortUrl.new(url: "test3").url).to eq("http://test3")
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
    expect(@source.short).to eq(ShortUrl.encode(@source.id) + ShortUrl.calc_simple_checksum(@source.url))
  end

  it "lengthens" do
    expect(ShortUrl.lengthen(@source.short)).to eq(@source.url)
  end

  it "returns false when attempting to lengthen an invalid short url" do
    expect(ShortUrl.lengthen("1")).to eq(false) #too short
    expect(ShortUrl.lengthen("ball")).to eq(false) #invalid character "a"
    expect(ShortUrl.lengthen("bell")).to eq(false) #invalid character "e"
    expect(ShortUrl.lengthen("bill")).to eq(false) #invalid character "i"
    expect(ShortUrl.lengthen("boll")).to eq(false) #invalid character "o"
    expect(ShortUrl.lengthen("bull")).to eq(false) #invalid character "u"
    expect(ShortUrl.lengthen("byrl")).to eq(false) #invalid character "y"
    expect(ShortUrl.lengthen("BALL")).to eq(false) #invalid character "A"
    expect(ShortUrl.lengthen("BELL")).to eq(false) #invalid character "E"
    expect(ShortUrl.lengthen("BILL")).to eq(false) #invalid character "I"
    expect(ShortUrl.lengthen("BOLL")).to eq(false) #invalid character "O"
    expect(ShortUrl.lengthen("BULL")).to eq(false) #invalid character "U"
    expect(ShortUrl.lengthen("BYRL")).to eq(false) #invalid character "Y"
    expect(ShortUrl.lengthen("qwrt.jpg")).to eq(false) #invalid character "."
    expect(ShortUrl.lengthen("mnbv/lkj")).to eq(false) #invalid character "/"
  end

  it "returns false when attempting to lengthen a short url with an invalid checksum" do
    expect(ShortUrl.lengthen("#{ShortUrl.encode(@source.id)}00")).to eq(false)
  end
end