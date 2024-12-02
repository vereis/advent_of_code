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

  def day_2(input_file \\ "day_2.txt") do
    reports =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.split(&1, " "))
      |> Enum.reject(&match?([""], &1))
      |> Enum.map(fn x -> Enum.map(x, &String.to_integer/1) end)

    part_1_result = day_2_part_1(reports)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_2_part_2(reports)
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  For each given report, check if that report is either:

    - All pairs are in increasing order
    - Or, all pairs are in decreasing order

  And also, check if the difference between each pair is in the range of `1..3`.

  ## Examples

      iex> AOC.day_2_part_1([[1, 2, 3, 4]])
      1

      iex> AOC.day_2_part_1([[4, 3, 2, 1]])
      1

      iex> AOC.day_2_part_1([[100, 10, 0, -10]])
      0

      iex> AOC.day_2_part_1([
      ...>   [7, 6, 4, 2, 1],  # Safe
      ...>   [1, 2, 7, 8, 9],  # Unsafe - delta {2, 7} not in 1..3
      ...>   [9, 7, 6, 2, 1],  # Unsafe - delta {7, 6} not in 1..3
      ...>   [1, 3, 2, 4, 5],  # Unsafe - {1, 3} is inc but {3, 2} is dec
      ...>   [8, 6, 4, 4, 1],  # Unsafe - {4, 4} is neither inc or dec
      ...>   [1, 3, 6, 7, 9],  # Safe
      ...> ])
      2

  """
  def day_2_part_1(reports) do
    all_increasing? = fn pairs ->
      Enum.all?(pairs, fn {a, b} -> a <= b end)
    end

    all_decreasing? = fn pairs ->
      Enum.all?(pairs, fn {a, b} -> a >= b end)
    end

    safe_delta? = fn pairs ->
      Enum.all?(pairs, fn {a, b} -> abs(b - a) in 1..3 end)
    end

    for [head | tails] <- reports,
        pairs = Enum.zip([head | tails], tails),
        all_increasing?.(pairs) or all_decreasing?.(pairs),
        safe_delta?.(pairs),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  @doc """
  Similar to `day_2_part_1/1`, where we check if the report is either:

    - All pairs are in increasing order
    - Or, all pairs are in decreasing order

  And also, check if the difference between each pair is in the range of `1..3`.

  But importantly, this time, we're allowed to permit a single bad level in any
  given report.

  ## Examples

      iex> AOC.day_2_part_2([
      ...>   [7, 6, 4, 2, 1],  # Safe
      ...>   [1, 2, 7, 8, 9],  # Unsafe - delta {2, 7} not in 1..3
      ...>   [9, 7, 6, 2, 1],  # Unsafe - delta {7, 6} not in 1..3
      ...>   [1, 3, 2, 4, 5],  # Safe - Removing `3` makes this safe
      ...>   [8, 6, 4, 4, 1],  # Safe - Removing `4` makes this safe
      ...>   [1, 3, 6, 7, 9],  # Safe
      ...> ])
      4

  """
  def day_2_part_2(reports) do
    validate_levels = fn levels when levels != [] ->
      count = Enum.count(levels)

      # Generate a list of all possible permutations of the given levels
      # by removing any single level from the list.
      permutations =
        for idx <- 0..count, permutation = List.delete_at(levels, idx) do
          permutation
        end

      # Then generate pairs for these permutations.
      permutation_pairs =
        for [head | tails] <- permutations,
            pairs = Enum.zip([head | tails], tails) do
          pairs
        end

      # The overall `levels` is safe if any single permutation is safe.
      Enum.any?(permutation_pairs, fn pairs ->
        all_increasing = Enum.all?(pairs, fn {a, b} -> a > b end)
        all_decreasing = Enum.all?(pairs, fn {a, b} -> a < b end)
        within_delta = Enum.all?(pairs, fn {a, b} -> abs(a - b) in 1..3 end)

        (all_increasing || all_decreasing) && within_delta
      end)
    end

    reports
    |> Enum.filter(validate_levels)
    |> Enum.count()
  end
end
