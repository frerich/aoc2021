defmodule Day13 do
  @doc ~S"""
  Solves part one of the puzzle by counting the number of dots in the input file
  after executing the first instruction in the input file.

  ## Examples

      iex> Day13.part_one("example.txt")
      17

      iex> Day13.part_one("input.txt")
      704
  """
  def part_one(input_file \\ "input.txt") do
    {sheet, [instruction | _]} = File.read!(input_file) |> parse()

    exec(instruction, sheet) |> Enum.count()
  end

  @doc ~S"""
  Parse some puzzle input into a 2-tuple in which the first element is a MapSet of all
  dots on the sheet of origami sheet and the second element is a sequence of folding
  instructions.

  ## Examples

      iex> Day13.parse("
      ...>6,10
      ...>41,7
      ...>
      ...>fold along x=15
      ...>fold along y=3
      ...>")
      {MapSet.new([{6, 10}, {41, 7}]), [fold_x: 15, fold_y: 3]}
  """
  def parse(input) do
    [coords, instructions] = String.split(input, "\n\n")

    coords = for line <- String.split(coords) do
      [x,y] = String.split(line, ",")
      {String.to_integer(x), String.to_integer(y)}
    end

    instructions = for line <- String.split(instructions, "\n", trim: true) do
      case line do
        <<"fold along x=", x::binary>> -> {:fold_x, String.to_integer(x)}
        <<"fold along y=", y::binary>> -> {:fold_y, String.to_integer(y)}
      end
    end

    {MapSet.new(coords), instructions}
  end

  @doc ~S"""
  Helper function for dispatching folding instructions to the right folding
  function.
  """
  def exec({:fold_x, x}, sheet), do: fold_at_x(sheet, x)
  def exec({:fold_y, y}, sheet), do: fold_at_y(sheet, y)

  @doc ~S"""
  Folds a sheet or origami sheet at the given Y coordinate (i.e. it folds horizontally).
  """
  def fold_at_y(sheet, fold_y) do
    {top_half, bottom_half} = Enum.split_with(sheet, fn {_x, y} -> y < fold_y end)
    {_x, max_y} = Enum.max_by(bottom_half, fn {_x, y} -> y end)
    flipped_bottom = MapSet.new(bottom_half, fn {x, y} -> {x, max_y - y} end)
    MapSet.union(MapSet.new(top_half), flipped_bottom)
  end

  @doc ~S"""
  Folds a sheet or origami sheet at the given Y coordinate (i.e. it folds vertically).
  """
  def fold_at_x(sheet, fold_x) do
    {left_half, right_half} = Enum.split_with(sheet, fn {x, _y} -> x < fold_x end)
    {max_x, _y} = Enum.max_by(right_half, fn {x, _y} -> x end)
    flipped_right = MapSet.new(right_half, fn {x, y} -> {max_x - x, y} end)
    MapSet.union(MapSet.new(left_half), flipped_right)
  end

  @doc ~S"""
  Solves part two of the puzzle by performing all folding steps in the given
  input file and then rendering the result.
  """
  def part_two(input_file \\ "input.txt") do
    {sheet, instructions} = File.read!(input_file) |> parse()

    instructions
    |> Enum.reduce(sheet, &exec/2)
    |> render()
    |> IO.puts()
  end

  @doc ~S"""
  Returns a string rendering of the given origami sheet.
  """
  def render(sheet) do
    {max_x, _y} = Enum.max_by(sheet, fn {x, _y} -> x end)
    {_x, max_y} = Enum.max_by(sheet, fn {_x, y} -> y end)

    Enum.map_join(0..max_y, "\n", fn y ->
      Enum.map_join(0..max_x, "", fn x ->
        if {x,y} in sheet, do: "#", else: "."
      end)
    end)
  end
end
