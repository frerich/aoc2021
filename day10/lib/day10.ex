defmodule Day10 do
  @doc ~S"""
  Solves part one of the puzzle by summing the scores for all corrupt lines.

  ## Examples

      iex> Day10.part_one("example.txt")
      26397

      iex> Day10.part_one("input.txt")
      271245
  """
  def part_one(input_file \\ "input.txt") do
    lines = input_file |> File.read!() |> parse() |> Enum.map(&classify/1)

    Enum.sum(for {:corrupt, x} <- lines, do: score_corrupt_line(x))
  end

  @doc ~S"""
  Parses some puzzle input into a convenient format: a list of charlists.

  ## Examples

      iex> Day10.parse("()[]\n{}{}\n(<>)")
      ['()[]', '{}{}', '(<>)']
  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
  end

  @doc ~S"""
  Classifies a line for whether it's valid, incomplete or corrupt.

  ## Examples

      iex> Day10.classify('()')
      :valid

      iex> Day10.classify('{()()()}')
      :valid

      iex> Day10.classify('[<>({}){}[([])<>]]')
      :valid

      iex> Day10.classify('(]')
      {:corrupt, ?]}

      iex> Day10.classify('{()()()>')
      {:corrupt, ?>}

      iex> Day10.classify('<([]){()}[{}])')
      {:corrupt, ?)}

      iex> Day10.classify('<{([([[(<>()){}]>(<<{{')
      {:corrupt, ?>}

      iex> Day10.classify('[(()[<>])]({[<{<<[]>>(')
      {:incomplete, ')}>]})'}
  """
  def classify(line) do
    Enum.reduce_while(line, [], fn
      ?(, closing -> {:cont, [?) | closing]}
      ?[, closing -> {:cont, [?] | closing]}
      ?{, closing -> {:cont, [?} | closing]}
      ?<, closing -> {:cont, [?> | closing]}
      x, [x | closing] -> {:cont, closing}
      x, _closing -> {:halt, x}
    end)
    |> case do
      [] -> :valid
      [_ | _] = missing_chars -> {:incomplete, missing_chars}
      x -> {:corrupt, x}
    end
  end

  @doc ~S"""
  Calculates the score of a correupt line based on the first corrupt (i.e.
  unexpected) character in a line.

  ## Examples

      iex> Day10.score_corrupt_line(?))
      3

      iex> Day10.score_corrupt_line(?})
      1197
  """
  def score_corrupt_line(?)), do: 3
  def score_corrupt_line(?]), do: 57
  def score_corrupt_line(?}), do: 1197
  def score_corrupt_line(?>), do: 25137

  @doc ~S"""
  Solves part two of the puzzle by computing the median of all scores for
  incomplete lines.

  ## Examples

      iex> Day10.part_two("example.txt")
      288957

      iex> Day10.part_two("input.txt")
      1685293086
  """
  def part_two(input_file \\ "input.txt") do
    lines = input_file |> File.read!() |> parse() |> Enum.map(&classify/1)

    scores = for {:incomplete, unclosed} <- lines, do: score_incomplete_line(unclosed)

    Enum.at(Enum.sort(scores), div(length(scores), 2))
  end

  @doc ~S"""
  Calculates the score of an incomplete line based on the characters which are
  needed to complete the line.

  ## Examples

      iex> Day10.score_incomplete_line('])}>')
      294

      iex> Day10.score_incomplete_line('}}]])})]')
      288957

      iex> Day10.score_incomplete_line(')}>]})')
      5566

      iex> Day10.score_incomplete_line('}}>}>))))')
      1480781

      iex> Day10.score_incomplete_line(']]}}]}]}>')
      995444
  """
  def score_incomplete_line(missing_chars) do
    Enum.reduce(missing_chars, 0, fn
      ?), score -> score * 5 + 1
      ?], score -> score * 5 + 2
      ?}, score -> score * 5 + 3
      ?>, score -> score * 5 + 4
    end)
  end
end
