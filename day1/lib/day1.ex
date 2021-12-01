defmodule Day1 do
  def input do
    "input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      {i, ""} = Integer.parse(s)
      i
    end)
  end

  def windows(enum, len) do
    Stream.chunk_every(enum, len, 1, :discard)
  end

  def part_one() do
    input()
    |> windows(2)
    |> Enum.count(fn [a, b] -> b > a end)
  end

  def part_two() do
    input()
    |> windows(3)
    |> Enum.map(&Enum.sum/1)
    |> windows(2)
    |> Enum.count(fn [a, b] -> b > a end)
  end
end
