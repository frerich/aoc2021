defmodule Day15 do
  @doc ~S"""
  Solves part one of the puzzle by computing the minimum risk of going from the
  top-left to the bottom-right corner of the puzzle input.

  ## Examples

      iex> Day15.part_one("example.txt")
      40

      iex> Day15.part_one("input.txt")
      363
  """
  def part_one(input_file \\ "input.txt") do
    risk_map = input_file |> File.read!() |> parse()
    bottom_right = risk_map |> Map.keys() |> Enum.max()
    risk_to(risk_map, {0, 0}, bottom_right)
  end

  @doc ~S"""
  Solves part one of the puzzle by computing the minimum risk of going from the
  top-left to the bottom-right corner of the expanded(!) puzzle input.

  ## Examples

      iex> Day15.part_two("example.txt")
      315

      iex> Day15.part_two("input.txt")
      2835
  """
  def part_two(input_file \\ "input.txt") do
    risk_map = input_file |> File.read!() |> parse() |> expand()
    bottom_right = risk_map |> Map.keys() |> Enum.max()
    risk_to(risk_map, {0, 0}, bottom_right)
  end

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

  @doc ~S"""
  Given a map of risk levels, computes the minimum cumulative risk of going
  from `start` to `target`.

  ## Examples

      iex> risk_map = Day15.parse("2191\n0982\n9856")
      ...> Day15.risk_to(risk_map, {0,0}, {3,2})
      19
  """
  def risk_to(risk_at, start, target) do
    next_to_visit = :pqueue2.in(start, 0, :pqueue2.new())
    risk_to = %{{0, 0} => 0}

    {next_to_visit, risk_to}
    |> Stream.iterate(fn {next_to_visit, risk_to} ->
      step(risk_at, target, next_to_visit, risk_to)
    end)
    |> Enum.find(&is_integer/1)
  end

  defp step(risk_at, target, next_to_visit, risk_to) do
    case :pqueue2.out(next_to_visit) do
      {{:value, ^target}, _next_to_visit} ->
        risk_to[target]

      {{:value, {x, y} = current}, next_to_visit} ->
        current_risk = risk_to[current]

        adjacent =
          [{x + 1, y}, {x, y + 1}, {x - 1, y}, {x, y - 1}]
          |> Enum.filter(&Map.has_key?(risk_at, &1))

        relevant =
          adjacent
          |> Enum.map(fn next -> {next, current_risk + risk_at[next]} end)
          |> Enum.filter(fn {next, risk_to_next} ->
            risk_to_next < Map.get(risk_to, next, risk_to_next + 1)
          end)

        next_to_visit =
          Enum.reduce(relevant, next_to_visit, fn {next, risk_to_next}, queue ->
            :pqueue2.in(next, risk_to_next, queue)
          end)

        risk_to = Map.merge(risk_to, Map.new(relevant))

        {next_to_visit, risk_to}
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
end
