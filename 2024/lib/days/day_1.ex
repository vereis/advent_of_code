defmodule AOC.Days.Day_1 do
  @doc """
  Pair up two lists of integers from smallest to largest and return the sum of
  the differences between each pair.

  ## Examples

      iex> AOC.Days.Day_1.part_1([1, 2, 3], [1, 2, 3])
      0

      iex> AOC.Days.Day_1.part_1([1, 2, 3], [3, 2, 1])
      0

      iex> AOC.Days.Day_1.part_1([1, 2, 3], [3, 5, 1])
      3

      iex> AOC.Days.Day_1.part_1([3, 4, 2, 1, 3, 3], [4, 3, 5, 3, 9, 1])
      9

  """
  def part_1(list_1, list_2) do
    list_1
    |> Enum.sort()
    |> Enum.zip(Enum.sort(list_2))
    |> Enum.reduce(0, fn {a, b}, acc -> acc + abs(a - b) end)
  end

  @doc """
  Multiply each element of the first list by the frequency of that element in the
  second list and return the sum of the products, frequency is 0 if the element
  is not present in the second list.

  ## Examples

      iex> AOC.Days.Day_1.part_2([1, 2, 3, 4, 5], [])
      0

      iex> AOC.Days.Day_1.part_2([1, 2, 3, 4, 5], [1, 2, 3, 4, 5])
      15

      iex> AOC.Days.Day_1.part_2([3, 4, 2, 1, 3, 3], [4, 3, 6, 3, 9, 3])
      31

  """
  def part_2(list_1, list_2) do
    frequencies = Enum.frequencies(list_2)

    list_1
    |> Enum.map(fn n -> n * Map.get(frequencies, n, 0) end)
    |> Enum.sum()
  end
end
