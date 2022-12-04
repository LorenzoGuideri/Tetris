;;;;;;;;;;;;;;
;;; TETRIS ;;;
;;;;;;;;;;;;;;


TEAM MEMBERS:
Davide Frova, Lorenzo Guideri, Greta Miglietti, Costanza Rodriguez Gavazzi

MILESTONE 1
-----------------------------
- Data definitions
- Constat definitions
- Added grid to WorldState
- Added score to WorldState
- Created vector manipulation functions, more specifically:
    - set-grid-block : Sets a block in grid to a given block
    - grid-block : Gets a block from grid
    - set-grid-row : Sets a row in grid to a given row
    - add-piece-to-grid : Adds a piece to a grid in the middle top part
    - grid-row : Gets a row from grid
    - grid-column : Gets a column from grid
- Functions to render blocks and grid
    - block-to-image : Renders a block to an image
    - grid-row-image : Renders a row of a grid to an image
    - grid-to-image : Renders a grid to an image
- Defined pieces as predefined constants of Vector<Vector<Block>>
    - I, J, L, O, S, T, Z
    - Pieces made up with predefined NonFalling and Falling Blocks
- random-piece: Function to retreive a random piece
- Implemented First version of big-bang function
- Discussion about using matrix or vector of vectors to represent the grid

MILESTONE 2
-----------------------------
NEW FUNCTIONS:
     - SCORE-TO-IMAGE FUNCTION
       takes a Score and turns it into an Image
     - DRAW FUNCTION
       takes a WorldState and renders the background and the grid
     - TICK FUNCTION
       takes a World-state and moves a Piece down every second
     - AUXILIARY FUNCTIONS TO UPDATE WORLD-STATE DATA
        all take a world-state and a value and insert the new value in the world-state
        - should-quit
        - should-spawn
        - is-paused
        - falling-blocks
      - CAN-BLOCK-FALL? FUNCTION
        takes a World-state, x and y coordinates and returns true if the Block (add1 y) at the coordinates x y in the Grid can fall
        - AUXILIARY FUNCTION: IS-BLOCK-EMPTY?
