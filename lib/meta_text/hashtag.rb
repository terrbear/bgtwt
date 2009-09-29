module MetaText
  module Hashtag
	  REGEX = /([^\w]|\s|^)(#\w+)/
	
	  def hashtags(text)
	    text.scan(Hashtag::REGEX).flatten.reject{|s| s.blank?}.uniq
	  end

    def populate_hashtag_links(text)
      text.gsub(MetaText::Hashtag::REGEX) do |match|
        "#{$1}\"#{$2}\":http://www.hashtags.org/tag/#{match[/\w+/].strip}"
      end
    end
    
    def populate_hashtag_links!(text)
      text.gsub!(MetaText::Hashtag::REGEX) do |match|
        "#{$1}\"#{$2}\":http://www.hashtags.org/tag/#{match[/\w+/].strip}"
      end
    end
	end
end
