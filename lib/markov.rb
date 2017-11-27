#!/usr/bin/env ruby
# encoding: utf-8

require 'pp'

class Markov
  attr_accessor :max_chain_length, :tokens, :raw_mapping

  def initialize(text, opts = {})
    raise ArgumentError.new("invalid chain length") if opts[:max_chain_length] < 1

    # {[list of words] => {word => number of times the word appears following the tuple}}
    # Example:
    #    {['eyes', 'turned'] => {'to' => 2.0, 'from' => 1.0}}
    # Used briefly while first constructing the normalized mapping.
    @raw_mapping = {}

    # {[list of words] => {word => *normalized* number of times the word appears following the tuple}}
    # Example entry:
    #    {['eyes', 'turned'] => {'to' => 0.666, 'from' => 0.333}}
    @mapping = {}

    # Contains words that can start sentences
    @starts = []

    @tokens = extract_words_from text
    @max_chain_length = opts[:max_chain_length] || 3
    build_mapping_with_markov_length @tokens, @max_chain_length
  end

  # Returns the contents of the file, split into a list of words and punctuations.
  def extract_words_from filename
    text = []
    file_content = File.open(filename, "r:UTF-8", &:read)
    file_content.each_line do |line|
      text << line.chomp.encode('utf-8').split(' ')
    end
    text
  end

  # Self-explanatory -- adds "word" to the `@raw_mapping` hash under `history`.
  # add_to_temp_mapping (and mapping) both match each word to a list of possible next
  # words.
  # Given history = ["the", "rain", "in"] and word = "Spain", we add "Spain" to
  # the entries for ["the", "rain", "in"], ["rain", "in"], and ["in"].
  def add_to_raw_mapping history, word
    until history.empty?
      if @raw_mapping.has_key? history
        if @raw_mapping[history].has_key? word
          @raw_mapping[history][word] += 1.0
        else
          @raw_mapping[history][word] = 1.0
        end
      else
        @raw_mapping[history.dup] = {}
        @raw_mapping[history][word] = 1.0
      end
      history.shift
    end
    @raw_mapping
  end

  # word_list - [[String]] list of sentences, split by each word.
  def build_mapping_with_markov_length word_list, markov_length
    word_list.each do |sentence|
      @starts << sentence.first
      sentence.each_with_index do |word, idx|
        if idx <= markov_length
          history = sentence[0..idx]
        else
          history = sentence[idx-markov_length+1..idx+1]
        end
        follow = sentence[idx+1]
        add_to_raw_mapping history, follow
      end
    end

    # TODO: normalize @raw_mapping to @mapping
    #
    #
  end

  # TODO: We want to be able to compare words independent of their capitalization.
  def fix_capitalization word

  end
end

class String
  def is_uppercase?
    return self =~ /[A-Z]+/
  end

  def is_lowercase?
    return self == self.downcase
  end
end