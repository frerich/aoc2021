defmodule Day14 do
  @doc ~S"""
  Solves part one of the puzzle by simulating the polymer injection 10 times
  and then calculating the difference between the least common and the most
  common element.

  ## Examples

      iex> Day14.part_one("example.txt")
      1588

      iex> Day14.part_one("input.txt")
      2233
  """
  def part_one(input_file \\ "input.txt") do
    {polymer_template, rules} = File.read!(input_file) |> parse()

    {min_count, max_count} =
      polymer_template
      |> run(rules, 10)
      |> Map.values()
      |> Enum.min_max()

    max_count - min_count
  end

  @doc ~S"""
  Parses some puzzle input.

  ## Examples

      iex> Day14.parse(\"""
      ...>NNCB
      ...>
      ...>CH -> B
      ...>HH -> N
      ...>CB -> H
      ...>\""")
      {'NNCB', %{'CH' => ?B, 'HH' => ?N, 'CB' => ?H}}
  """
  def parse(input) do
    [template | rules] = String.split(input, "\n", trim: true)

    template = to_charlist(template)

    rules =
      for line <- rules do
        [element_pair, "->", injected] = String.split(line)
        [injected] = to_charlist(injected)
        {to_charlist(element_pair), injected}
      end

    {to_charlist(template), Map.new(rules)}
  end

  @doc ~S"""
  Runs a polymer insertion process for `num_steps` steps, starting with the
  given polymer and considering the insertion rules in `rules`.

  Returns a frequency table detailing how often each element occurs in the
  final polymer.

  ## Examples

      iex> Day14.run('CHHB', %{'CH' => ?B, 'HH' => ?N}, 0)
      %{?C => 1, ?H => 2, ?B => 1}

      iex> Day14.run('CHHB', %{'CH' => ?B, 'HH' => ?N}, 1)
      %{?C => 1, ?H => 2, ?B => 2, ?N => 1}
  """
  def run([first_element | _] = polymer, rules, num_steps) do
    polymer
    |> Enum.chunk_every(2, 1, :discard)
    |> Map.new(fn element_pair -> {element_pair, 1} end)
    |> Stream.iterate(&step(&1, rules))
    |> Enum.at(num_steps)
    |> Enum.map(fn {[_, element], count} -> {element, count} end)
    |> sum_pairs()
    |> bump(first_element)
  end

  @doc ~S"""
  Grow a set of element pairs according to the given rules, keeping track of
  how often each pair occurs.

  ## Examples

      iex> Day14.step(%{'CH' => 3, 'HH' => 1, 'HB' => 2}, %{'CH' => ?B, 'HH' => ?N})
      %{'CB' => 3, 'BH' => 3, 'HN' => 1, 'NH' => 1, 'HB' => 2}
  """
  def step(element_pairs, rules) do
    element_pairs
    |> Enum.flat_map(fn {[a, b] = pair, count} ->
      case Map.get(rules, pair) do
        nil -> [{pair, count}]
        injected -> [{[a, injected], count}, {[injected, b], count}]
      end
    end)
    |> sum_pairs()
  end

  @doc ~S"""
  Sums up a list of pairs in which the second element is expected to be an integer.

  ## Examples

      iex> Day14.sum_pairs([])
      %{}

      iex> Day14.sum_pairs([a: 13, b: 2, c: 9, b: 17])
      %{a: 13, b: 19, c: 9}
  """
  def sum_pairs(enum) do
    Enum.reduce(enum, %{}, fn {key, count}, map -> bump(map, key, count) end)
  end

  @doc ~S"""
  Increases a map value by a given value.

  ## Examples

      iex> Day14.bump(%{}, :a)
      %{a: 1}

      iex> Day14.bump(%{a: 2}, :a, 5)
      %{a: 7}
  """
  def bump(map, key, increment \\ 1) do
    Map.update(map, key, increment, &(&1 + increment))
  end

  @doc ~S"""
  Solves part one of the puzzle by simulating the polymer injection 40 times
  and then calculating the difference between the least common and the most
  common element.

  ## Examples

      iex> Day14.part_two("example.txt")
      2188189693529

      iex> Day14.part_two("input.txt")
      2884513602164
  """
  def part_two(input_file \\ "input.txt") do
    {polymer_template, rules} = File.read!(input_file) |> parse()

    {min_count, max_count} =
      polymer_template
      |> run(rules, 40)
      |> Map.values()
      |> Enum.min_max()

    max_count - min_count
  end
end
