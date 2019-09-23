defmodule RoundTest do
  use ExUnit.Case
  doctest Round

  test "build the map" do
    assert Round.build_map(3, 3) == [['0', '0', '0'], ['0', '0', '0'], ['0', '0', '0']]
  end

  test "place character on the map" do
    round = Round.start(3, 3)
    %Round{map: map} = round
    character = Enum.at(map, 0) |> Enum.at(0)
    assert %Round{char_col: 0, char_row: 0} = round
    assert character == 'X'
  end

  test "placing a random character" do
    round = Round.start(3, 3)
    round = round |> Round.place_at(2, 2, 'Q')
    %Round{map: map} = round
    placement = Enum.at(map, 2) |> Enum.at(2)
    assert placement == 'Q'
  end

  test "move character down" do
    round = Round.start(3, 3)
    round = round |> Round.move(:down)
    %Round{map: map} = round
    character = Enum.at(map, 1) |> Enum.at(0)
    assert %Round{char_col: 0, char_row: 1} = round
    assert character == 'X'
  end

  test "can move within bounds of map" do
    round = Round.start(3, 3)

    possible_move? = round |> Round.move(:down) |> Round.possible_move?(:down)

    assert possible_move? == true
  end

  test "can't move outside of bounds of map" do
    round = Round.start(3, 3)

    possible_move? =
      round |> Round.move(:down) |> Round.move(:down) |> Round.possible_move?(:down)

    assert possible_move? == false
  end

  test "generate enemies" do
    enemies = Round.generate_enemies(3, 3, 5)

    assert enemies |> Enum.uniq() |> Enum.count() == 5
  end
end
