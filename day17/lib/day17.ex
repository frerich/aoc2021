defmodule Day17 do
  @doc ~S"""
  Solves part one of the puzzle by computing the minimum X velocity and maximum
  Y velocity for the trajectory of the probe to still hit the target area. The
  function then returns the highest Y coordinate along that trajectory.

  ## Examples
      iex> Day17.part_one(Day17.example)
      45

      iex> Day17.part_one(Day17.input)
      35511
  """
  def part_one(target) do
    vx = min_vx(target)
    vy = max_vy(target)

    {{_x, max_y}, _v} =
      {{0, 0}, {vx, vy}}
      |> trajectory(target)
      |> Enum.max_by(fn {{_x, y}, _v} -> y end)

    max_y
  end

  @doc ~S"""
  Solves part two of the puzzle by counting the number of distinct trajectories
  which all hits the target area.

      iex> Day17.part_two(Day17.example)
      112

      iex> Day17.part_two(Day17.input)
      3282
  """
  def part_two(target) do
    min_vx = min_vx(target)
    max_vx = max_vx(target)

    min_vy = min_vy(target)
    max_vy = max_vy(target)

    for vx <- min_vx..max_vx, vy <- min_vy..max_vy do
      {vx, vy}
    end
    |> Enum.count(fn v -> hits?(v, target) end)
  end

  @doc ~S"""
  Calculates the trajectory of the probe when starting with the given velocity;
  the trajectory is cut off when we know that it cannot possibly hit the given
  target area.
  """
  def trajectory({{x, y}, _v}, {_top_left, {x1, y1}}) when y1 > y or x > x1, do: []
  def trajectory(probe, target), do: [probe | trajectory(step(probe), target)]

  @doc ~S"""
  Moves the probe at the given position a single step according to the given
  velocity vector. Returns the updated position and velocity.
  """
  def step({{x, y}, {0, vy}}), do: {{x, y + vy}, {0, vy - 1}}
  def step({{x, y}, {vx, vy}}) when vx > 0, do: {{x + vx, y + vy}, {vx - 1, vy - 1}}
  def step({{x, y}, {vx, vy}}) when vx < 0, do: {{x + vx, y + vy}, {vx + 1, vy - 1}}

  @doc ~S"""
  Tells if firing the probe with the given velocity vector would hit the given
  target area.
  """
  def hits?(v, {{x0, y0}, {x1, y1}} = target) do
    {{x, y}, _v} =
      {{0, 0}, v}
      |> trajectory(target)
      |> Enum.at(-1)

    x0 <= x and x <= x1 and y0 >= y and y >= y1
  end

  @doc ~S"""
  Computes a lower bound (the largest lower bound) for the possible X
  velocities which have any chance of hitting the target area.

  ## Examples

      iex> Day17.min_vx(Day17.example)
      6

      iex> Day17.min_vx(Day17.input)
      5
  """
  def min_vx(target) do
    naturals = Stream.iterate(0, &(&1 + 1))
    Enum.find(naturals, fn vx -> hits?({vx, 0}, target) end)
  end

  def max_vx({_top_left, {x1, _y1}}), do: x1
  def min_vy({_top_left, {_x1, y1}}), do: y1

  def max_vy(target) do
    vx = min_vx(target)
    Enum.find(500..0, fn vy -> hits?({vx, vy}, target) end)
  end

  def input, do: {{14, -225}, {50, -267}}
  def example, do: {{20, -5}, {30, -10}}
end
