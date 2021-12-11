defmodule Day11 do
  @doc ~S"""
  Solves part one of the puzzle by computing how many octopodes flashed after
  100 steps.
  #
  ## Examples

      iex> Day11.part_one("example.txt")
      1656

      iex> Day11.part_one("input.txt")
      1694
  """
  def part_one(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.drop(1)
    |> Enum.take(100)
    |> Enum.map(fn swarm ->
      Enum.count(swarm, fn {_pos, energy} -> energy == 0 end)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  Parses some puzzle input into a map in which each position is
  associated with the energy level of the octopus at that point.

  ## Examples

      iex> Day11.parse("
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
  Executes a single step of simulating the energy growth within the swarm.
  All octopodes which flashed will have an energy level of zero after this
  step.

  ## Examples

      iex> Day11.step(%{{0, 0} => 1, {0, 1} => 1, {1, 0} => 3, {1,1} => 2})
      %{{0, 0} => 2, {0, 1} => 2, {1, 0} => 4, {1, 1} => 3}

      iex> Day11.step(%{{0, 0} => 1, {0, 1} => 9, {1, 0} => 3, {1,1} => 2})
      %{{0, 0} => 3, {0, 1} => 0, {1, 0} => 5, {1, 1} => 4}
  """
  def step(swarm) do
    {swarm, []} =
      swarm
      |> Enum.reduce({swarm, Map.keys(swarm)}, fn _octopus, {swarm, coords} ->
        coord = Enum.max_by(coords, &Map.fetch!(swarm, &1))
        swarm = gain(swarm, coord)

        {swarm, coords -- [coord]}
      end)

    swarm
    |> Enum.map(fn
      {pos, energy} when energy > 9 -> {pos, 0}
      other -> other
    end)
    |> Map.new()
  end

  @doc ~S"""
  Updates the map of octopodes by letting the octopus at the given coordinates
  gain energy. In case this causes the octopus the flash, all surrounding
  octopodes will gain energy, too. No energy level is re-set to zero!

  ## Examples

      iex> Day11.gain(%{{0, 0} => 1, {0, 1} => 1, {1, 0} => 3, {1,1} => 2}, {0, 0})
      %{{0, 0} => 2, {0, 1} => 1, {1, 0} => 3, {1, 1} => 2}

      iex> Day11.gain(%{{0, 0} => 1, {0, 1} => 9, {1, 0} => 3, {1,1} => 2}, {0, 1})
      %{{0, 0} => 2, {0, 1} => 10, {1, 0} => 4, {1, 1} => 3}
  """
  def gain(swarm, {x, y} = pos) do
    area =
      case Map.fetch!(swarm, pos) do
        energy when energy >= 9 ->
          for dy <- -1..1, dx <- -1..1, Map.has_key?(swarm, {x + dx, y + dy}) do
            {x + dx, y + dy}
          end

        _ ->
          [pos]
      end

    Enum.reduce(area, swarm, fn pos, swarm -> Map.update!(swarm, pos, &(&1 + 1)) end)
  end

  @doc ~S"""
  ## Examples

      iex> Day11.part_two("example.txt")
      195

      iex> Day11.part_two("input.txt")
      346
  """
  def part_two(input_file \\ "input.txt") do
    File.read!(input_file)
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.with_index()
    |> Enum.find_value(fn {swarm, step} ->
      if Enum.all?(swarm, fn {_pos, energy} -> energy == 0 end) do
        step
      end
    end)
  end
end
