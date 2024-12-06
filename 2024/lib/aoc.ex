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

  def day_3(input_file \\ "day_3.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = day_3_part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_3_part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  Given some string, try to extract the supported symbols and their arguments,
  and then evaluate the expression.

  Importantly, ignore any non-matching symbols.

  ## Examples

      iex> AOC.day_3_part_1("")
      0

      iex> AOC.day_3_part_1("Junk")
      0

      iex> AOC.day_3_part_1("mul(4*")
      0

      iex> AOC.day_3_part_1("mul(1, 2)")
      0

      iex> AOC.day_3_part_1("mul(2,2)")
      4

      iex> AOC.day_3_part_1("mul(2,2)!!randomnoise//mul(2,2)")
      8

  """
  def day_3_part_1(input) do
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
  Similar to `day_3_part_1/1`, but this time, there are two operands: `do()` and `don't()`.

  After seeing a `do()` symbol, we should evaluate the expression until we see a `don't()` symbol.
  Likewise, after seeing a `don't()` symbol, we should ignore the expression until we see a `do()` symbol.

  Always start with `do()`.

  ## Examples

      iex> AOC.day_3_part_2("mul(2,2)!!randomnoise//mul(2,2)")
      8

      iex> AOC.day_3_part_2("do()mul(2,2)!!randomnoise//mul(2,2)")
      8

      iex> AOC.day_3_part_2("do()mul(2,2)!!do()randomnoise//mul(2,2)")
      8

      iex> AOC.day_3_part_2("don't()mul(2,2)!!randomnoise//mul(2,2)")
      0

      iex> AOC.day_3_part_2("don't()mul(2,2)!!rando()mnoise//mul(2,2)")
      4

  """
  def day_3_part_2(input) do
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

  def day_4(input_file \\ "day_4.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = day_4_part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_4_part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  For a given grid, do a DFS starting at each occurency of the "X" symbol and
  try to find the word "XMAS" after four steps in each direction.

  ## Examples

         iex> AOC.day_4_part_1("--X-X--XMAS--X")
         1

         iex> AOC.day_4_part_1("--SAMX-XMAS--X")
         2

         iex> AOC.day_4_part_1(\"""
         ...> XMAS
         ...> M--A
         ...> A--M
         ...> SAMX
         ...> \""")
         4

         iex> AOC.day_4_part_1(\"""
         ...> ---S
         ...> X-A-
         ...> -M--
         ...> X-A-
         ...> ---S
         ...> \""")
         2

  """
  def day_4_part_1(input) do
    steps = 0..3
    grid = :ets.new(:grid, [:set, read_concurrency: true])
    dirs = [:u, :d, :l, :r, :dl, :dr, :ul, :ur]

    advance = fn
      {x, y}, :u, step -> {x, y - step}
      {x, y}, :d, step -> {x, y + step}
      {x, y}, :l, step -> {x - step, y}
      {x, y}, :r, step -> {x + step, y}
      {x, y}, :dl, step -> {x - step, y + step}
      {x, y}, :dr, step -> {x + step, y + step}
      {x, y}, :ul, step -> {x - step, y - step}
      {x, y}, :ur, step -> {x + step, y - step}
    end

    input
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      for {char, x} <- line |> String.split("") |> Enum.with_index(),
          char != "",
          :ets.insert(grid, {{x, y}, char}),
          char == "X",
          dir <- dirs do
        {{x, y}, dir}
      end
    end)
    |> Task.async_stream(fn {{x, y}, dir} ->
      chars =
        Enum.reduce_while(steps, [], fn step, acc ->
          case :ets.lookup(grid, advance.({x, y}, dir, step)) do
            [{{_new_x, _new_y}, char}] when char in ["X", "M", "A", "S"] ->
              {:cont, [char | acc]}

            _otherwise ->
              {:halt, acc}
          end
        end)

      (chars == ["S", "A", "M", "X"] && 1) || 0
    end)
    |> Enum.filter(&match?({:ok, 1}, &1))
    |> Enum.count()
  end

  @doc """
  For a given grid, look for all occurences of MAS in a cross shape
  per the examples:

  ## Examples

         iex> AOC.day_4_part_2(\"""
         ...> M-S
         ...> -A-
         ...> M-S
         ...> \""")
         1

         iex> AOC.day_4_part_2(\"""
         ...> M-SS-M
         ...> -A--A-
         ...> M-SS-M
         ...> \""")
         2

         iex> AOC.day_4_part_2(\"""
         ...> .M.S......
         ...> ..A..MSMS.
         ...> .M.S.MAA..
         ...> ..A.ASMSM.
         ...> .M.S.M....
         ...> ..........
         ...> S.S.S.S.S.
         ...> .A.A.A.A..
         ...> M.M.M.M.M.
         ...> ..........
         ...> \""")
         9

  """
  def day_4_part_2(input) do
    grid = :ets.new(:grid, [:set, read_concurrency: true])

    advance = fn
      {x, y}, :dl, step -> {x - step, y + step}
      {x, y}, :dr, step -> {x + step, y + step}
      {x, y}, :ul, step -> {x - step, y - step}
      {x, y}, :ur, step -> {x + step, y - step}
    end

    input
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      for {char, x} <- line |> String.split("") |> Enum.with_index(),
          char != "",
          :ets.insert(grid, {{x, y}, char}),
          char == "A" do
        {x, y}
      end
    end)
    |> Task.async_stream(fn {x, y} ->
      try do
        [{_, dl}] = :ets.lookup(grid, advance.({x, y}, :dl, 1))
        [{_, ur}] = :ets.lookup(grid, advance.({x, y}, :ur, 1))

        [{_, dr}] = :ets.lookup(grid, advance.({x, y}, :dr, 1))
        [{_, ul}] = :ets.lookup(grid, advance.({x, y}, :ul, 1))

        true =
          [dl, ur] in [["M", "S"], ["S", "M"]] &&
            [dr, ul] in [["M", "S"], ["S", "M"]]

        1
      rescue
        _e -> 0
      end
    end)
    |> Enum.filter(&match?({:ok, 1}, &1))
    |> Enum.count()
  end

  def day_5(input_file \\ "day_5.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = day_5_part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_5_part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  Given an input, which is split into `ordering_rules` and `inputs`, for each input,
  make sure each `ordering_rule` is satisfied where if an ordering rule is `X|Y`, then
  `X` must come before `Y` in `input`

  Rules where `X` and `Y` are not present in the input are ignored.

  Return the sum of the middle element of each valid input.

  ## Examples

         iex> AOC.day_5_part_1(\"""
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
  def day_5_part_1(input) do
    {{_ordering_rules, validator}, processed_inputs} = day_5_setup(input)

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

         iex> AOC.day_5_part_2(\"""
         ...> 1|2
         ...> 2|3
         ...>
         ...> 3,1,2
         ...> \""")
         2

  """
  def day_5_part_2(input) do
    {{ordering_rules, validator}, processed_inputs} = day_5_setup(input)

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

  defp day_5_setup(input) do
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

  def day_6(input_file \\ "day_6.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = day_6_part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = day_6_part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  @doc """
  Given a map containing several `obstacle`s (denoted by `#`) and a guard (denoted by `^`),
  find every position the guard will move to before they leave the map.

  The guard's AI is very simple, advancing forward in their current direction until they hit
  an obstacle, at which point they will turn 90 degrees to the right and continue.

  ## Examples

         iex> AOC.day_6_part_1(\"""
         ...> #...
         ...> ...#
         ...> ....
         ...> ^...
         ...> \""")
         6

  """
  def day_6_part_1(input) do
    {grid, starting_coord_and_dir, step} = day_6_setup(input)

    tick = fn {{x, y}, dir} ->
      {{next_x, next_y}, turn_dir} = step.({x, y}, dir)

      case :ets.lookup(grid, {next_x, next_y}) do
        [{_, "#"}] -> {[{x, y}], {{x, y}, turn_dir}}
        [{_, _}] -> {[{next_x, next_y}], {{next_x, next_y}, dir}}
        _ -> {:halt, {{x, y}, dir}}
      end
    end

    fn -> starting_coord_and_dir end
    |> Stream.resource(tick, fn _ -> :ok end)
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc """
  Same as part one, but this time, knowing the guard's path, we need to add one new obstacle
  in the guard's path to create a cycle, and count the number of different cycles that can be
  created.

  ## Examples

    iex> AOC.day_6_part_2(\"""
    ...> .#....
    ...> .....#
    ...> ......
    ...> #^....
    ...> ......
    ...> \""")
    1

    iex> AOC.day_6_part_2(\"""
    ...> ....#.....
    ...> .........#
    ...> ..........
    ...> ..#.......
    ...> .......#..
    ...> ..........
    ...> .#..^.....
    ...> ........#.
    ...> #.........
    ...> ......#...
    ...> \""")
    6

  """
  def day_6_part_2(input) do
    {grid, starting_coord_and_dir, step} = day_6_setup(input)
    {{start_x, start_y}, start_dir} = starting_coord_and_dir

    tick = fn {grid, {{x, y}, dir}} ->
      {{next_x, next_y}, turn_dir} = step.({x, y}, dir)

      case :ets.lookup(grid, {next_x, next_y}) do
        [{_, "#"}] -> {[{{x, y}, turn_dir}], {grid, {{x, y}, turn_dir}}}
        [{_, _}] -> {[{{next_x, next_y}, dir}], {grid, {{next_x, next_y}, dir}}}
        _ -> {:halt, {grid, {{x, y}, dir}}}
      end
    end

    fn -> {grid, starting_coord_and_dir} end
    |> Stream.resource(tick, fn _ -> :ok end)
    |> Enum.uniq()
    |> Task.async_stream(fn {{path_x, path_y}, path_dir} ->
      new_grid = :ets.new(:grid, [:set])
      grid |> :ets.tab2list() |> Enum.each(&:ets.insert(new_grid, &1))

      obstacle_coord = case path_dir do
        :u -> {path_x, path_y - 1}
        :r -> {path_x + 1, path_y}
        :d -> {path_x, path_y + 1}
        :l -> {path_x - 1, path_y}
      end

      :ets.insert(new_grid, {obstacle_coord, "#"})

      new_route =
        fn -> {new_grid, starting_coord_and_dir} end
        |> Stream.resource(tick, fn _ -> :ok end)
        |> Enum.reduce_while([{{start_x, start_y}, start_dir}], fn
          {{new_x, new_y}, dir}, acc ->
            if {{new_x, new_y}, dir} in acc do
              {:halt, [:cycle, {{new_x, new_y}, dir} | acc]}
            else
              {:cont, [{{new_x, new_y}, dir} | acc]}
            end
        end)

      if hd(new_route) == :cycle do
        obstacle_coord
      end
    end)
    |> Enum.map(fn {:ok, resp} -> resp end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp day_6_setup(input) do
    grid = :ets.new(:grid, [:set])

    [guard_pos] =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        for {char, x} <- line |> String.split("", trim: true) |> Enum.with_index(),
            :ets.insert(grid, {{x, y}, char}),
            char == "^" do
          {x, y}
        end
      end)

    step = fn
      {x, y}, :u -> {{x, y - 1}, :r}
      {x, y}, :r -> {{x + 1, y}, :d}
      {x, y}, :d -> {{x, y + 1}, :l}
      {x, y}, :l -> {{x - 1, y}, :u}
    end

    {grid, {guard_pos, :u}, step}
  end
end
