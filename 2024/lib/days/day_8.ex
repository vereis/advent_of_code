defmodule AOC.Days.Day_8 do
  @doc """
  Given a map of antennas with a frequency (a character that isn't `.` or `#`), find the number of
  antinodes that can be created by the antennas.

  Antinodes are created by two antennas that are in the same frequency and have the same distance
  to a third point. The antinode is the point that is the same distance from the two antennas.

  ## Examples

         iex> AOC.Days.Day_8.part_1(\"""
         ...> ..........
         ...> ...#......
         ...> ..........
         ...> ....a.....
         ...> ..........
         ...> ..........
         ...> ..........
         ...> ......#...
         ...> ..........
         ...> ..........
         ...> \""")
         0

         iex> AOC.Days.Day_8.part_1(\"""
         ...> ..........
         ...> ...#......
         ...> ..........
         ...> ....a.....
         ...> ..........
         ...> .....a....
         ...> ..........
         ...> ......#...
         ...> ..........
         ...> ..........
         ...> \""")
         2

         iex> AOC.Days.Day_8.part_1(\"""
         ...> ..........
         ...> ...#......
         ...> #.........
         ...> ....a.....
         ...> ........a.
         ...> .....a....
         ...> ..#.......
         ...> ......#...
         ...> ..........
         ...> ..........
         ...> \""")
         4

         iex> AOC.Days.Day_8.part_1(\"""
         ...> ......#....#
         ...> ...#....0...
         ...> ....#0....#.
         ...> ..#....0....
         ...> ....0....#..
         ...> .#....A.....
         ...> ...#........
         ...> #......#....
         ...> ........A...
         ...> .........A..
         ...> ..........#.
         ...> ..........#.
         ...> \""")
         14

  """
  def part_1(input) do
    {frequencies, {min_x, min_y, max_x, max_y}, _antennas, antinodes} = build_map!(input)

    for {char, coords} <- frequencies,
        {x_1, y_1} <- coords,
        {x_2, y_2} <- coords,
        {x_1, y_1} != {x_2, y_2} do
      delta_x = x_1 - x_2
      delta_y = y_1 - y_2
      antinode_x = x_1 + delta_x
      antinode_y = y_1 + delta_y

      if antinode_x >= min_x && antinode_x <= max_x && antinode_y >= min_y && antinode_y <= max_y do
        :ets.insert(antinodes, {{antinode_x, antinode_y}, char})
      end
    end

    antinodes |> :ets.tab2list() |> Enum.count()
  end

  @doc """
  Same as part 1, but antinodes now propagate forever until they go out of bounds. They also create
  antinodes under every antenna (as long as is more than one for that frequency).


  ## Examples

         iex> AOC.Days.Day_8.part_2(\"""
         ...> T....#....
         ...> ...T......
         ...> .T....#...
         ...> .........#
         ...> ..#.......
         ...> ..........
         ...> ...#......
         ...> ..........
         ...> ....#.....
         ...> ..........
         ...> \""")
         9

         iex> AOC.Days.Day_8.part_2(\"""
         ...> ##....#....#
         ...> .#.#....0...
         ...> ..#.#0....#.
         ...> ..##...0....
         ...> ....0....#..
         ...> .#...#A....#
         ...> ...#..#.....
         ...> #....#.#....
         ...> ..#.....A...
         ...> ....#....A..
         ...> .#........#.
         ...> ...#......##
         ...> \""")
         34

  """
  def part_2(input) do
    {frequencies, {min_x, min_y, max_x, max_y}, _antennas, antinodes} = build_map!(input)

    for {char, coords} <- frequencies,
        {x_1, y_1} <- coords,
        {x_2, y_2} <- coords,
        {x_1, y_1} != {x_2, y_2} do
      delta_x = x_1 - x_2
      delta_y = y_1 - y_2

      Enum.reduce_while(0..999, {x_1 - delta_x, y_1 - delta_y}, fn _i, {x_3, y_3} ->
        antinode_x = x_3 + delta_x
        antinode_y = y_3 + delta_y

        if antinode_x >= min_x && antinode_x <= max_x && antinode_y >= min_y &&
             antinode_y <= max_y do
          :ets.insert(antinodes, {{antinode_x, antinode_y}, char})
          {:cont, {antinode_x, antinode_y}}
        else
          {:halt, :ok}
        end
      end)
    end

    antinodes |> :ets.tab2list() |> Enum.count()
  end

  def build_map!(input) do
    frequency_regex = ~r/([A-Z]|[a-z]|[0-9])/
    antennas = :ets.new(:antennas, [:set, read_concurrency: true])
    antinodes = :ets.new(:antinodes, [:set, read_concurrency: true])

    {max_x, max_y} =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        max_x =
          line
          |> String.split("", trim: true)
          |> Enum.with_index()
          |> Enum.map(fn {char, x} ->
            if Regex.match?(frequency_regex, char) do
              :ets.insert(antennas, {{x, y}, char})
            end

            x
          end)
          |> Enum.max()

        {max_x, y}
      end)
      |> Enum.max_by(fn {_x, y} -> y end)

    entries = :ets.tab2list(antennas)

    {Enum.group_by(entries, fn {_coords, char} -> char end, fn {coords, _char} -> coords end),
     {0, 0, max_x, max_y}, antennas, antinodes}
  end
end
