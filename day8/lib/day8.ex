defmodule Day8 do
  @digits %{
    'abcefg' => 0,
    'cf' => 1,
    'acdeg' => 2,
    'acdfg' => 3,
    'bcdf' => 4,
    'abdfg' => 5,
    'abdefg' => 6,
    'acf' => 7,
    'abcdefg' => 8,
    'abcdfg' => 9
  }

  @doc ~S"""
  Solves part one.

  ## Examples

      iex> Day8.part_one("example.txt")
      26

      iex> Day8.part_one("input.txt")
      421
  """
  def part_one(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> Enum.map(fn {_patterns, digits} ->
      Enum.count(digits, fn segments -> Enum.count(segments) in [2, 3, 4, 7] end)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  Solves part two.

  ## Examples

      iex> Day8.part_two("example.txt")
      61229

      iex> Day8.part_two("input.txt")
      986163
  """
  def part_two(input_file \\ "input.txt") do
    possible_assignments =
      'abcdefg'
      |> permutations()
      |> Enum.map(fn permutation ->
        permutation
        |> Enum.zip('abcdefg')
        |> Map.new()
      end)

    File.read!(input_file)
    |> parse()
    |> Enum.map(fn {patterns, digits} -> 
      possible_assignments
      |> assignment_for_patterns(patterns)
      |> decode(digits)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  Parse some puzzle input into a list of records.

  ## Examples

      iex> Day8.parse("
      ...> abcd efg ab | cdfeb fcadb
      ...> bcdef abfge fac | fcadb
      ...> ")
      [{['abcd', 'efg', 'ab'], ['bcdef', 'abcdf']}, {['bcdef', 'abefg', 'acf'], ['abcdf']}]
  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_record/1)
  end

  @doc ~S"""
  Parses a single record of the notes.

  ## Examples

      iex> Day8.parse_record("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")
      {['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab'], ['bcdef', 'abcdf', 'bcdef', 'abcdf']}
  """
  def parse_record(record) do
    [patterns, digits] = String.split(record, "|")

    patterns = patterns |> String.split() |> Enum.map(& Enum.sort(String.to_charlist(&1)))
    digits = digits |> String.split() |> Enum.map(& Enum.sort(String.to_charlist(&1)))
    {patterns, digits}
  end

  @doc ~S"""
  Decodes a digit identified by the wire signals given a mapping of wires to
  segments.
  """
  def decode(assignment, digits) do
    digits
    |> Enum.map(fn digit ->
      reverse_translated_segments = Enum.map(digit, fn segment -> Map.get(assignment, segment) end)
      Map.get(@digits, Enum.sort(reverse_translated_segments))
    end)
    |> Integer.undigits()
  end

  @doc ~S"""
  Computes the assignment of wires to segments given a list of patterns.
  """
  def assignment_for_patterns(possible_assignments, patterns) do
    possible_assignments
    |> Enum.find(fn assignment ->
      Enum.all?(patterns, fn pattern ->
        translated_pattern = Enum.map(pattern, fn segment -> Map.get(assignment, segment) end)
        Map.has_key?(@digits, Enum.sort(translated_pattern))
      end)
    end)
  end

  @doc ~S"""
  Generates all permutations of the given list.

  ## Examples

      iex> Day8.permutations([1])
      [[1]]

      iex> Day8.permutations([1,2,3])
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
  """
  def permutations([]), do: [[]]
  def permutations(list) do
    Enum.flat_map(list, fn x ->
      for permutation <- permutations(list -- [x]) do
        [x | permutation]
      end
    end)
  end
end
