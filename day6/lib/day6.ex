defmodule Day6 do
  @doc ~S"""
  Solves part one of the puzzle by computing the size of the laternfish
  population described by `input_file` after 80 days.

  ## Examples

      iex> Day6.part_one("example.txt")
      5934

      iex> Day6.part_one("input.txt")
      349549
  """
  def part_one(input_file \\ "input.txt") do
    input_file |> parse() |> population_size(80)
  end

  @doc ~S"""
  Solves part one of the puzzle by computing the size of the laternfish
  population described by `input_file` after 256 days.

  ## Examples

      iex> Day6.part_two("example.txt")
      26984457539

      iex> Day6.part_two("input.txt")
      1589590444365
  """
  def part_two(input_file \\ "input.txt") do
    input_file |> parse() |> population_size(256)
  end

  @doc ~S"""
  Parses a puzzle input file.

  ## Examples

      iex> Day6.parse("example.txt")
      [3,4,3,1,2]
  """
  def parse(input_file \\ "input.txt") do
    input_file
    |> File.read!()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @doc ~S"""
  Computes the resulting population size after growing `population` for
  `num_days` days.

  ## Examples

      iex> Day6.population_size([3,4,3,1,2], 0)
      5

      iex> Day6.population_size([3,4,3,1,2], 18)
      26

      iex> Day6.population_size([3,4,3,1,2], 80)
      5934
  """
  def population_size(population, num_days) do
    population
    |> Enum.frequencies()
    |> Stream.iterate(&grow/1)
    |> Enum.at(num_days)
    |> Map.values()
    |> Enum.sum()
  end

  @doc ~S"""
  Grows a given population (represented as a map associating each timer value
  with the number of members having that timer value) in a single step.

  ## Examples

      iex> Day6.grow(%{1 => 1, 2 => 1, 3 => 2, 4 => 1})
      %{0 => 1, 1 => 1, 2 => 2, 3 => 1}

      iex> Day6.grow(%{0 => 3, 1 => 2, 2 => 2, 3 => 1, 6 => 1, 7 => 1, 8 => 1})
      %{0 => 2, 1 => 2, 2 => 1, 5 => 1, 6 => 4, 7 => 1, 8 => 3}
  """
  def grow(population) do
    population
    |> Enum.flat_map(fn
      {0, n} -> [%{6 => n}, %{8 => n}]
      {t, n} -> [%{(t - 1) => n}]
    end)
    |> Enum.reduce(%{}, fn m, acc ->
      Map.merge(acc, m, fn _k, v1, v2 -> v1 + v2 end)
    end)
  end
end
