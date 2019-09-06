import subprocess
import random
import time


def print_map(m, score, enemy_count):
    subprocess.call('clear')
    for row in m:
        print(row)

    print()
    print("Score: %s" % (score))
    print("Enemies Remaining: %s" % (enemy_count))


def setup():
    row = 3
    col = 3
    char_row = 0
    char_col = 0
    my_map, enemy_count = draw_stage(row, col)

    start = time.time()
    score = 0

    # Remove enemy if placed under player
    if my_map[char_row][char_col] == '@':
        enemy_count -= 1

    # Initial position
    my_map[char_row][char_col] = 'X'
    print_map(my_map, score, enemy_count)

    # Game loop
    while True:
        direction = input("move where? ")
        char_row, char_col, my_map, score, enemy_count = move(
            my_map,
            char_row,
            char_col,
            direction,
            score,
            enemy_count
        )
        print_map(my_map, score, enemy_count)

        # Final game condition to win
        if enemy_count == 0:
            subprocess.call('clear')
            end = time.time()
            print("You win!")
            print("You cleared in %2.2f seconds" % (end - start))


def move(my_map, row, col, direction, score, enemy_count):

    # Max bounds of map for collision detection
    max_row = len(my_map)
    max_col = len(my_map[row])

    # Clear previous position
    my_map[row][col] = '0'

    # Movement
    if direction == 'down':
        row += 1
    elif direction == 'up':
        row -= 1
    elif direction == 'left':
        col -= 1
    elif direction == 'right':
        col += 1

    # Collision detection
    if row <= 0:
        row = 0
    if row >= max_row:
        row = 2
    if col <= 0:
        col = 0
    if col >= max_col:
        col = 2

    # Collision with enemy
    if my_map[row][col] == '@':
        score += 1
        enemy_count -= 1

    # Place new position
    my_map[row][col] = 'X'

    return row, col, my_map, score, enemy_count


def draw_stage(row, col):
    enemy_count = 0
    my_list = []
    for i in range(row):
        inner = ['0' if random.randint(1, 2) == 1 else '@' for i in range(col)]
        enemy_count += inner.count('@')
        my_list.append(inner)

    return my_list, enemy_count


setup()
