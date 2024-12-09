defmodule AOC.Days.Day_3 do
  @doc """
  Given some string, try to extract the supported symbols and their arguments,
  and then evaluate the expression.

  Importantly, ignore any non-matching symbols.

  ## Examples

      iex> AOC.Days.Day_3.part_1("")
      0

      iex> AOC.Days.Day_3.part_1("Junk")
      0

      iex> AOC.Days.Day_3.part_1("mul(4*")
      0

      iex> AOC.Days.Day_3.part_1("mul(1, 2)")
      0

      iex> AOC.Days.Day_3.part_1("mul(2,2)")
      4

      iex> AOC.Days.Day_3.part_1("mul(2,2)!!randomnoise//mul(2,2)")
      8

  """
  def part_1(input) do
    parser = ~r/(mul)\((\d\d?\d?),(\d\d?\d?)\)/

    parser
    |> Regex.scan(input)
    |> Enum.reduce(0, fn
      [_full_match, "mul", a, b], acc ->
        acc + String.to_integer(a) * String.to_integer(b)

      _otherwise, acc ->
        acc
    end)
  end

  @doc """
  Similar to `part_1/1`, but this time, there are two operands: `do()` and `don't()`.

  After seeing a `do()` symbol, we should evaluate the expression until we see a `don't()` symbol.
  Likewise, after seeing a `don't()` symbol, we should ignore the expression until we see a `do()` symbol.

  Always start with `do()`.

  ## Examples

      iex> AOC.Days.Day_3.part_2("mul(2,2)!!randomnoise//mul(2,2)")
      8

      iex> AOC.Days.Day_3.part_2("do()mul(2,2)!!randomnoise//mul(2,2)")
      8

      iex> AOC.Days.Day_3.part_2("do()mul(2,2)!!do()randomnoise//mul(2,2)")
      8

      iex> AOC.Days.Day_3.part_2("don't()mul(2,2)!!randomnoise//mul(2,2)")
      0

      iex> AOC.Days.Day_3.part_2("don't()mul(2,2)!!rando()mnoise//mul(2,2)")
      4

  """
  def part_2(input) do
    parser = ~r/(do\(\)|don't\(\))|((mul)\((\d\d?\d?),(\d\d?\d?)\))/

    {_mode, result} =
      parser
      |> Regex.scan(input)
      |> Enum.reduce({:do, 0}, fn
        [_full_match, "do()"], {_mode, acc} ->
          {:do, acc}

        [_full_match, "don't()"], {_mode, acc} ->
          {:dont, acc}

        [_full_match, _op_1, _op_2, "mul", a, b], {:do, acc} ->
          {:do, acc + String.to_integer(a) * String.to_integer(b)}

        _otherwise, acc ->
          acc
      end)

    result
  end
end
