defmodule Day12 do
  @doc ~S"""
  Solves part one of the puzzle by calculating the number of distinct paths in
  the given input, going from 'start' to 'end'.

  ## Examples

      iex> Day12.part_one("example1.txt")
      10

      iex> Day12.part_one("example2.txt")
      19

      iex> Day12.part_one("example3.txt")
      226

      iex> Day12.part_one("input.txt")
      3679
  """
  def part_one(input_file \\ "input.txt") do
    input_file
    |> File.read!()
    |> parse()
    |> paths("start", "end", fn cave, visited -> large_cave?(cave) or cave not in visited end)
    |> Enum.count()
  end

  @doc ~S"""
  Parse puzzle input.

  ## Examples

      iex> Day12.parse("a-b\na-c")
      %{"a" => ["b", "c"], "b" => ["a"], "c" => ["a"]}
  """
  def parse(input) do
    input
    |> String.split()
    |> Enum.flat_map(fn line ->
      [a, b] = String.split(line, "-")
      [{a, b}, {b, a}]
    end)
    |> Enum.group_by(fn {src, _dst} -> src end, fn {_src, dst} -> dst end)
  end

  @doc ~S"""
  Calculates all paths the graph `graph` going from `src` to `dest` based on a
  given `reachable_fun` giving the valid neighboring caves.

  ## Examples

      iex> "a-b\nb-c" |> Day12.parse() |> Day12.paths("a", "c", fn cave, seen -> cave not in seen end)
      ...> |> Enum.sort()
      [["a", "b", "c"]]

      iex> "a-b\na-c\nb-d\nc-d" |> Day12.parse() |> Day12.paths("a", "d", fn cave, seen -> cave not in seen end)
      ...> |> Enum.sort()
      [["a", "b", "d"], ["a", "c", "d"]]

      iex> "start-B\nstart-c\nB-c\nB-end\nc-end" |> Day12.parse() |> Day12.paths("start", "end", fn cave, seen ->
      ...>   cave == String.upcase(cave) or cave not in seen
      ...> end)
      ...> |> Enum.sort()
      [["start", "B", "c", "B", "end"], ["start", "B", "c", "end"], ["start", "B", "end"], ["start", "c", "B", "end"], ["start", "c", "end"]]
  """
  def paths(map, src, dst, can_enter_cave?, visited \\ [])

  def paths(_map, dst, dst, _can_enter_cave?, visited),
    do: [Enum.reverse([dst | visited])]

  def paths(map, src, dst, can_enter_cave?, visited) do
    visited = [src | visited]

    for neighbor <- Map.fetch!(map, src),
        can_enter_cave?.(neighbor, visited),
        path <- paths(map, neighbor, dst, can_enter_cave?, visited) do
      path
    end
  end

  @doc ~S"""
  Tests if the given cave is a large cave.

  ## Examples

      iex> Day12.large_cave?("start")
      false

      iex> Day12.large_cave?("TW")
      true
  """
  def large_cave?(<<char, _rest::binary>>), do: char >= ?A and char <= ?Z

  @doc ~S"""
  Solves part two of the puzzle by calculating the number of distinct paths in
  the given input, going from 'start' to 'end' -- this time however, a single
  small cave may be visited twice.

  ## Examples

      iex> Day12.part_two("example1.txt")
      36

      iex> Day12.part_two("example2.txt")
      103

      iex> Day12.part_two("example3.txt")
      3509

      iex> Day12.part_two("input.txt")
      107395
  """
  def part_two(input_file \\ "input.txt") do
    input_file
    |> File.read!()
    |> parse()
    |> paths("start", "end", fn
      _neighbor, ["end" | _rest] ->
        false

      "start", _visited ->
        false

      cave, visited ->
        large_cave?(cave) or cave not in visited or all_unique?(Enum.reject(visited, &large_cave?/1))
    end)
    |> Enum.count()
  end

  @doc ~S"""
  Tests if all elements in the given list are unique.

  ## Examples

      iex> Day12.all_unique?([3,4,1,6])
      true

      iex> Day12.all_unique?([3,4,1,3,6])
      false
  """
  def all_unique?(list) do
    tails(list) |> Enum.all?(fn [h | t] -> h not in t end)
  end

  @doc ~S"""
  Returns the given list followed by all non-empty tails of the given list.

  ## Examples

      iex> Day12.tails([1,2,3])
      [[1,2,3], [2,3], [3]]
  """
  def tails([]), do: []
  def tails([_ | t] = list), do: [list | tails(t)]
end
