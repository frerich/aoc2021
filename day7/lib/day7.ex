defmodule Day7 do
  @doc ~S"""
  Solves part one by computing the minimum alignment cost when assuming that
  every alignment step has a constant cost.

  # Examples

      iex> Day7.part_one("example.txt")
      37

      iex> Day7.part_one("input.txt")
      349769
  """
  def part_one(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> min_alignment_cost(fn p, q -> abs(p - q) end)
  end

  @doc ~S"""
  Solves part two by computing the minimum alignment cost when assuming that
  every alignment step has an increasing cost.

  # Examples

      iex> Day7.part_two("example.txt")
      168

      iex> Day7.part_two("input.txt")
      99540554
  """
  def part_two(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> min_alignment_cost(fn p, q -> Enum.sum(0..abs(p - q)) end)
  end

  @doc ~S"""
  Parses some puzzle input.

  ## Examples

      iex> Day7.parse("16,1,2,0,4,2,7,1,2,14")
      [16,1,2,0,4,2,7,1,2,14]
  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @doc ~S"""
  Computes the minimum alignment cost by identifying the cheapest position for
  aligning all `positions` at with the distance between two positions given by
  `distance_fun`.

  ## Examples

    iex> Day7.min_alignment_cost([16,1,2,0,4,2,7,1,2,14], & abs(&1 - &2))
    37
  """
  def min_alignment_cost(positions, distance_fun) do
    {min_pos, max_pos} = Enum.min_max(positions)

    min_pos..max_pos
    |> Enum.map(fn p ->
      positions
      |> Enum.map(fn q -> distance_fun.(p, q) end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end
end
