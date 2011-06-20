# Where we will store our dictionary list
# while we are searching for neighbours
class Dictionary
  
  def initialize
    @words = []
  end
  
  def all
    return @words
  end  
  
  def add(word)
    @words = @words << word
  end
  
  def delete(word)
    @words.delete word
  end
  
end

# Here we are going to store our chains
# and work up the chain one level at a time
class Store
  
  @@store = Hash.new { [] }
  
  # Add a chain to our store
  def add(data)
    length = data.keys.count
    @@store[length] = @@store[length] << data
  end
  
  # Get the next chain in our store
  # and delete the old one.
  def next
    level = @@store.keys.sort.first
    if @@store[level].count == 0
      @@store.delete level
      level = @@store.keys.sort.first
      raise "End of search - no solution found" unless level
      STDOUT.puts "\n\nSearching #{level+1} word chains"
    end
    queued = @@store[level].shift
    @@store[level].delete_at 0
    return queued
  end  
end

# This is the class where our searching takes place
class WordChain
  def initialize(from, to)
    raise "Found chain: #{from} -> #{to}" if from == to # for all the tricksters
    raise "Words must be the same length" unless from.length == to.length
    
    @dictionary = Dictionary.new

    
    load_words_same_length_as from
    
    [from, to].each do |word|
      raise "#{word} isnt in dictionary" unless @dictionary.all.include?(word)
    end
    
    @from = from
    @to = to
    @store = Store.new

    delete_hit_word_from_list from
    STDOUT.puts "\n\nSearching for chains from #{from} to #{to}\n"
    STDOUT.flush
    find_chain
  end
  
  # This is our main loop for finding chains
  def find_chain(data={1=>@from})
    level = data.count
        
    word_neighbours = neighbours_of(data.fetch(level))
    word_neighbours.to_a.each do |neighbour|
      unless data.has_value? neighbour
        if neighbour == @to
          answer = []
          data.keys.sort.each do |d|
            answer << data.fetch(d)
          end
          answer << neighbour
          STDOUT.puts "\n\n\nSOLUTION: #{ answer.join(' -> ') }"
          return true
        end
        data_clone = data.clone
        data_clone[level+1] = neighbour
        @store.add(data_clone)
        STDOUT.write "."
        delete_hit_word_from_list neighbour        
      end
      STDOUT.flush
    end
    find_chain @store.next
  end
  
  # Delete a word that we have hit in a chain from
  # our dictionary. This makes our search faster but
  # we might miss the shortest chain.
  def delete_hit_word_from_list(word)
    @dictionary.delete word
  end  
  
  # To find words that are close to our target
  # word by only one letter. For this we will
  # create a regex match to find our words and
  # reject the target word and nil returns.
  def neighbours_of(word)
    neighbours_array = []
    for i in 0..word.length-1 do
      cloned_word = word.clone
      cloned_word[i] = '[a-z]'
      for dictionary_word in @dictionary.all
        neighbour_matches = dictionary_word.match(/#{cloned_word}/)
        neighbours_array << neighbour_matches.to_s unless neighbour_matches.nil? || neighbour_matches.to_s == word
      end
    end
    return neighbours_array.flatten.uniq
  end
  
  # We only want to focus on words that are the same
  # length as our target words. Filter all others out
  # of our word list.
  #
  # At the same time we want to convert the words to
  # lowercase and remove the newline character at the end
  # of the word
  def load_words_same_length_as(from)
    wordlist = '/usr/share/dict/words'
    temp_dictionary = File.new(wordlist)
    for word in temp_dictionary.to_a do
      word = word.chomp
      if word.length == from.length
        word = word.downcase
        @dictionary.add word.to_s
      end
    end
  end
end


if ARGV[0] && ARGV[1]
  # How we are going to fire off the search from command line
  
  from = ARGV[0].dup
  to = ARGV[1].dup
  
  raise "Please enter your start and finish words - ruby chain.rb mint code"unless from && to
  
  WordChain.new(from, to)
end