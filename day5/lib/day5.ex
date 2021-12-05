defmodule Day5 do
  @doc ~S"""
  Solves part one of the puzzle by computing at how many points at least two
  lines overlap.

  ## Examples

      iex> Day5.part_one("example.txt")
      5

      iex> Day5.part_one("input.txt")
      5632
  """
  def part_one(input_file \\ "input.txt") do
    input_file
    |> File.read!()
    |> parse()
    |> Enum.flat_map(&coverage/1)
    |> Enum.frequencies()
    |> Enum.count(fn {_, num_overlaps} -> num_overlaps >= 2 end)
  end

  @doc ~S"""
  Solves part two of the puzzle by computing at how many points at least two
  lines overlap when also considering diagonal lines.

  ## Examples

      iex> Day5.part_two("example.txt")
      12
  """
  def part_two(input_file \\ "input.txt") do
    input_file
    |> File.read!()
    |> parse()
    |> Enum.flat_map(fn
      {{src_x, src_y}, {dst_x, dst_y}} when abs(src_x - dst_x) == abs(src_y - dst_y) ->
        Enum.zip(src_x..dst_x, src_y..dst_y)
      line -> coverage(line)
    end)
    |> Enum.frequencies()
    |> Enum.count(fn {_, num_overlaps} -> num_overlaps >= 2 end)
  end

  @doc ~S"""
  Parses the puzzle input.

  ## Examples

      iex> Day5.parse("
      ...> 0,9 -> 423,9
      ...> 8,0 -> 11,0
      ...> 9,4 -> 3,4
      ...> ")
      [{{0,9}, {423,9}}, {{8,0},{11,0}}, {{9,4},{3,4}}]
  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [src, "->", dst] = String.split(line)
      [src_x, src_y] = src |> String.split(",") |> Enum.map(&String.to_integer/1)
      [dst_x, dst_y] = dst |> String.split(",") |> Enum.map(&String.to_integer/1)
      {{src_x, src_y}, {dst_x, dst_y}}
    end)
  end

  @doc ~S"""
  Computes the range of coordinates covered by the given line; only works for
  horizontal or vertical lines.

  ## Examples

      iex> Day5.coverage({{0,9}, {5,9}})
      [{0,9}, {1,9}, {2,9}, {3,9}, {4,9}, {5,9}]

      iex> Day5.coverage({{4,3}, {4,0}})
      [{4,3}, {4,2}, {4,1}, {4,0}]
  """
  def coverage({{src_x, y}, {dst_x, y}}), do: for x <- src_x..dst_x, do: {x, y}
  def coverage({{x, src_y}, {x, dst_y}}), do: for y <- src_y..dst_y, do: {x, y}
  def coverage(_line), do: []
end
