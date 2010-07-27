#!/usr/bin/env ruby
require 'wukong'
require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model

require 'set'

SEEDS = %w[mrflip tom_e_white nealrichter tlipcon mza wattsteve
josephkelly peteskomoroch jeromatron datajunkie communicating mikeolson
lusciouspear mat_kelcey esammer cmastication kevinweil metcalfc mndoci ogrisel
bradfordcross chrisdiehl flowingdata lenbust cutting dataspora dhruvbansal sogrady kentbrew].to_set

OR_SEEDS = %w[ infochimps hadoop cloudera ]

Tweet.class_eval do
  def is_reply?
    not in_reply_to_screen_name.blank?
  end
end

class ReplyGraphMapper < Wukong::Streamer::StructStreamer
  def process(raw_tweet,*_)
    tweet = raw_tweet # tweet = Tweet.new(raw_tweet)
    tweet.screen_name.downcase! ; tweet.in_reply_to_screen_name.downcase! ;
    if tweet.is_reply? && (
        (SEEDS.include?(tweet.screen_name) && SEEDS.include?(tweet.in_reply_to_screen_name)) ||
        OR_SEEDS.include?(tweet.screen_name) ||
        OR_SEEDS.include?(tweet.in_reply_to_screen_name) )
      yield [tweet.screen_name, tweet.in_reply_to_screen_name]
    end
  end
end

SEEDS.each do |seed|
  puts [seed, 'hadoop'].join("\t")
end

Wukong::Script.new(ReplyGraphMapper).run
