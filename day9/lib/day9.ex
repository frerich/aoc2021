defmodule Day9 do
  @doc ~S"""
  Solves part one of the puzzle by summing the risk level of all low points in
  the input.

  ## Examples

      iex> Day9.part_one("example.txt")
      15

      iex> Day9.part_one("input.txt")
      607
  """
  def part_one(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> filter_low_points()
    |> Enum.map(fn {_coord, height} -> risk_level(height) end)
    |> Enum.sum()
  end

  @doc ~S"""
  Solves part two of the puzzle by multiplying the sizes of the three largest
  basins in the input.

  ## Examples

      iex> Day9.part_two("example.txt")
      1134

      iex> Day9.part_two("input.txt")
      900864
  """
  def part_two(input_file \\ "input.txt") do
    height_map = File.read!(input_file) |> parse()

    height_map
    |> filter_low_points()
    |> Enum.map(fn {coord, _height} -> identify_basin(height_map, coord) |> Enum.count() end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  @doc ~S"""
  Parses some puzzle input into a height map in which each coordinate is
  associated with the height at that point.

  ## Examples

      iex> Day9.parse("
      ...> 2191
      ...> 0982
      ...> 9856
      ...>")
      %{
        {0,0} => 2, {1,0} => 1, {2,0} => 9, {3,0} => 1,
        {0,1} => 0, {1,1} => 9, {2,1} => 8, {3,1} => 2,
        {0,2} => 9, {1,2} => 8, {2,2} => 5, {3,2} => 6
      }
  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index(fn line, y ->
      line
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index(fn height, x ->
        {{x, y}, String.to_integer(height)}
      end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  @doc ~S"""
  Identifies all 'low points' in the given height map, i.e. positions at which
  no adjacent neighbor point is lower.

  ## Examples

      iex> File.read!("example.txt") |> Day9.parse() |> Day9.filter_low_points()
      [{{2, 2}, 5}, {{1, 0}, 1}, {{6, 4}, 5}, {{9, 0}, 0}]
  """
  def filter_low_points(height_map) do
    height_map
    |> Enum.filter(fn {coord, height} ->
      height_map
      |> adjacent(coord)
      |> Enum.all?(fn neighbour ->
        height < Map.fetch!(height_map, neighbour)
      end)
    end)
  end

  @doc ~S"""
  Computes the risk level of a point.

  ## Examples

      iex> Day9.risk_level(5)
      6
  """
  def risk_level(height) do
    height + 1
  end

  @doc ~S"""
  Identifies the 'basin' in a given height map assuming that the given coordinates
  identify a low point.

  ## Examples

      iex> File.read!("example.txt") |> Day9.parse() |> Day9.identify_basin({1,0})
      #MapSet<[{0, 0}, {0, 1}, {1, 0}]>

      iex> File.read!("example.txt") |> Day9.parse() |> Day9.identify_basin({6,4})
      #MapSet<[{5, 4}, {6, 3}, {6, 4}, {7, 2}, {7, 3}, {7, 4}, {8, 3}, {8, 4}, {9, 4}]>
  """
  def identify_basin(height_map, coord, seen \\ %MapSet{}) do
    height = Map.fetch!(height_map, coord)

    next_coords =
      height_map
      |> adjacent(coord)
      |> Enum.reject(fn neighbour -> MapSet.member?(seen, neighbour) end)
      |> Enum.filter(fn neighbour ->
        neighbour_height = Map.fetch!(height_map, neighbour)
        neighbour_height > height and neighbour_height < 9
      end)

    case next_coords do
      [] ->
        MapSet.put(seen, coord)

      _ ->
        next_coords
        |> Enum.map(fn neighbour ->
          identify_basin(height_map, neighbour, MapSet.put(seen, coord))
        end)
        |> Enum.reduce(%MapSet{}, fn seen, acc ->
          MapSet.union(seen, acc)
        end)
    end
  end

  @doc ~S"""
  Identifies all coordinates which are adjacent to the given coordinates.
  """
  def adjacent(height_map, {x, y}) do
    Enum.filter([{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}], &Map.has_key?(height_map, &1))
  end
end
