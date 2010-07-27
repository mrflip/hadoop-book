#!/usr/bin/env ruby
require 'wukong'
require 'wukong/and_pig'
require 'set'

class IdentityMapper < Wukong::Streamer::LineStreamer
  def process *args
    yield *args
  end
end

class AdjacencyListReducer < Wukong::Streamer::AccumulatingReducer
  def start! *_
    @out_nodes = [].to_set
  end
  def accumulate src, dest
    @out_nodes << dest
  end

  def finalize
    # simulate the appearance of a pig bag.
    yield [key, @out_nodes.sort.map(&:to_pig_tuple).to_pig_bag ]
  end
end

#
# This class will retain counts of replies between a and each b
# The finalize is the same, just replaces the means of accumulation
#
class AdjacencyListWithCountsReducer < AdjacencyListReducer
  def start! *_
    @out_nodes = Hash.new{|h,k| h[k] = 0 } # auto vivify a missing key as zero
  end
  def accumulate src, dest
    @out_nodes[dest] += 1
  end
end


Wukong::Script.new(IdentityMapper, AdjacencyListReducer,
  :partition_fields => 1,
  :sort_fields => 2
  ).run
