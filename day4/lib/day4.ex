defmodule Day4 do
  @doc ~S"""
  Computes the final score when choosing the winning board.

  ## Examples

      iex> Day4.part_one("example.txt")
      4512

      iex> Day4.part_one("input.txt")
      51776
  """
  def part_one(input_file \\ "input.txt") do
    {numbers, boards} = parse(File.read!(input_file))

    {marked_numbers, winning_board} =
      boards
      |> winners(numbers)
      |> Enum.min_by(fn {marked_numbers, _board} -> Enum.count(marked_numbers) end)

    score(winning_board, marked_numbers)
  end

  @doc ~S"""
  Computes the final score when choosing the losing board.

  ## Examples

      iex> Day4.part_two("example.txt")
      1924

      iex> Day4.part_two("input.txt")
      16830
  """
  def part_two(input_file \\ "input.txt") do
    {numbers, boards} = parse(File.read!(input_file))

    {marked_numbers, losing_board} =
      boards
      |> winners(numbers)
      |> Enum.max_by(fn {marked_numbers, _board} -> Enum.count(marked_numbers) end)

    score(losing_board, marked_numbers)
  end

  @doc ~S"""
  Parses some puzzle input.

  ## Examples

      iex> Day4.parse("
      ...> 6,2,8,1,3,9,4,5
      ...>
      ...> 1 2 3
      ...> 4 5 6
      ...> 7 8 9
      ...>
      ...> 9 8 7
      ...> 6 5 4
      ...> 3 2 1
      ...> ")
      {[6,2,8,1,3,9,4,5], [[[1,2,3],[4,5,6],[7,8,9]], [[9,8,7],[6,5,4],[3,2,1]]]}
  """
  def parse(input) do
    [numbers | boards] = input |> String.trim() |> String.split("\n\n")

    {parse_numbers(numbers, ","), Enum.map(boards, &parse_board/1)}
  end

  @doc ~S"""
  Parses a line `input` of numbers (separated by `sep`) into a list of
  integers.

  ## Examples

      iex> Day4.parse_numbers("1,4,84,3,123", ",")
      [1,4,84,3,123]

      iex> Day4.parse_numbers(" 1  8 13 24  9", " ")
      [1,8,13,24,9]
  """
  def parse_numbers(input, sep) do
    input
    |> String.split(sep, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc ~S"""
  Parses a board.

  ## Examples

      iex> Day4.parse_board("
      ...>  3 24 19
      ...> 12  8 17
      ...>  9 11 10
      ...> ")
      [[3,24,19],[12,8,17],[9,11,10]]
  """
  def parse_board(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> parse_numbers(line, " ") end)
  end

  @doc ~S"""
  Computes the numbers to be drawn for any of the given boards to win.

  ## Examples

      iex> board_a = [[1,2,3],[4,5,6],[7,8,9]]
      iex> board_b = [[1,5,3],[2,6,4],[8,7,9]]
      iex> Day4.winners([board_a, board_b], [4,7,2,3,1,6,5,9,8])
      [{[4,7,2,3,1], board_a}, {[4,7,2,3,1,6], board_b}]
  """
  def winners(boards, numbers) do
    boards
    |> Enum.map(fn board ->
      numbers
      |> heads()
      |> Enum.find_value(fn marked_numbers ->
        if wins?(board, marked_numbers) do
          {marked_numbers, board}
        end
      end)
    end)
  end

  @doc ~S"""
  Checks if a given board `board` wins assuming that `marked_numbers` is the
  list of marked numbers.

  ## Examples

      iex> Day4.wins?([[1,2,3],[4,5,6],[7,8,9]], [1,4,8])
      false

      iex> Day4.wins?([[1,2,3],[4,5,6],[7,8,9]], [1,4,7])
      true

      iex> Day4.wins?([[1,2,3],[4,5,6],[7,8,9]], [5,4,6])
      true
  """
  def wins?(board, marked_numbers) when is_list(board) and is_list(marked_numbers) do
    any_row_complete?(board, marked_numbers) or
      any_row_complete?(transpose(board), marked_numbers)
  end

  @doc ~S"""
  Tests if any row in the given board has all numbers marked.

  ## Examples

      iex> Day4.any_row_complete?([[1,2,3],[4,5,6],[7,8,9]], [1,9,2])
      false

      iex> Day4.any_row_complete?([[1,2,3],[4,5,6],[7,8,9]], [1,3,2])
      true
  """
  def any_row_complete?(board, marked_numbers) do
    Enum.any?(board, fn row ->
      row -- marked_numbers === []
    end)
  end

  @doc ~S"""
  Computes the final score of a board considering a given list of marked numbers.

  ## Examples

      iex> Day4.score([[1,2,3],[4,5,6],[7,8,9]], [1,8,2,7,3,9,6,4,5])
      0

      iex> Day4.score([[1,2,3],[4,5,6],[7,8,9]], [1,8,2,7,3,9])
      135
  """
  def score(board, marked_numbers) do
    unmarked_numbers =
      board
      |> List.flatten()
      |> Enum.reject(&(&1 in marked_numbers))

    last_number_called = Enum.at(marked_numbers, -1)

    Enum.sum(unmarked_numbers) * last_number_called
  end

  @doc ~S"""
  Returns all heads of the given enumerator.

  ## Examples

      iex> Day4.heads([])
      []

      iex> Day4.heads([1,2,3])
      [[1], [1,2], [1,2,3]]
  """
  def heads(enum) do
    enum
    |> Enum.scan([], fn x, acc -> [x | acc] end)
    |> Enum.map(&Enum.reverse/1)
  end

  @doc ~S"""
  Tranposes the given enumerator.

  ## Examples

      iex> Day4.transpose([])
      []

      iex> Day4.transpose([[1,2,3],[4,5,6],[7,8,9]])
      [[1,4,7],[2,5,8],[3,6,9]]
  """
  def transpose(enum) do
    Enum.zip_with(enum, & &1)
  end
end
