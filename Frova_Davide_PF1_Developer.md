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

HANDLE-KEY


ROTATE

MOVE

ANY-FULL-ROWS

LOSER



