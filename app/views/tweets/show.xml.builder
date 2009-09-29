xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title("Bgtwt: for when your thoughts exceed 140 characters.")
    xml.link(@tweet.permalink)
    xml.description("Bgtwt: #{super_short(@tweet)}")
    xml.language('en-us')
      xml.item do
          xml.title(!@tweet.title.nil? ? @tweet.title : "#{@tweet.body[0, 25]} ...")
          xml.description(filter_body(@tweet.body))      
          xml.author(@tweet.author_name)               
          xml.pubDate(@tweet.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.link(@tweet.permalink)
          xml.guid(@tweet.permalink)
      end
      for post in @replies
        xml.item do
          xml.title(!post.title.nil? ? post.title : "#{post.body[0, 25]} ...")
          xml.description(filter_body(post.body))      
          xml.author(post.author_name)               
          xml.pubDate(post.created_at.strftime("%a, %d %b %Y %H:%M:%S %z"))
          xml.link(post.permalink)
          xml.guid(post.permalink)
        end
      end
  }
}
