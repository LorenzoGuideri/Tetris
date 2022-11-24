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
- The user can move the pieces left and right, rotate them (UP Arrow) and drop them down (in a faster way with Down Arrow)
- The user can hard drop the piece with the space bar (Drop the piece instantly)
- The user can pause the game with the escape key
- The user can quit the game with the "q" key
- (MAYBE) The user will see the next piece in the top right corner of the screen
- The user will see the score on the top of the screen

LIBRARIES:
- 2htdp/image to manipulate images
- 2htdp/universe to implement big-bang function

DATA TYPES:
- BACKGROUND → Image

- BLOCK → Structure (make-block n is-falling) where:

     n is a Number between 0 and a 7 where:
        0 is empty
        1 to 7 are colors available for the blocks

     is-falling is a boolean
          - this flag is used to check if the block is falling (like the new spawned blocks that fall from the top)

     posn
          - Posn containing the position of the block in the grid

- PIECE -> Still to be defined
     - A piece is the combination of various blocks to form the well known tetrominoes
     - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece

- GRID → list<list<Blocks>> (lolob)
     - (cons List<Block> List<List<Block>>)

     - The grid is the playing field where the pieces will fall
     - The grid is a list of lists of blocks
     - The main list will be the rows of the grid, each row is a list of blocks

- SCORE → number
     - The score is the number of lines completed by the user (1 line = 100 points)
     - If the user completes more then one line at the same time, 
       the score will be increased by a special factor (All the way up to 4 lines at the same time)

- Worldstate → Structure (make-world-state grid score should-quit should-spawn) where:
     should-quit is a boolean
          - if true, the application will quit
     should-spawn is a boolean
          - if true, a new block is spawned at the top of the grid

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
