defmodule AOC do
  @moduledoc """
  Documentation for `AOC`.
  """

  @priv_dir "./priv/inputs"

  def day_1(input_file \\ "day_1.txt") do
    {list_1, list_2} =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "   "))
      |> Enum.reduce({[], []}, fn
        [n_1, n_2], {acc_1, acc_2} ->
          {[String.to_integer(n_1) | acc_1], [String.to_integer(n_2) | acc_2]}

        _otherwise, acc ->
          acc
      end)

    part_1_result = day_1_part_1(Enum.reverse(list_1), Enum.reverse(list_2))
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_1_part_2(Enum.reverse(list_1), Enum.reverse(list_2))
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  Pair up two lists of integers from smallest to largest and return the sum of
  the differences between each pair.

  ## Examples

      iex> AOC.day_1_part_1([1, 2, 3], [1, 2, 3])
      0

      iex> AOC.day_1_part_1([1, 2, 3], [3, 2, 1])
      0

      iex> AOC.day_1_part_1([1, 2, 3], [3, 5, 1])
      3

      iex> AOC.day_1_part_1([3, 4, 2, 1, 3, 3], [4, 3, 5, 3, 9, 1])
      9

  """
  def day_1_part_1(list_1, list_2) do
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

      iex> AOC.day_1_part_2([1, 2, 3, 4, 5], [])
      0

      iex> AOC.day_1_part_2([1, 2, 3, 4, 5], [1, 2, 3, 4, 5])
      15

      iex> AOC.day_1_part_2([3, 4, 2, 1, 3, 3], [4, 3, 6, 3, 9, 3])
      31

  """
  def day_1_part_2(list_1, list_2) do
    frequencies = Enum.frequencies(list_2)

    list_1
    |> Enum.map(fn n -> n * Map.get(frequencies, n, 0) end)
    |> Enum.sum()
  end
end
