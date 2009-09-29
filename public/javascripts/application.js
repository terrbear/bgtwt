// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function firehose_json(data) {
  $.each(data, function(i, item) {
    container = $("<div/>");
    container.attr("style", "clear:both");

    tweet = $("<div/>");
    tweet.attr("class", "firehose_tweet");

    tweet.text(item.tweet.body);

    pic_div = $("<div/>").attr("class", "firehose_type");
    permalink = $("<a/>").attr("href", item.tweet.permalink).attr("target", "_new");

    if(item.tweet.author != null) {
      author_div = $("<div/>").attr("class", "firehose_toolbar").attr("style", "text-align: right;");
      author_div.text("by " + item.tweet.author.handle);
      tweet.append(author_div);
    }

    pic = $("<img/>").attr("height", "45").attr("width", "45");

    if(item.tweet.parent_id === 0) {
      pic.attr("src", "/images/parent.png");
    } else {
      pic.attr("src", "/images/reply.png");
    }
    permalink.append(pic);
    pic_div.append(permalink);

    container.append(pic_div);
    container.append(tweet)

    container.prependTo('#firehose').dropIn("slow");
  });
}
