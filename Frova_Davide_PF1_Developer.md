Describing the source files, what each of the main top-level functions does, 
how the functions are combined together, and which libraries are used for what purpose. 
this document does not need to describe all functions you defined, 
but should focus on the most important ones from the point of view of implementing 
the overall project’s functionality. Maximum length: 1000 words of text.

LIBRARIES USED:
(require 2htdp/universe) for big-bang
(require 2htdp/image) to manipulate images
(require racket/vector) to use vectors advanced functions
(require racket/base) 

The file Tetris.rkt contains the whole code for the game. 
All of the images were created with 2htdp/image. Nothing was imported in order to make the program lighter and faster.

We have a set of "retrieve 'x' from Grid" (GET-GRID-'X') functions to access the data more easily, and a set of "update x in World-state" (UPDATE-X) in order to manipulate our world-states more clearly.

To render our grid we first rendered the single block (BLOCK-TO-IMAGE), we then rendered a row (GRID-ROW-IMAGE) by rendering multiple blocks one beside the other and then stacked the rows in order to render the whole grid (GRID-TO-IMAGE). DRAW is our final rendering function that renders four possible scenarios: the welcome page, when the game is paused, when the player lost (game-over) and when the game is running.

The main functionalities of the game are the following:
The pieces move down every x time, this is handled by tick-function.
The pieces can be moved and rotated when the player presses some keys, this is handled by handle-key.
Rotation and movements are handled by rotate and move.
When a row is complete, it disappears and all row above it are pushed down (handled by any-full-rows).
When the ceiling of the grid is reached by pieces, the player lost (loser function).

TICK-FUNCTION this function is divided in 2 main parts: 
 - when a piece is spawned: a piece is placed in the top part of
 the grid and it starts moving down every tick
  functions called: spawn-piece

 - when a piece is moved: the program checks if the new positions are available, then all the blocks that are falling are removed from the grid, then the falling-blocks posns are updated with the offset of the movement required, finally the blocks are added to the grid based on the updated positsion.
  function called: is-new-destination-in-grid?, move-blocks-offset 
    ( 
      - remove-blocks-in-posn
      - update-posns-in-falling-blocks
      - add-blocks-to-falling-blocks-posns
    )

HANDLE-KEY this function handles all the key presses that can happen during the game
the keys that can be pressed are:
- left arrow: move the piece to the left
- right arrow: move the piece to the right
- up arrow: rotate the piece
- down arrow: move the piece down faster (this function increments the score by 1 each tick, the tick-delay is set to 1)
- space: start the game
- escape: pause the game
- r: restart the game while it is paused or after the game is over
- q: quit the game

This function uses the move and rotate functions to handle the movements and rotations of the pieces, update- functions to update the world-state values

ROTATE-CW This function handles the rotation of the piece that is falling
The function checks if the new position of the blocks is available, if it is, the blocks are removed from the grid, the blocks posns are rotated and then added to the grid in the new position 

MOVE
This function handles the movement of the piece that is falling
It checks if the new position of the blocks is available, if it is, the blocks are removed from the grid, the blocks posns are updated with the offset of the movement required and then added to the grid in the new position

ANY-FULL-ROWS
This function checks if there are any full rows in the grid, if there are, the function removes each full row and pushes down all the rows above it
It keeps truck of the number of rows removed and uses it to update the score with a special factor

LOSER
This function checks if the ceiling of the grid is reached by the falling blocks, if it is, the game is over and the player lost
Then the game over page is rendered with the score and the keys to restart or quit the game.

The main constants are the following:
- grid-width: the width of the grid in blocks
- grid-height: the height of the grid in blocks
- PIECES : a vector of all the pieces that can be spawned
- PIECES-POSITIONS : a vector of all the initial positions of the pieces
- INITIAL-STATE : the initial state of the world-state