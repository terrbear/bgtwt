module Base62
  SIXTYTWO = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
  
  module Numeric
    def to_62
      i = self
		  return '0' if i == 0
		  s = ''
		  while i > 0
		    s << Base62::SIXTYTWO[i.modulo(62)]
		    i /= 62
		  end
		  s.reverse
    end
  end

  module String
    def from_62
		  power = 0
		  digits = self.scan(/./).map{|i| Base62::SIXTYTWO.index(i)}
		  sum = 0
		  while digit = digits.pop
		    sum += digit * (62 ** power)
		    power += 1
		  end
		  sum
    end
  end
end

Numeric.send(:include, Base62::Numeric)
String.send(:include, Base62::String)
