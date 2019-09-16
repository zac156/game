defmodule Round do
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

  def generate_enemies(row, col, num \\ @enemy_count) do
    Enum.reduce(1..num, [], fn _, enemies ->
      enemy = generate_enemy(row, col, enemies)
      enemies ++ [enemy]
    end)
  end

  def generate_enemy(row, col, enemies) do
    enemy = {Enum.random(0..(row - 1)), Enum.random(0..(col - 1))}
    validate_enemy(row, col, enemy, enemies)
  end

  def validate_enemy(row, col, enemy, enemies) when enemy == {0, 0} do
    generate_enemy(row, col, enemies)
  end

  def validate_enemy(row, col, enemy, enemies) do
    case Enum.member?(enemies, enemy) do
      true -> generate_enemy(row, col, enemies)
      _ -> enemy
    end
  end

  def build_map(row, col) do
    List.duplicate('0', row) |> List.duplicate(col)
  end

  def place_enemy(map, set_row, set_col, value) do
    get_row = Enum.at(map, set_row)
    new_row = List.replace_at(get_row, set_col, value)
    map = List.replace_at(map, set_row, new_row)
    map
  end

  def place_enemies(map, enemies) do
    Enum.reduce(enemies, map, fn {row, col}, map -> place_enemy(map, row, col, @enemy) end)
  end

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

defmodule Game do
  @rows 3
  @cols 3

  def print_map(%Round{map: map, enemy_count: enemy_count}) do
    IEx.Helpers.clear()

    map |> Enum.map(fn n -> IO.inspect(n) end)
    IO.puts("Enemy count: " <> Integer.to_string(enemy_count))
  end

  def setup do
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

Game.setup()
