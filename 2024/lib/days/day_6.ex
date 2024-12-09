defmodule AOC.Days.Day_6 do
  @doc """
  Given a map containing several `obstacle`s (denoted by `#`) and a guard (denoted by `^`),
  find every position the guard will move to before they leave the map.

  The guard's AI is very simple, advancing forward in their current direction until they hit
  an obstacle, at which point they will turn 90 degrees to the right and continue.

  ## Examples

         iex> AOC.Days.Day_6.part_1(\"""
         ...> #...
         ...> ...#
         ...> ....
         ...> ^...
         ...> \""")
         6

  """
  def part_1(input) do
    {grid, starting_coord_and_dir, step} = setup(input)

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

    iex> AOC.Days.Day_6.part_2(\"""
    ...> .#....
    ...> .....#
    ...> ......
    ...> #^....
    ...> ......
    ...> \""")
    1

    iex> AOC.Days.Day_6.part_2(\"""
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
  def part_2(input) do
    {grid, starting_coord_and_dir, step} = setup(input)
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

      obstacle_coord =
        case path_dir do
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

  defp setup(input) do
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
