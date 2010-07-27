#!/usr/bin/env ruby
require 'wukong'

class IdentityMapper < Wukong::Streamer::LineStreamer
end

class AdjacencyListReducer < Wukong::Streamer::AccumulatingReducer
  def start! *_
    @out_nodes = []
  end
  def accumulate src, dest
    @out_nodes << dest
  end
  def finalize
    yield [key, @out_nodes.join(",")]
  end
end


Wukong::Script.new(IdentityMapper, AdjacencyListReducer,
  :partition_fields => 1,
  :sort_fields => 2
  ).run
