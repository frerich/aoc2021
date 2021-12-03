defmodule Day3 do
  @doc ~S"""
  Solves part one of the puzzle by computing the power consumption of the
  submarine.

  ## Examples

      iex> Day3.part_one
      3549854
  """
  def part_one() do
    File.read!("input.txt") |> parse() |> power_consumption()
  end

  @doc ~S"""
  Parses some input data into a list of charlists.

  ## Examples

      iex> Day3.parse("")
      []

      iex> Day3.parse("00100\n11110\n10110")
      ['00100', '11110', '10110']
  """
  def parse(data) when is_binary(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&to_charlist/1)
  end

  @doc ~S"""
  Compute the power consumption of a submarine.

  ## Examples

      iex> report = Day3.parse("00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010")
      iex> Day3.power_consumption(report)
      198
  """
  def power_consumption(report) when is_list(report) do
    gamma_rate(report) * epsilon_rate(report)
  end

  @doc ~S"""
  Computes the gamma rate given a submarine report.

  ## Examples

      iex> Day3.gamma_rate(['00100', '11110', '10110'])
      22
  """
  def gamma_rate(report) when is_list(report) do
    report
    |> most_common_bits()
    |> to_string()
    |> String.to_integer(2)
  end

  @doc ~S"""
  Computes the epsilon rate given a submarine report.

  ## Examples

      iex> Day3.epsilon_rate(['00100', '11110', '10110'])
      9
  """
  def epsilon_rate(report) when is_list(report) do
    report
    |> most_common_bits()
    |> Enum.map(fn
      ?0 -> ?1
      ?1 -> ?0
    end)
    |> to_string()
    |> String.to_integer(2)
  end

  @doc ~S"""
  Given a report, returns the most common bit in each position.

  ## Examples

      iex> Day3.most_common_bits(['00100', '11110', '10110'])
      '10110'
  """
  def most_common_bits(report) when is_list(report) do
    report
    |> Enum.zip()
    |> Enum.map(fn tuple -> most_common(Tuple.to_list(tuple)) end)
  end

  @doc ~S"""
  Identifies the most commonly occurring element. Returns the first found
  element if there are multiple possible elements.

  ### Examples

      iex> Day3.most_common([1,2,3,2,1,2])
      2

      iex> Day3.most_common([1,2,3,2,1])
      1
  """
  def most_common(enum) do
    enum
    |> Enum.frequencies()
    |> Enum.max_by(fn {_x, freq} -> freq end)
    |> then(fn {x, _freq} -> x end)
  end

  @doc ~S"""
  Solves part two of the puzzle by computing the life support rating of the
  submarine.

  ## Examples

      iex> Day3.part_two
      3765399
  """
  def part_two() do
    File.read!("input.txt") |> parse() |> life_support_rating()
  end

  @doc ~S"""
  Compute the life support rating of a submarine.

  ## Examples
      iex> report = Day3.parse("00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010")
      iex> Day3.life_support_rating(report)
      230
  """
  def life_support_rating(report) when is_list(report) do
    oxygen_generator_rating(report) * co2_scrubber_rating(report)
  end

  @doc ~S"""
  Compute the oxygen generator rating.

  ## Examples

      iex> report = Day3.parse("00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010")
      iex> Day3.oxygen_generator_rating(report)
      23
  """
  def oxygen_generator_rating(report) when is_list(report) do
    prune_report(report, fn numbers_with_zero, numbers_with_one ->
      if Enum.count(numbers_with_zero) > Enum.count(numbers_with_one) do
        numbers_with_zero
      else
        numbers_with_one
      end
    end)
  end

  @doc ~S"""
  Compute the CO2 scrubber rating.

  ## Examples

      iex> report = Day3.parse("00100\n11110\n10110\n10111\n10101\n01111\n00111\n11100\n10000\n11001\n00010\n01010")
      iex> Day3.co2_scrubber_rating(report)
      10
  """
  def co2_scrubber_rating(report) when is_list(report) do
    prune_report(report, fn numbers_with_zero, numbers_with_one ->
      if Enum.count(numbers_with_zero) > Enum.count(numbers_with_one) do
        numbers_with_one
      else
        numbers_with_zero
      end
    end)
  end

  defp prune_report([number | _] = report, fun) when is_function(fun, 2) do
    num_bits_per_number = Enum.count(number)

    0..num_bits_per_number
    |> Enum.reduce(report, fn
      _index, [number] ->
        [number]

      index, numbers ->
        {numbers_with_zero, numbers_with_one} =
          Enum.split_with(numbers, fn number -> Enum.at(number, index) === ?0 end)

        fun.(numbers_with_zero, numbers_with_one)
    end)
    |> Enum.at(0)
    |> to_string()
    |> String.to_integer(2)
  end
end
