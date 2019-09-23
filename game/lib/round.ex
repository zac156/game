defmodule Round do
  @moduledoc """
  Responsible for the state of the game and functions which transform that state
  """
  @character 'X'
  @enemy '@'
  @enemy_count 5

  defstruct [
    :map,
    :char_row,
    :char_col,
    :max_row,
    :max_col,
    :enemy_count,
    :enemies
  ]

  @type enemy :: {integer, integer}
  @type enemies :: [{integer, integer}]
  @type game_map :: [list]
  @type round_state :: %Round{
          map: game_map,
          enemies: enemies,
          enemy_count: integer,
          char_row: integer,
          char_col: integer,
          max_row: integer,
          max_col: integer
        }

  @spec generate_enemies(integer, integer, integer) :: list
  def generate_enemies(row, col, num \\ @enemy_count) do
    Enum.reduce(1..num, [], fn _, enemies ->
      enemy = generate_enemy(row, col, enemies)
      enemies ++ [enemy]
    end)
  end

  @spec generate_enemies(integer, integer, list) :: enemy
  def generate_enemy(row, col, enemies) do
    enemy = {Enum.random(0..(row - 1)), Enum.random(0..(col - 1))}
    validate_enemy(row, col, enemy, enemies)
  end

  @spec validate_enemy(integer, integer, enemy, list) :: enemy
  def validate_enemy(row, col, enemy, enemies) when enemy == {0, 0} do
    generate_enemy(row, col, enemies)
  end

  def validate_enemy(row, col, enemy, enemies) do
    case Enum.member?(enemies, enemy) do
      true -> generate_enemy(row, col, enemies)
      _ -> enemy
    end
  end

  @spec build_map(integer, integer) :: game_map
  def build_map(row, col) do
    List.duplicate('0', row) |> List.duplicate(col)
  end

  @spec place_enemy(game_map, integer, integer, String.t()) :: game_map
  def place_enemy(map, set_row, set_col, value) do
    get_row = Enum.at(map, set_row)
    new_row = List.replace_at(get_row, set_col, value)
    map = List.replace_at(map, set_row, new_row)
    map
  end

  @spec place_enemies(game_map, enemies) :: game_map
  def place_enemies(map, enemies) do
    Enum.reduce(enemies, map, fn {row, col}, map -> place_enemy(map, row, col, @enemy) end)
  end

  @spec start(integer, integer) :: %Round{}
  def start(rows, cols) do
    char_row = 0
    char_col = 0
    enemies = generate_enemies(rows, cols)

    round = %Round{
      map: build_map(rows, cols) |> place_enemies(enemies),
      enemies: enemies,
      enemy_count: enemies |> Enum.count(),
      char_row: char_row,
      char_col: char_col,
      max_row: rows,
      max_col: cols
    }

    round
    |> place_at(char_row, char_col, @character)
  end

  def possible_move?(
        %Round{char_row: char_row, char_col: char_col, max_row: max_row, max_col: max_col},
        direction
      ) do
    # collision detection
    case direction do
      :down -> char_row + 1 < max_row
      :up -> char_row - 1 >= 0
      :left -> char_col - 1 >= 0
      :right -> char_col + 1 < max_col
      _ -> false
    end
  end

  def maybe_eat_enemy(
        %Round{map: map, char_row: char_row, char_col: char_col, enemy_count: enemy_count} =
          round,
        direction
      ) do
    enemy? =
      case direction do
        :up -> map |> Enum.at(char_row - 1) |> Enum.at(char_col)
        :down -> map |> Enum.at(char_row + 1) |> Enum.at(char_col)
        :left -> map |> Enum.at(char_row) |> Enum.at(char_col - 1)
        :right -> map |> Enum.at(char_row) |> Enum.at(char_col + 1)
      end

    enemy_count =
      case enemy? do
        @enemy -> enemy_count - 1
        _ -> enemy_count
      end

    %Round{round | enemy_count: enemy_count}
  end

  def move(%Round{char_row: char_row, char_col: char_col} = round, :up) do
    round
    |> maybe_eat_enemy(:up)
    |> place_at(char_row, char_col, '0')
    |> place_at(char_row - 1, char_col, @character)
  end

  def move(%Round{char_row: char_row, char_col: char_col} = round, :down) do
    round
    |> maybe_eat_enemy(:down)
    |> place_at(char_row, char_col, '0')
    |> place_at(char_row + 1, char_col, @character)
  end

  def move(%Round{char_row: char_row, char_col: char_col} = round, :left) do
    round
    |> maybe_eat_enemy(:left)
    |> place_at(char_row, char_col, '0')
    |> place_at(char_row, char_col - 1, @character)
  end

  def move(%Round{char_row: char_row, char_col: char_col} = round, :right) do
    round
    |> maybe_eat_enemy(:right)
    |> place_at(char_row, char_col, '0')
    |> place_at(char_row, char_col + 1, @character)
  end

  def place_at(%Round{map: map} = round, set_row, set_col, value) do
    get_row = Enum.at(map, set_row)
    new_row = List.replace_at(get_row, set_col, value)
    map = List.replace_at(map, set_row, new_row)

    %Round{round | map: map, char_row: set_row, char_col: set_col}
  end
end
