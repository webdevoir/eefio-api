# TODO: why doesn’t this autoload from /app/lib
class String
  # Usage: '0xACAB'.from_hex #=> 44203
  def from_hex
    to_i 16
  end
end

# TODO: why doesn’t this autoload from /app/lib
class Integer
  # Usage: 8675309.to_hex #=> 0x845fed
  def to_hex
    '0x' + to_s(16)
  end
end

class TransactionExtractorService
  # TODO: write this!
end
