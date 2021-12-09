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
    File.read!(input_file)
    |> parse()
    |> Enum.map(fn {patterns, digits} ->
      assignment = deduce_wire_assignment(patterns)

      digits
      |> Enum.map(&pattern_to_digit(&1, assignment))
      |> Integer.undigits()
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

    patterns = patterns |> String.split() |> Enum.map(&Enum.sort(String.to_charlist(&1)))
    digits = digits |> String.split() |> Enum.map(&Enum.sort(String.to_charlist(&1)))
    {patterns, digits}
  end

  @doc ~S"""
  Deduced the wire-to-segment assignment given a list of signal patterns.

  ## Examples

      iex> Day8.deduce_wire_assignment(['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab'])
      %{97 => 99, 98 => 102, 99 => 103, 100 => 97, 101 => 98, 102 => 100, 103 => 101}
  """
  def deduce_wire_assignment(patterns) do
    [assignment] =
      for {c, rest} <- select('abcdefg'),
          {f, rest} <- select(rest),
          Enum.sort([c, f]) in patterns,
          {a, rest} <- select(rest),
          Enum.sort([a, c, f]) in patterns,
          {b, rest} <- select(rest),
          {d, rest} <- select(rest),
          Enum.sort([b, c, d, f]) in patterns,
          {g, rest} <- select(rest),
          Enum.sort([a, c, d, f, g]) in patterns,
          Enum.sort([a, b, d, f, g]) in patterns,
          Enum.sort([a, b, c, d, f, g]) in patterns,
          {e, []} <- select(rest),
          Enum.sort([a, c, d, e, g]) in patterns,
          Enum.sort([a, b, d, e, f, g]) in patterns,
          Enum.sort([a, b, c, d, e, f, g]) in patterns,
          Enum.sort([a, b, c, e, f, g]) in patterns do
        %{a => ?a, b => ?b, c => ?c, d => ?d, e => ?e, f => ?f, g => ?g}
      end

    assignment
  end

  @doc ~S"""
  Translates a signal pattern (identified by the wires giving a signal) and an
  assignment table which tells which segments to light for each wire into a
  digit.

  ## Examples

      iex> Day8.pattern_to_digit('ab', %{?a => ?a, ?b => ?b, ?c => ?c, ?d => ?d, ?e => ?e, ?f => ?f, ?g => ?g})
      nil

      iex> Day8.pattern_to_digit('cf', %{?a => ?a, ?b => ?b, ?c => ?c, ?d => ?d, ?e => ?e, ?f => ?f, ?g => ?g})
      1
  """
  def pattern_to_digit(pattern, assignment) do
    segments = Enum.map(pattern, fn wire -> Map.get(assignment, wire) end)

    Map.get(@digits, Enum.sort(segments))
  end

  @doc ~S"""
  Returns all ways to draw one element from the given list.

  ## Examples

      iex> Day8.select([1,2,3,4])
      [{1, [2,3,4]}, {2, [1,3,4]}, {3, [1,2,4]}, {4, [1,2,3]}]
  """
  def select(list) do
    Enum.map(0..(Enum.count(list) - 1), &List.pop_at(list, &1))
  end
end
