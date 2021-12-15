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

  def risk_to(risk_at, start, target) do
    next_to_visit = :pqueue2.in(start, 0, :pqueue2.new())
    risk_to = %{{0, 0} => 0}

    {next_to_visit, risk_to}
    |> Stream.iterate(fn {next_to_visit, risk_to} -> step(risk_at, target, next_to_visit, risk_to) end)
    |> Enum.find(&is_integer/1)
  end

  def step(risk_at, target, next_to_visit, risk_to) do
    case :pqueue2.out(next_to_visit) do
      {{:value, ^target}, _next_to_visit} ->
        risk_to[target]

      {{:value, {x, y}}, next_to_visit} ->
        [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]
        |> Enum.filter(fn next -> Map.has_key?(risk_at, next) end)
        |> Enum.reduce({next_to_visit, risk_to}, fn next, {next_to_visit, risk_to} ->
          risk_to_next = risk_to[{x, y}] + risk_at[next]

          if not Map.has_key?(risk_to, next) or risk_to_next < risk_to[next] do
            next_to_visit = :pqueue2.in(next, risk_to_next, next_to_visit)
            risk_to = Map.put(risk_to, next, risk_to_next)
            {next_to_visit, risk_to}
          else
            {next_to_visit, risk_to}
          end
        end)
    end
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
    risk_map = input_file |> File.read!() |> parse()
    bottom_right = risk_map |> Map.keys() |> Enum.max()
    risk_to(risk_map, {0, 0}, bottom_right)
  end

  def part_two(input_file \\ "input.txt") do
    risk_map = input_file |> File.read!() |> parse() |> expand()
    bottom_right = risk_map |> Map.keys() |> Enum.max()
    risk_to(risk_map, {0, 0}, bottom_right)
  end
end
