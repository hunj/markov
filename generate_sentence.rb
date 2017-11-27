require_relative 'lib/markov'

chain_length = ARGV[1].nil? ? 3 : ARGV[1].to_i

m = Markov.new(ARGV[0], max_chain_length: chain_length)
