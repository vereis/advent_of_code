defmodule AOC.Days.Day_4 do
  @doc """
  For a given grid, do a DFS starting at each occurency of the "X" symbol and
  try to find the word "XMAS" after four steps in each direction.

  ## Examples

         iex> AOC.Days.Day_4.part_1("--X-X--XMAS--X")
         1

         iex> AOC.Days.Day_4.part_1("--SAMX-XMAS--X")
         2

         iex> AOC.Days.Day_4.part_1(\"""
         ...> XMAS
         ...> M--A
         ...> A--M
         ...> SAMX
         ...> \""")
         4

         iex> AOC.Days.Day_4.part_1(\"""
         ...> ---S
         ...> X-A-
         ...> -M--
         ...> X-A-
         ...> ---S
         ...> \""")
         2

  """
  def part_1(input) do
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

         iex> AOC.Days.Day_4.part_2(\"""
         ...> M-S
         ...> -A-
         ...> M-S
         ...> \""")
         1

         iex> AOC.Days.Day_4.part_2(\"""
         ...> M-SS-M
         ...> -A--A-
         ...> M-SS-M
         ...> \""")
         2

         iex> AOC.Days.Day_4.part_2(\"""
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
  def part_2(input) do
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
end
