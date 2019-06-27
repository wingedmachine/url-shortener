require 'test_helper'

RSpec.describe ShortUrl do
  before(:all) do
    @source = ShortUrl.create!(url: "https://github.com/wingedmachine/url-shortener")
  end

  after(:all) do
    @source.destroy
  end

  it "encodes" do
    expect(ShortUrl.encode(1)).to eq("1")
    expect(ShortUrl.encode(49)).to eq("Z")
    expect(ShortUrl.encode(50)).to eq("10")
    expect(ShortUrl.encode(147904)).to eq("1984")
  end

  it "decodes" do
    expect(ShortUrl.decode("1")).to eq(1)
    expect(ShortUrl.decode("Z")).to eq(49)
    expect(ShortUrl.decode("10")).to eq(50)
    expect(ShortUrl.decode("1984")).to eq(147904)
  end

  it "calculates checksums" do
    expect(ShortUrl.calc_simple_checksum(@source.url)).to eq("P0")
  end

  it "shortens" do
    expect(ShortUrl.shorten(@source.id)).to eq(ShortUrl.encode(@source.id) + ShortUrl.calc_simple_checksum(@source.url))
  end

  it "lengthens" do
    expect(ShortUrl.lengthen(ShortUrl.shorten(@source.id))).to eq(@source.url)
  end
end