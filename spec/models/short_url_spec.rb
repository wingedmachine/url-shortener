require 'test_helper'

RSpec.describe ShortUrl do
  it "correctly encodes indices" do
    expect(ShortUrl.encode_index(1)).to eq("1")
    expect(ShortUrl.encode_index(49)).to eq("Z")
    expect(ShortUrl.encode_index(50)).to eq("10")
    expect(ShortUrl.encode_index(147904)).to eq("1984")
  end
end