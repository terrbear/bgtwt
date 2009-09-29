module MetaText
  module Twitter
    NAME_REGEX = /([^\w]|\s|^)@\w+/

    def populate_twitter_links(text)
      text.gsub(MetaText::Twitter::NAME_REGEX) do |match|
        "#{$1}\"#{match[/@\w+/].strip}\":http://www.twitter.com/#{match[/\w+/].strip}"
      end
    end
    
    def populate_twitter_links!(text)
      text.gsub!(MetaText::Twitter::NAME_REGEX) do |match|
        "#{$1}\"#{match[/@\w+/].strip}\":http://www.twitter.com/#{match[/\w+/].strip}"
      end
    end
  end
end
