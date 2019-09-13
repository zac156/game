
defmodule Round do

    defstruct [
        :map, :char_row, :char_col
    ]

    def build_map(row, col) do
        List.duplicate('0', row)
        |> List.duplicate(col)
    end

    def start(rows, cols) do
        char_row = 0
        char_col = 0
        round = %Round{
          map: build_map(rows, cols),
          char_row: char_row,
          char_col: char_col
        }
        round = place_at(round, char_row, char_col, '@')
        round
    end

    def move(%Round{char_row: char_row, char_col: char_col} = round, :down) do
        round
        |> place_at(char_row, char_col, '0')
        |> place_at(char_row + 1, char_col, '@')
    end

    def move(%Round{char_row: char_row, char_col: char_col} = round, :up) do
        round
        |> place_at(char_row, char_col, '0')
        |> place_at(char_row - 1, char_col, '@')
    end

    def move(%Round{char_row: char_row, char_col: char_col} = round, :left) do
        round
        |> place_at(char_row, char_col, '0')
        |> place_at(char_row, char_col - 1, '@')
    end

    def move(%Round{char_row: char_row, char_col: char_col} = round, :right) do
        round
        |> place_at(char_row, char_col, '0')
        |> place_at(char_row, char_col + 1, '@')
    end

    def place_at(%Round{map: map} = round, set_row, set_col, value) do
        get_row = Enum.at(map, set_row)
        new_row = List.replace_at(get_row, set_col, value)
        map = List.replace_at(map, set_row, new_row)

        %Round{round | map: map, char_row: set_row, char_col: set_col}
    end
end


defmodule Game do
    @row 3
    @col 3

    def print_map(%Round{map: map} = _round) do
        map |> Enum.map(fn n -> IO.inspect(n) end)
    end

    def setup do
        round = Round.start(@row, @col)
        print_map(round)
        loop(round)
    end

    def loop(round) do
        direction = get_input()

        round = round |> Round.move(direction)

        print_map(round)

        loop(round)
    end

    def get_input do
        IO.gets("Move where? ")
        |> String.trim
        |> String.to_atom
    end

end

Game.setup()


