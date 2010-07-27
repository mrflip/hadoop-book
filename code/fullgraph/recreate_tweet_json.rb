#!/usr/bin/env ruby
require 'wukong'
require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model

#
# Digging the original tweets out of cold storage would be impossible, so here
# is a script to dummy up a JSON tweet from the infochimps internal format.
#
#
#

BARE_TWEET = {
  "text"                           => "",
  "truncated"                      => false,
  "in_reply_to_status_id"          => nil,
  "source"                         => "",
  "in_reply_to_screen_name"        => nil,
  "favorited"                      => false,
  "contributors"                   => nil,
  "created_at"                     => "",
  "in_reply_to_user_id"            => nil,
  "id"                             => nil,
  "coordinates"                    => nil,
  "place"                          => nil,
  "geo"                            => nil,
  "user"                           => {
    "id"                           => nil,
    "screen_name"                  => "",
    "protected"                    => false,
    "created_at"                   => "",
    #
    "statuses_count"               => nil,
    "followers_count"              => nil,
    "friends_count"                => nil,
    "favourites_count"             => nil,
    #
    "name"                         => "",
    "description"                  => "",
    "url"                          => nil,
    "location"                     => "",
    "time_zone"                    => "",
    "utc_offset"                   => nil,
    "lang"                         => "en",
    #
    "profile_background_color"     => "",
    "profile_background_image_url" => "",
    "profile_background_tile"      => false,
    "profile_image_url"            => "",
    "profile_link_color"           => "",
    "profile_sidebar_border_color" => "",
    "profile_sidebar_fill_color"   => "",
    "profile_text_color"           => "",
    "profile_use_background_image" => true,
    #
    "listed_count"                 => nil,
    "geo_enabled"                  => false,
    "follow_request_sent"          => nil,
    "following"                    => nil,
    "contributors_enabled"         => false,
    "notifications"                => nil,
    "verified"                     => false
  }
}

class TermUsageMapper < Wukong::Streamer::StructStreamer
  def process tweet, *_
    TERMS_RE.each do |term, regex|
      if tweet.text =~ regex
        # , tweet.text, tweet.source
        yield [:usage, tweet.tweet_id, tweet.created_at, term, tweet.user_id, tweet.screen_name, tweet.in_reply_to_user_id, tweet.in_reply_to_screen_name, tweet.iso_language_code, tweet.latitude, tweet.longitude]
      end
    end
  end
end

Wukong::Script.new(TermUsageMapper, nil).run

# cat tweet_1.tsv |  ~/ics/hadoop/hadoop_book/code/term_usage_counts.rb --map > /tmp/usages.txt &
# sort -u /tmp/usages.txt | sort -nk5 > usages.tsv


