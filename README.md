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
- Function to retreive a random piece
- Implemented First version of big-bang function
- Discussion about using matrix or vector of vectors to represent the grid

