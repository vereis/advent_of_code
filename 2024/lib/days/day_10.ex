defmodule AOC.Days.Day_10 do
  @doc """
  Given a topological map of hiking trails, where integers are heights on the map,
  find all walkable routes from trailheads (0) to peaks (9) where the gradient is
  never more or less than 1.

  A route has a score, equal to the number of peaks it passes through. More than one
  route can appear on a map.

  Return the sum of the scores of each route.

  ## Examples

         iex> AOC.Days.Day_10.part_1(\"""
         ...> ...0...
         ...> ...1...
         ...> ...2...
         ...> 6543456
         ...> 7.....7
         ...> 8.....8
         ...> 9.....9
         ...> \""")
         2

         iex> AOC.Days.Day_10.part_1(\"""
         ...> ..90..9
         ...> ...1.98
         ...> ...2..7
         ...> 6543456
         ...> 765.987
         ...> 876....
         ...> 987....
         ...> \""")
         4

         iex> AOC.Days.Day_10.part_1(\"""
         ...> 10..9..
         ...> 2...8..
         ...> 3...7..
         ...> 4567654
         ...> ...8..3
         ...> ...9..2
         ...> .....01
         ...> \""")
         3

         iex> AOC.Days.Day_10.part_1(\"""
         ...> 89010123
         ...> 78121874
         ...> 87430965
         ...> 96549874
         ...> 45678903
         ...> 32019012
         ...> 01329801
         ...> 10456732
         ...> \""")
         36

  """
  def part_1(input) do
    {map, trailheads} = build_map!(input)

    trailheads
    |> Task.async_stream(&(map |> navigate_trail(&1) |> Enum.count(fn {_, h} -> h == 9 end)))
    |> Enum.map(fn {:ok, count} -> count end)
    |> Enum.sum()
  end

  @doc """
  Similar to part 1, but this time, calculate the number of possible distinct routes
  starting at any trailhead (0) and ending at any peak (9) on the map.

  Return the sum of possible routes.

  ## Examples

         iex> AOC.Days.Day_10.part_2(\"""
         ...> .....0.
         ...> ..4321.
         ...> ..5..2.
         ...> ..6543.
         ...> ..7..4.
         ...> ..8765.
         ...> ..9....
         ...> \""")
         3

         iex> AOC.Days.Day_10.part_2(\"""
         ...> ..90..9
         ...> ...1.98
         ...> ...2..7
         ...> 6543456
         ...> 765.987
         ...> 876....
         ...> 987....
         ...> \""")
         13

         iex> AOC.Days.Day_10.part_2(\"""
         ...> 012345
         ...> 123456
         ...> 234567
         ...> 345678
         ...> 4.6789
         ...> 56789.
         ...> \""")
         227

         iex> AOC.Days.Day_10.part_2(\"""
         ...> 89010123
         ...> 78121874
         ...> 87430965
         ...> 96549874
         ...> 45678903
         ...> 32019012
         ...> 01329801
         ...> 10456732
         ...> \""")
         81

  """
  def part_2(input) do
    {map, trailheads} = build_map!(input)

    trailheads
    |> Task.async_stream(&(map |> discover_trails(&1) |> Enum.count()))
    |> Enum.map(fn {:ok, count} -> count end)
    |> Enum.sum()
  end

  def navigate_trail(map, current_position, acc \\ %{})

  def navigate_trail(map, {{x, y}, h}, acc) do
    acc = Map.put(acc, {x, y}, h)

    next_positions =
      [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
      |> Enum.filter(fn {x, y} -> not is_map_key(acc, {x, y}) end)
      |> Enum.map(&(map |> :ets.lookup(&1) |> List.first()))
      |> Enum.reject(&is_nil/1)
      |> Enum.filter(fn {_coord, new_h} -> new_h - h == 1 end)

    if next_positions == [] do
      acc
    else
      next_positions
      |> Enum.map(fn {coord, new_h} -> navigate_trail(map, {coord, new_h}, acc) end)
      |> Enum.reduce(%{}, &Map.merge(&1, &2))
    end
  end

  def discover_trails(map, current_position, acc \\ [])

  def discover_trails(map, {{x, y}, h}, acc) do
    next_positions =
      [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
      |> Enum.map(&(map |> :ets.lookup(&1) |> List.first()))
      |> Enum.reject(&is_nil/1)
      |> Enum.filter(fn {_coord, new_h} -> new_h - h == 1 end)

    cond do
      h == 9 ->
        [{{x, y}, h} | acc]

      next_positions == [] ->
        acc

      true ->
        next_positions
        |> Enum.flat_map(fn {coord, new_h} -> discover_trails(map, {coord, new_h}, acc) end)
    end
  end

  def build_map!(input) do
    map = :ets.new(:map, [:set, read_concurrency: true])
    trailheads = :ets.new(:trailheads, [:set, read_concurrency: true])

    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.each(fn {line, y} ->
      line
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.each(fn {char, x} ->
        char = (char != "." && String.to_integer(char)) || nil

        if char == 0 do
          :ets.insert(trailheads, {{x, y}, char})
        end

        if char >= 0 && char <= 9 do
          :ets.insert(map, {{x, y}, char})
        end
      end)
    end)

    {map, :ets.tab2list(trailheads)}
  end
end
