require 'digest-crc/crc32'

module Fossilize
  module Delta
    def digit_count(v)
      i, x = 1, 64
      while v >= x
        i += 1
        x = x << 6
      end
    end

    def checksum(zIn, zSize)
      sum0, sum1, sum2, sum3 = 0

      while zSize >= 16
        sum0 += (z[0] + z[4] + z[8] + z[12])
        sum1 += (z[1] + z[5] + z[9] + z[13])
        sum2 += (z[2] + z[6] + z[10]+ z[14])
        sum3 += (z[3] + z[7] + z[11]+ z[15])
        zIn += 16
        zSize -= 16
      end
    end
  end
end
