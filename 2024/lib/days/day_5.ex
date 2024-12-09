defmodule AOC.Days.Day_5 do
  @doc """
  Given an input, which is split into `ordering_rules` and `inputs`, for each input,
  make sure each `ordering_rule` is satisfied where if an ordering rule is `X|Y`, then
  `X` must come before `Y` in `input`

  Rules where `X` and `Y` are not present in the input are ignored.

  Return the sum of the middle element of each valid input.

  ## Examples

         iex> AOC.Days.Day_5.part_1(\"""
         ...> 1|2
         ...> 2|5
         ...> 0|100
         ...>
         ...> 1,2,3,4,5
         ...> 100,0,101,102,103
         ...> 0,100,101,102,103
         ...> \""")
         104

  """
  def part_1(input) do
    {{_ordering_rules, validator}, processed_inputs} = setup(input)

    processed_inputs
    |> Enum.filter(validator)
    |> Enum.map(fn {_input, input_chars} ->
      middle_idx = div(length(input_chars), 2)
      input_chars |> Enum.at(middle_idx) |> String.to_integer()
    end)
    |> Enum.sum()
  end

  @doc """
  Same as part 1, but this time, we need to sort each incoming input based on the
  ordering rules and return the sum of the middle element of each sorted, incorrect
  input.

  ## Examples

         iex> AOC.Days.Day_5.part_2(\"""
         ...> 1|2
         ...> 2|3
         ...>
         ...> 3,1,2
         ...> \""")
         2

  """
  def part_2(input) do
    {{ordering_rules, validator}, processed_inputs} = setup(input)

    ordering_pairs =
      Enum.map(ordering_rules, fn {{a, b}, _rule} ->
        {String.to_integer(a), String.to_integer(b)}
      end)

    processed_inputs
    |> Enum.reject(validator)
    |> Enum.map(fn {_input, input_chars} ->
      middle_idx = div(length(input_chars), 2)

      input_chars
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort(fn a, b -> {a, b} in ordering_pairs end)
      |> Enum.at(middle_idx)
    end)
    |> Enum.sum()
  end

  defp setup(input) do
    [ordering_rules, inputs] = String.split(input, "\n\n", trim: true)

    ordering_rules =
      ordering_rules
      |> String.split("\n")
      |> Enum.map(&String.split(&1, "|"))
      |> Map.new(fn [a, b] -> {{a, b}, ~r/#{a}.*#{b}/} end)

    processed_inputs =
      inputs
      |> String.split("\n", trim: true)
      |> Enum.map(fn input -> {input, String.split(input, ",")} end)

    validator = fn {input, input_chars} ->
      ordering_rules
      |> Enum.filter(fn {{a, b}, _rule} -> a in input_chars && b in input_chars end)
      |> Enum.all?(fn {{_a, _b}, rule} ->
        Regex.match?(rule, input)
      end)
    end

    {{ordering_rules, validator}, processed_inputs}
  end
end
