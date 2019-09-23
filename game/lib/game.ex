defmodule Game do
  @moduledoc """
  Controls the game loop and interface to the game
  """
  @rows 3
  @cols 3

  def print_map(%Round{map: map, enemy_count: enemy_count}) do
    IEx.Helpers.clear()

    map |> Enum.map(fn n -> IO.inspect(n) end)
    IO.puts("Enemy count: " <> Integer.to_string(enemy_count))
  end

  def start do
    round = Round.start(@rows, @cols)
    print_map(round)
    loop(round)
  end

  def loop(%Round{enemy_count: enemy_count}) when enemy_count == 0 do
    IEx.Helpers.clear()
    IO.puts("You have won")
  end

  def loop(round) do
    direction = get_input()

    # Movement and collision detection
    round =
      case Round.possible_move?(round, direction) do
        true -> round |> Round.move(direction)
        false -> round
      end

    print_map(round)
    loop(round)
  end

  def get_input do
    IO.gets("Move where? ")
    |> String.trim()
    |> String.to_atom()
  end
end
