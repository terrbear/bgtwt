module MetaText
  module Link
    LINK_REGEX = /(^|\s)(http:\/\/(\w|\.|\/)+)/

    def populate_links(text)
      text.gsub(MetaText::Link::LINK_REGEX, '\1"\2":\2')
    end
    
    def populate_links!(text)
      text.gsub!(MetaText::Link::LINK_REGEX, '\1"\2":\2')
    end
  end
end
