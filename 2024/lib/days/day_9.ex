defmodule AOC.Days.Day_9 do
  @doc """
  Parse the input which represents a compressed block format. Naively defrag each block one at a time,
  and calculate the checksum.

  ## Examples

         iex> AOC.Days.Day_9.part_1("2333133121414131402")
         1928

  """
  def part_1(input) do
    input
    |> to_blocks()
    |> defrag_blocks()
    |> checksum()
  end

  @doc """
  Parse the input which represents a compressed block format. Defrag entire files at a time,
  and calculate the checksum.

  Note that if a block cannot be moved to a free space, it will be left in its original position.

  ## Examples

         iex> AOC.Days.Day_9.part_2("2333133121414131402")
         2858

  """
  def part_2(input) do
    input
    |> to_blocks()
    |> defrag_files()
    |> checksum()
  end

  @doc """
  Converts a compressed block format into a list of blocks where an integer denotes a used block and its ID,
  whereas `nil` denotes a free space.

  ## Examples

         iex> AOC.Days.Day_9.to_blocks("12345")
         [0, nil, nil, 1, 1, 1, nil, nil, nil, nil, 2, 2, 2, 2, 2]

  """
  def to_blocks(input) do
    id = :counters.new(1, [])

    input
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn
      [blocks, free_space] ->
        :counters.add(id, 1, 1)
        List.duplicate(:counters.get(id, 1) - 1, blocks) ++ List.duplicate(nil, free_space)

      [blocks] ->
        :counters.add(id, 1, 1)
        List.duplicate(:counters.get(id, 1) - 1, blocks)
    end)
  end

  @doc """
  Given a list of blocks, defragments the list one block at a time, allocating each free space (from left-to-right)
  with the rightmost block ID.

  ## Examples

         iex> "12345" |> AOC.Days.Day_9.to_blocks() |> AOC.Days.Day_9.defrag_blocks()
         [0, 2, 2, 1, 1, 1, 2, 2, 2]

         iex> "2333133121414131402" |> AOC.Days.Day_9.to_blocks() |> AOC.Days.Day_9.defrag_blocks()
         [0, 0, 9, 9, 8, 1, 1, 1, 8, 8, 8, 2, 7, 7, 7, 3, 3, 3, 6, 4, 4, 6, 5, 5, 5, 5, 6, 6]

  """
  def defrag_blocks(blocks) do
    defrag_blocks(blocks, Enum.reverse(blocks), [])
  end

  def defrag_blocks(blocks, reversed_blocks, acc)
      when [] in [blocks, reversed_blocks] or length(acc) >= length(reversed_blocks) do
    Enum.reverse(acc)
  end

  def defrag_blocks([block | blocks], reversed_blocks, acc) when block >= 0 and block <= 9999 do
    defrag_blocks(blocks, reversed_blocks, [block | acc])
  end

  def defrag_blocks([nil | _rest] = blocks, [nil | reversed_blocks], acc) do
    defrag_blocks(blocks, reversed_blocks, acc)
  end

  def defrag_blocks([nil | blocks], [char | reversed_blocks], acc)
      when char >= 0 and char <= 9999 do
    defrag_blocks(blocks, reversed_blocks, [char | acc])
  end

  @doc """
  Like `defrag_blocks/1` but with the added complexity of defragmenting entire files, not breaking them up
  into blocks.

  ## Examples

         iex> "2333133121414131402" |> AOC.Days.Day_9.to_blocks() |> AOC.Days.Day_9.defrag_files()
         [0, 0, 9, 9, 2, 1, 1, 1, 7, 7, 7, nil, 4, 4, nil,3, 3, 3, nil, nil, nil, nil, 5, 5, 5,
          5, nil, 6, 6, 6, 6, nil, nil, nil, nil, nil, 8, 8, 8, 8, nil, nil]

  """
  def defrag_files(blocks) do
    {remaining_blocks, block_map} =
      Enum.reduce(blocks, {[], []}, fn
        nil, {[nil | _rest] = block_acc, total_acc} ->
          {[nil | block_acc], total_acc}

        char, {[char | _rest] = block_acc, total_acc} ->
          {[char | block_acc], total_acc}

        block, {[], total_acc} ->
          {[block], total_acc}

        block, {block_acc, total_acc} ->
          {[block], [block_acc | total_acc]}
      end)

    block_map =
      [remaining_blocks]
      |> Enum.concat(block_map)
      |> Enum.reverse()
      |> Enum.with_index()

    empty_blocks =
      block_map
      |> Enum.filter(fn {[block | _rest], _index} -> is_nil(block) end)
      |> Enum.map(fn {block, index} -> {length(block), index} end)

    patches = file_block_patches(Enum.reverse(block_map), empty_blocks, [])

    block_map
    |> Enum.map(fn {blocks, idx} ->
      cond do
        is_map_key(patches, idx) && patches[idx] == nil ->
          Enum.map(blocks, fn _ -> nil end)

        is_map_key(patches, idx) ->
          patches[idx]

        true ->
          blocks
      end
    end)
    |> List.flatten()
  end

  def file_block_patches(block_map, empty_blocks, acc)
      when block_map == [] do
    updates =
      acc
      |> Enum.group_by(
        fn {_block, _initial_block_idx, new_block_idx} -> new_block_idx end,
        fn {block, _initial_block_idx, _new_block_idx} -> block end
      )
      |> Map.new(fn {idx, blocks} ->
        {remaining_empty_blocks, ^idx} =
          Enum.find(empty_blocks, fn {_, idx_2} -> idx == idx_2 end)

        {idx, Enum.concat(Enum.reverse(blocks)) ++ List.duplicate(nil, remaining_empty_blocks)}
      end)

    acc
    |> Map.new(fn {_block, initial_block_idx, _new_block_idx} -> {initial_block_idx, nil} end)
    |> Map.merge(updates)
  end

  def file_block_patches([{block, _idx} | block_map], empty_blocks, acc)
      when is_nil(hd(block)) do
    file_block_patches(block_map, empty_blocks, acc)
  end

  def file_block_patches([{block, idx} | block_map], empty_blocks, acc)
      when hd(block) >= 0 and hd(block) <= 9999 do
    block_length = length(block)

    usable_empty_block =
      Enum.find(empty_blocks, fn {empty_block_length, _index} ->
        block_length <= empty_block_length
      end)

    case usable_empty_block do
      nil ->
        file_block_patches(block_map, empty_blocks, acc)

      {_empty_block_length, empty_block_idx} ->
        empty_blocks =
          Enum.map(empty_blocks, fn
            {empty_block_length, ^empty_block_idx} ->
              {empty_block_length - block_length, empty_block_idx}

            {block_length, idx} ->
              {block_length, idx}
          end)

        file_block_patches(block_map, empty_blocks, [{block, idx, empty_block_idx} | acc])
    end
  end

  @doc """
  Generates a checksum by multipliying all block IDs in the given list of blocks with their
  relative index in the blocklist.

  Ignores empty blocks.

  ## Examples

         iex> "2333133121414131402" |> AOC.Days.Day_9.to_blocks() |> AOC.Days.Day_9.defrag_blocks() |> AOC.Days.Day_9.checksum()
         1928

  """
  def checksum(blocks) do
    blocks
    |> Enum.with_index()
    |> Enum.reject(fn {block_id, _index} -> is_nil(block_id) end)
    |> Enum.map(fn {block_id, index} -> block_id * index end)
    |> Enum.sum()
  end
end
