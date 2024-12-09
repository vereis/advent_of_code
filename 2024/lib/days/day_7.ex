defmodule AOC.Days.Day_7 do
  @doc """
  Given some input containing a possible answer, and a list of equation w/ missing
  operators, see if the answer is correct.

  Available operands can be added left to right, and must be either `*` or `+`

  ## Examples

         iex> AOC.Days.Day_7.part_1(\"""
         ...> 190: 10 19
         ...> \""")
         190

         iex> AOC.Days.Day_7.part_1(\"""
         ...> 3267: 81 40 27
         ...> \""")
         3267

         iex> AOC.Days.Day_7.part_1(\"""
         ...> 292: 11 6 16 20
         ...> \""")
         292

         iex> AOC.Days.Day_7.part_1(\"""
         ...> 21037: 9 7 18 13
         ...> \""")
         0

         iex> AOC.Days.Day_7.part_1(\"""
         ...> 190: 10 19
         ...> 3267: 81 40 27
         ...> 83: 17 5
         ...> 156: 15 6
         ...> 7290: 6 8 6 15
         ...> 161011: 16 10 13
         ...> 192: 17 8 14
         ...> 21037: 9 7 18 13
         ...> 292: 11 6 16 20
         ...> \""")
         3749

  """
  def part_1(input) do
    equations = setup(input)

    equations
    |> Enum.filter(fn {answer, numbers} -> part_1_valid?(numbers, answer) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part_1_valid?(numbers, answer, acc \\ 0)

  def part_1_valid?([], answer, acc) do
    acc == answer
  end

  def part_1_valid?([x | rest], answer, acc) do
    part_1_valid?(rest, answer, x + acc) ||
      part_1_valid?(rest, answer, x * (acc || 1))
  end

  @doc """
  Same as `part_1/1` but with an additional concatenation operator, where `1 || 1 == 11`.

  ## Examples

         iex> AOC.Days.Day_7.part_2(\"""
         ...> 156: 15 6
         ...> \""")
         156

         iex> AOC.Days.Day_7.part_2(\"""
         ...> 7290: 6 8 6 15
         ...> \""")
         7290

         iex > AOC.Days.Day_7.part_2(\"""
         ...> 192: 17 8 14
         ...> \""")
         192

  """
  def part_2(input) do
    equations = setup(input)

    equations
    |> Enum.filter(fn {answer, numbers} -> part_2_valid?(numbers, answer) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part_2_valid?(numbers, answer, acc \\ 0)

  def part_2_valid?([], answer, acc) do
    acc == answer
  end

  def part_2_valid?([x | rest], answer, acc) do
    part_2_valid?(rest, answer, x + acc) ||
      part_2_valid?(rest, answer, x * (acc || 1)) ||
      part_2_valid?(rest, answer, String.to_integer("#{acc || ""}#{x}"))
  end

  def setup(input) do
    for input <- String.split(input, "\n", trim: true) do
      [answer, numbers] = String.split(input, ": ", trim: true)
      numbers = numbers |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

      {String.to_integer(answer), numbers}
    end
  end
end
