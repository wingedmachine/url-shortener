require 'test_helper'

RSpec.describe ShortUrl do
  it "correctly encodes indices" do
    expect(ShortUrl.encode_index(1)).to eq("1")
    expect(ShortUrl.encode_index(49)).to eq("Z")
    expect(ShortUrl.encode_index(50)).to eq("10")
    expect(ShortUrl.encode_index(147904)).to eq("1984")
  end

  it "correctly decodes indices" do
    expect(ShortUrl.decode_index("1")).to eq(1)
    expect(ShortUrl.decode_index("Z")).to eq(49)
    expect(ShortUrl.decode_index("10")).to eq(50)
    expect(ShortUrl.decode_index("1984")).to eq(147904)
  end
end