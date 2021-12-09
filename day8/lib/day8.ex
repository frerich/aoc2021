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
      assignment = pick(patterns)

      digits
      |> Enum.map(& pattern_to_digit(&1, assignment))
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

  def candidates(patterns) do
    Enum.map(0..9, fn digit ->
      num_segments =
        Enum.find_value(@digits, fn {segments, d} -> if d === digit, do: Enum.count(segments) end)

      Enum.filter(patterns, fn wires -> Enum.count(wires) == num_segments end)
    end)
  end

  def pick(patterns) do
    candidates = candidates(patterns)

    [assignment] =
      for {c, rest} <- select('abcdefg'),
          {f, rest} <- select(rest),
          Enum.any?(Enum.at(candidates, 1), fn wires -> [c, f] -- wires == [] end),
          {a, rest} <- select(rest),
          Enum.any?(Enum.at(candidates, 7), fn wires -> [a, c, f] -- wires == [] end),
          {b, rest} <- select(rest),
          {d, rest} <- select(rest),
          Enum.any?(Enum.at(candidates, 4), fn wires -> [b, c, d, f] -- wires == [] end),
          {g, rest} <- select(rest),
          Enum.any?(Enum.at(candidates, 3), fn wires -> [a, c, d, f, g] -- wires == [] end),
          Enum.any?(Enum.at(candidates, 5), fn wires -> [a, b, d, f, g] -- wires == [] end),
          Enum.any?(Enum.at(candidates, 9), fn wires -> [a, b, c, d, f, g] -- wires == [] end),
          {e, []} <- select(rest),
          Enum.any?(Enum.at(candidates, 2), fn wires -> [a, c, d, e, g] -- wires == [] end),
          Enum.any?(Enum.at(candidates, 6), fn wires -> [a, b, d, e, f, g] -- wires == [] end),
          Enum.any?(Enum.at(candidates, 8), fn wires -> [a, b, c, d, e, f, g] -- wires == [] end),
          Enum.any?(Enum.at(candidates, 0), fn wires -> [a, b, c, e, f, g] -- wires == [] end) do
        %{a => ?a, b => ?b, c => ?c, d => ?d, e => ?e, f => ?f, g => ?g}
      end

    assignment
  end

  def pattern_to_digit(pattern, assignment) do
    segments = Enum.map(pattern, fn wire -> Map.get(assignment, wire) end)

    Map.get(@digits, Enum.sort(segments))
  end

  def select(list) do
    Enum.map(0..(Enum.count(list) - 1), &List.pop_at(list, &1))
  end
end
