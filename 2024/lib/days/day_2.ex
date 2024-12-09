defmodule AOC.Days.Day_2 do
  @doc """
  For each given report, check if that report is either:

    - All pairs are in increasing order
    - Or, all pairs are in decreasing order

  And also, check if the difference between each pair is in the range of `1..3`.

  ## Examples

      iex> AOC.Days.Day_2.part_1([[1, 2, 3, 4]])
      1

      iex> AOC.Days.Day_2.part_1([[4, 3, 2, 1]])
      1

      iex> AOC.Days.Day_2.part_1([[100, 10, 0, -10]])
      0

      iex> AOC.Days.Day_2.part_1([
      ...>   [7, 6, 4, 2, 1],  # Safe
      ...>   [1, 2, 7, 8, 9],  # Unsafe - delta {2, 7} not in 1..3
      ...>   [9, 7, 6, 2, 1],  # Unsafe - delta {7, 6} not in 1..3
      ...>   [1, 3, 2, 4, 5],  # Unsafe - {1, 3} is inc but {3, 2} is dec
      ...>   [8, 6, 4, 4, 1],  # Unsafe - {4, 4} is neither inc or dec
      ...>   [1, 3, 6, 7, 9],  # Safe
      ...> ])
      2

  """
  def part_1(reports) do
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
  Similar to `part_1/1`, where we check if the report is either:

    - All pairs are in increasing order
    - Or, all pairs are in decreasing order

  And also, check if the difference between each pair is in the range of `1..3`.

  But importantly, this time, we're allowed to permit a single bad level in any
  given report.

  ## Examples

      iex> AOC.Days.Day_2.part_2([
      ...>   [7, 6, 4, 2, 1],  # Safe
      ...>   [1, 2, 7, 8, 9],  # Unsafe - delta {2, 7} not in 1..3
      ...>   [9, 7, 6, 2, 1],  # Unsafe - delta {7, 6} not in 1..3
      ...>   [1, 3, 2, 4, 5],  # Safe - Removing `3` makes this safe
      ...>   [8, 6, 4, 4, 1],  # Safe - Removing `4` makes this safe
      ...>   [1, 3, 6, 7, 9],  # Safe
      ...> ])
      4

  """
  def part_2(reports) do
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
