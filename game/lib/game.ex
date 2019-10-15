defmodule Game do
  @moduledoc """
  Controls the game loop and interface to the game
  """
  @rows 3
  @cols 3

  def draw(%Round{map: map, enemy_count: enemy_count}) do
    map
    |> Enum.with_index()
    |> Enum.each(fn {row, n} ->
      ExNcurses.mvprintw(n, 0, "#{inspect(row)}")
    end)

    ExNcurses.mvprintw(@cols + 1, 0, "Enemy count: " <> Integer.to_string(enemy_count))
    ExNcurses.refresh()
  end

  def start do
    ExNcurses.n_begin()

    ExNcurses.listen()
    ExNcurses.noecho()
    ExNcurses.keypad()
    ExNcurses.curs_set(0)

    round = Round.start(@rows, @cols)
    loop(round)
  end

  def loop(%Round{enemy_count: enemy_count}) when enemy_count == 0 do
    ExNcurses.clear()
    ExNcurses.mvprintw(0, 0, "You have won!")
    ExNcurses.refresh()

    # Continue playing
    # round = Round.start(@rows, @cols)
    # loop(round)
  end

  def loop(round) do
    draw(round)

    char = ExNcurses.getch()
    ExNcurses.mvprintw(10, 0, "You entered '#{char}'  ")

    if char == 113, do: ExNcurses.endwin()

    direction =
      case char do
        259 -> :up
        258 -> :down
        260 -> :left
        261 -> :right
      end

    # Movement and collision detection
    round =
      case Round.possible_move?(round, direction) do
        true -> round |> Round.move(direction)
        false -> round
      end

    ExNcurses.refresh()
    loop(round)
  end

  def get_input do
    IO.gets("Move where? ")
    |> String.trim()
    |> String.to_atom()
  end
end
