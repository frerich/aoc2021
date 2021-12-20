defmodule Day20 do
  require Integer

  @doc ~S"""
  Solves part one of the puzzle by computing how many pixels are lit after
  enhancing the image in the given input file twice.

  ## Examples

      iex> Day20.part_one("example.txt")
      35

      iex> Day20.part_one("input.txt")
      4873
  """
  def part_one(input_file) do
    {algorithm, image} = File.read!(input_file) |> parse()

    outside_lit_fun = outside_lit_behaviour(algorithm)

    image
    |> enhance(algorithm, outside_lit_fun, 0)
    |> enhance(algorithm, outside_lit_fun, 1)
    |> Enum.count()
  end

  @doc ~S"""
  Solves part one of the puzzle by computing how many pixels are lit after
  enhancing the image in the given input file 50 times.

  ## Examples

      iex> Day20.part_two("example.txt")
      3351

      iex> Day20.part_two("input.txt")
      16394
  """
  def part_two(input_file) do
    {algorithm, image} = File.read!(input_file) |> parse()

    outside_lit_fun = outside_lit_behaviour(algorithm)

    0..49
    |> Enum.reduce(image, fn step_no, image ->
      enhance(image, algorithm, outside_lit_fun, step_no)
    end)
    |> Enum.count()
  end

  def parse(input) do
    [algorithm | image] = String.split(input)

    algorithm =
      for {?#, i} <- Enum.with_index(to_charlist(algorithm)), into: %MapSet{} do
        i
      end

    image =
      for {line, y} <- Enum.with_index(image),
          {?#, x} <- Enum.with_index(to_charlist(line)),
          into: %MapSet{} do
        {x, y}
      end

    {algorithm, image}
  end

  def outside_lit_behaviour(algorithm) do
    case {MapSet.member?(algorithm, 0), MapSet.member?(algorithm, 511)} do
      {false, _} -> fn _step_no -> false end
      {true, false} -> fn step_no -> Integer.is_odd(step_no) end
      {true, true} -> fn step_no -> step_no > 0 end
    end
  end

  def enhance(image, algorithm, outside_lit_fun, step_no) do
    outside_lit? = outside_lit_fun.(step_no)

    {x_coords, y_coords} = Enum.unzip(image)

    {min_x, max_x} = Enum.min_max(x_coords)
    {min_y, max_y} = Enum.min_max(y_coords)

    for y <- (min_y - 1)..(max_y + 1),
        x <- (min_x - 1)..(max_x + 1),
        MapSet.member?(
          algorithm,
          index(image, {x, y}, outside_lit?, {{min_x, max_x}, {min_y, max_y}})
        ),
        into: %MapSet{} do
      {x, y}
    end
  end

  def index(image, {x, y}, outside_lit?, {{min_x, max_x}, {min_y, max_y}}) do
    for y <- (y - 1)..(y + 1), x <- (x - 1)..(x + 1) do
      out_of_bounds? = y < min_y or y > max_y or x < min_x or x > max_x

      if (out_of_bounds? and outside_lit?) or MapSet.member?(image, {x, y}) do
        1
      else
        0
      end
    end
    |> Integer.undigits(2)
  end
end
