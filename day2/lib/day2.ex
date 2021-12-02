defmodule Day2 do
  def input do
    "input.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [command, arg] = String.split(line)
      {command, String.to_integer(arg)}
    end)
  end

  def part_one() do
    {pos, depth} =
      input()
      |> Enum.reduce({0, 0}, fn
        {"forward", n}, {pos, depth} -> {pos + n, depth}
        {"down", n}, {pos, depth} -> {pos, depth + n}
        {"up", n}, {pos, depth} -> {pos, depth - n}
      end)

    pos * depth
  end

  def part_two() do
    {pos, depth, _aim} =
      input()
      |> Enum.reduce({0, 0, 0}, fn
        {"forward", n}, {pos, depth, aim} -> {pos + n, depth + aim * n, aim}
        {"down", n}, {pos, depth, aim} -> {pos, depth, aim + n}
        {"up", n}, {pos, depth, aim} -> {pos, depth, aim - n}
      end)

    pos * depth
  end
end
