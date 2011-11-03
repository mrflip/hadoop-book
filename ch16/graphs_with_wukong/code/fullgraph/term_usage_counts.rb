#!/usr/bin/env ruby
require 'wukong'
require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model

#
# Make an inverted index -- maps usage of our term ('hadoop', 'infochimps',
# 'cloudera', 'map reduce', 'network graph' and 'big data') to user, tweet_id,
# date and geo.
#
# Note that a tweet mentioning multiple terms will emit multiple terms, but only
# once per term: "hadoop hadoop infochimps mapreduce" will emit
#
#     usage   hadoop      ...
#     usage   infochimps  ...
#     usage   map_reduce  ...
#
# only
#

TERMS_RE = {
  :hadoop        => /hadoop/i,
  :infochimps    => /infochimps?/i,
  :cloudera      => /cloudera/i,
  :map_reduce    => /map\W*reduce/i,
  :network_graph => /network\W*graph/i,
  :big_data      => /big\W*data/i,
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
