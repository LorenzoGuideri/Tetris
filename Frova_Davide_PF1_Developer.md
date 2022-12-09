Describing the source files, what each of the main top-level functions does, 
how the functions are combined together, and which libraries are used for what purpose. 
this document does not need to describe all functions you defined, 
but should focus on the most important ones from the point of view of implementing 
the overall project’s functionality. Maximum length: 1000 words of text.

LIBRARIES USED:
(require 2htdp/universe) for big-bang
(require 2htdp/image) to manipulate images
(require racket/vector) to use vectors
(require racket/base) 

The file Tetris.rkt contains the whole code for the game. 
All of the images were created with 2htdp/image. Nothing was imported in order to make the program lighter and faster.

The function VECTOR-SET was created from scratch because we were having trouble with the built-in one. It was necessary in order to manipulate the rows of our Grid (SET-GRID-ROW), a feature which we used to add Blocks to our Grid (SET-GRID-BLOCK). 
All of this was necessary in order to move the Blocks (MOVE-BLOCK) when the user pressed the arrows (HANDLE-KEY) and to check if any rows were full (ROW-FULL), in order to delete them. 

We have a set of "retrieve 'x' from Grid" (GET-GRID-'X') functions to access the data more easily, and a set of "update x in World-state" (UPDATE-X) in order to manipulate our world-states more clearly.

To render our grid we first rendered the single block (BLOCK-TO-IMAGE), we then rendered a row (GRID-ROW-TO-IMAGE) by rendering multiple blocks one beside the other and then stacked the rows in order to render the whole grid (GRID-TO-IMAGE). DRAW is our final rendering function that renders three possible scenarios: when the game is paused, when the player lost (game-over) and when the game is running.

ADD-PIECE-TO-WORLD-STATE FUNCTION 
TICK FUNCTION
CHANGE-POSN-Y-IN-WORLD-STATE FUNCTION
BLOCK-FALLS-DOWN FUNCTION
SWAP-BLOCK FUNCTION
CAN-BLOCK-FALL? FUNCTION
AUX IS-BLOCK-EMPTY?
LOSER FUNCTION
AUX IS-BLOCK-NONEMPTY?
IF-GAME-OVER-DONT-SPAWN 
HANDLE-KEY FUNCTION
MOVE-RIGHT FUNCTION
MOVE-LEFT FUNCTION
MOVE-DOWN FUNCTION
ROTATE-FRONT FUNCTION
ROTATE-BACK FUNCTION
HARD-DROP FUNCTION
QUIT? FUNCTION
BIG-BANG
