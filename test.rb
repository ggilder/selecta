require 'benchmark/ips'

# TODO improve performance further by caching indexes of chars in strings?
# could use lots of memory though
# with long lists of files, every character typed forces us to recalculate the
# positions of the previous characters, and ruby-prof tells us we spend a lot
# of time doing that

# Find the length of the shortest substring matching the given characters.
def compute_match_length(string, chars)
  first_char, *rest = chars
  first_indexes = find_char_in_string(string, first_char)

  first_indexes.map do |first_index|
    last_index = find_end_of_match(string, rest, first_index)
    if last_index
      last_index - first_index + 1
    else
      nil
    end
  end.compact.min
end

# Find all occurrences of the character in the string, returning their indexes.
def find_char_in_string(string, char)
  index = 0
  indexes = []
  while index
    index = string.index(char, index)
    if index
      indexes << index
      index += 1
    end
  end
  indexes
end

# Find each of the characters in the string, moving strictly left to right.
def find_end_of_match(string, chars, first_index)
  last_index = first_index
  chars.each do |this_char|
    index = string.index(this_char, last_index + 1)
    return nil unless index
    last_index = index
  end
  last_index
end

def trial(string, chars)
  indexes = indexes_for_chars(string, chars)
  find_shortest_run(indexes)
end

# Find all indexes for all chars in string.
def indexes_for_chars(string, chars)
  indexes = []
  chars.each do |c|
    c_indexes = []
    c_index = -1
    while c_index
      c_index = string.index(c, c_index + 1)
      c_indexes << c_index if c_index
    end
    return if c_indexes.empty?
    indexes << c_indexes
  end
  indexes
end

# Find length of shortest sequence of strictly increasing numbers in array of
# array of indices.
def find_shortest_run(indexes)
  first_indexes, *rest = indexes
  first_indexes.map do |first_index|
    last = rest.reduce(first_index) do |last_index, char_indexes|
      char_indexes.find { |x| x > last_index } || break
    end
    last ? last - first_index + 1 : nil
  end.compact.min
end

str = "spec/search_spec.rb"
query = %w(s e a r)

Benchmark.ips do |x|
  x.report('old') { compute_match_length(str, query) }
  x.report('new') { trial(str, query) }
  x.compare!
end

