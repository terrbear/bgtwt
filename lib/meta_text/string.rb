module MetaText
  module String
    include MetaText::Link
    include MetaText::Hashtag
    include MetaText::Twitter

    def meta_filter
      dup.meta_filter!
    end

    def meta_filter!
      populate_links!(self)
      populate_hashtag_links!(self)
      populate_twitter_links!(self)
      self
    end
  end
end

String.send(:include, MetaText::String)
