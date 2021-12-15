defmodule Day15 do
  @doc ~S"""
  Parses some puzzle input into a map in which each position is
  associated with the risk level at that point.

  ## Examples

      iex> Day15.parse("
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
    |> String.split()
    |> Enum.with_index(fn line, y ->
      line
      |> to_charlist()
      |> Enum.with_index(fn energy, x -> {{x, y}, energy - ?0} end)
    end)
    |> List.flatten()
    |> Map.new()
  end

  def graph(risk_map) do
    risk_map
    |> Enum.reduce(Graph.new(), fn {{x, y} = current, risk}, g ->
      [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
      |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
      |> Enum.filter(fn neighbor -> Map.has_key?(risk_map, neighbor) end)
      |> Enum.reduce(g, fn neighbor, g ->
        Graph.add_edge(g, neighbor, current, weight: risk)
      end)
    end)
  end

  def min_total_risk(risk_map) do
    bottom_right = risk_map |> Map.keys() |> Enum.max()

    risk_map
    |> graph()
    |> Graph.get_shortest_path({0, 0}, bottom_right)
    |> Enum.map(fn pos -> Map.fetch!(risk_map, pos) end)
    |> Enum.sum()
    |> then(fn sum -> sum - Map.fetch!(risk_map, {0, 0}) end)
  end

  def render(risk_map) do
    {max_x, max_y} = risk_map |> Map.keys() |> Enum.max()

    Enum.map_join(0..max_y, "\n", fn y ->
      Enum.map_join(0..max_x, "", fn x ->
        "#{Map.fetch!(risk_map, {x,y})}"
      end)
    end)
  end

  def expand(risk_map) do
    {max_x, max_y} = risk_map |> Map.keys() |> Enum.max()

    for {{x, y}, risk} <- risk_map, tile_y <- 0..4, tile_x <- 0..4 do
      x = tile_x * (max_x + 1) + x
      y = tile_y * (max_y + 1) + y
      risk = rem(risk + tile_x + tile_y - 1, 9) + 1
      {{x, y}, risk}
    end
    |> Map.new()
  end

  def part_one(input_file \\ "input.txt") do
    input_file |> File.read!() |> parse() |> min_total_risk()
  end

  def part_two(input_file \\ "input.txt") do
    input_file |> File.read!() |> parse() |> expand() |> min_total_risk()
  end
end
