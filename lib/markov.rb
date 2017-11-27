#!/usr/bin/env ruby
# encoding: utf-8

require 'pp'

class Markov
  attr_accessor :max_chain_length, :tokens, :raw_mapping, :mapping, :starts

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
    normalize_mapping
    p generate_sentence @max_chain_length
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
          @raw_mapping[history][word.dup] = 1.0
        end
      else
        @raw_mapping[history.dup] = {}
        @raw_mapping[history][word.dup] = 1.0
      end
      history.shift
    end
  end

  # word_list - [[String]] list of sentences, split by each word.
  def build_mapping_with_markov_length word_list, markov_length
    word_list.each do |sentence|
      @starts << sentence.first
      (1..sentence.size-1).each do |idx|
        if idx <= markov_length
          history = sentence[0..idx]
        else
          history = sentence[idx - markov_length+1..idx]
        end
        follow = sentence[idx+1]
        add_to_raw_mapping history, follow
      end
    end
  end

  def normalize_mapping
    # normalize @raw_mapping frequencies into @mapping
    @raw_mapping.each do |token, frequencies|
      total = frequencies.values.sum
      @mapping[token] = {}
      frequencies.each do |next_token, frequency|
        @mapping[token][next_token] = frequency / total
      end
    end
    @mapping
  end

  def next_word_from prev_list
    sum = 0.0
    idx = Random.rand
    return_str = ""

    # Shorten prevList until it's in mapping
    until @mapping.include? prev_list
      prev_list.shift
      if prev_list.empty?
        return nil
      end
    end

    # Get a random word from the mapping, given prevList
    @mapping[prev_list].each do |next_word, frequency|
      sum += frequency
      if sum >= idx
        return_str = next_word
      end
    end

    return_str
  end

  def generate_sentence markov_length
    current = @starts.sample
    sentence = ""
    prev_list = [current]
    # keep adding words until we hit end of sentence.
    until current.nil?
      sentence << current
      sentence << " "
      current = next_word_from prev_list
      prev_list << current
      # if the prev_list has gotten too long, trim it.
      if prev_list.size > markov_length
        prev_list.shift
      end
    end
    sentence
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