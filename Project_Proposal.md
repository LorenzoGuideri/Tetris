;;;;;;;;;;;;;;
;;; TETRIS ;;;
;;;;;;;;;;;;;;


TEAM MEMBERS:
Davide Frova, Lorenzo Guideri, Greta Miglietti, Costanza Rodriguez Gavazzi

FUNCTIONALITY:
- Reproduce the game "Tetris" in its simplest possible form with a different color scheme
- "Tetris is a puzzle video game where players complete lines by moving differently shaped pieces (tetrominoes),
which descend onto the playing field.
The completed lines disappear and grant the player points, and the player can proceed to fill the vacated spaces.
The game ends when the uncleared lines reach the top of the playing field.
The longer the player can delay this outcome, the higher their score will be" (Source: Wikipedia)

USER EXPERIENCE:
- The game is played with the keyboard arrows
- The user can move the pieces:
    - left and right (with arrows)
    - rotate them clockwise (UP Arrow)
    - rotate them counterclockwise 90degrees (Z key)
    - drop them down (in a faster way with Down Arrow)
    - hard drop the piece with the space bar (Drop the piece instantly)
- The user can pause the game with the escape key
- The user can quit the game with the "Q" key
- (MAYBE) The user will see the next piece in the top right corner of the screen
- The user will see the score on the top of the screen

LIBRARIES:
- 2htdp/image to manipulate images
- 2htdp/universe to implement big-bang function
- racket/vector to use vector functions

DATA TYPES:
- BACKGROUND → Image

- BLOCK → Structure (make-block type position is-falling ) where:

     where type is one of:
        - #false
        - color

     position is a Posn containing the position of the block in the grid

     is-falling is a boolean
          - this flag is used to check if the block is falling (like the new spawned blocks that fall from the top)

- PIECE -> Vector<Vector<Block>> vovob [length: 4x4]
     - A piece is the combination of various blocks to form the well known tetrominoes
     - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece
     - The pieces are constants

- GRID → Vector<Vector<Blocks>>  vovob [10 width, 40 height (only 20 visible)]
     - The grid is the playing field where the pieces will fall
     - The grid is a list of lists of blocks

- SCORE → number
     - The score is the number of lines completed by the user (1 line = 100 points)
     - If the user completes more then one line at the same time,
       the score will be increased by a special factor (All the way up to 4 lines at the same time)

- Worldstate → Structure (make-world-state grid score should-quit should-spawn is-paused) where:
     - should-quit is a boolean
          - if true, the application will quit
     - should-spawn is a boolean
          - if true, a new block is spawned at the top of the grid
     - is-paused is a boolean
          - if true, the game pauses and a menu pops up where you can choose to resume or quit

- PAUSE MENU -> Worldstate
      - is paused is true

- MAIN FUNCTIONALITIES
     - spawn-piece
     - move-piece
     - rotate-piece
     - drop-piece
     - check-collision
     - check-completed-lines
          - if a line is completed, the score is increased and the line is removed
          - all the lines above the completed line will drop down n rows (n = number of completed lines)
     - check-game-over
     - update-grid
     - update-score
     - update-world-state
     - draw-grid
     - draw-score
