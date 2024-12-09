defmodule AOC do
  @moduledoc """
  Documentation for `AOC`.
  """

  @priv_dir "./priv/inputs"

  alias AOC.Days.Day_1
  alias AOC.Days.Day_2
  alias AOC.Days.Day_3
  alias AOC.Days.Day_4
  alias AOC.Days.Day_5
  alias AOC.Days.Day_6
  alias AOC.Days.Day_7
  alias AOC.Days.Day_8

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

    part_1_result = Day_1.part_1(Enum.reverse(list_1), Enum.reverse(list_2))
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_1.part_1(Enum.reverse(list_1), Enum.reverse(list_2))
    IO.puts("Part 2: #{part_2_result}")
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

    part_1_result = Day_2.part_1(reports)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_2.part_2(reports)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_3(input_file \\ "day_3.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_3.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_3.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_4(input_file \\ "day_4.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_4.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_4.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_5(input_file \\ "day_5.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_5.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_5.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_6(input_file \\ "day_6.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_6.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_6.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_7(input_file \\ "day_7.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_7.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_7.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end

  def day_8(input_file \\ "day_8.txt") do
    input =
      @priv_dir
      |> Path.join(input_file)
      |> File.read!()

    part_1_result = Day_8.part_1(input)
    IO.puts("Part 1: #{part_1_result}")

    part_2_result = Day_8.part_2(input)
    IO.puts("Part 2: #{part_2_result}")
  end
end
