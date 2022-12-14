#lang htdp/asl

(require 2htdp/universe)
(require 2htdp/image)
(require racket/vector)
(require racket/base)


#|

(///////////////////**/*********,***,,,,,,,,,,,,,,,,,,,,,..................
(...............................................................................
(..,                                                                         ,..
(,,,  *//////////*.(##########.&%%%%%%%%%%#,((((((((((*  ((((/  *////////.   ,,,
(,,,  *//////////*.(%%%#######.&&&&&&&&&&&#,(((#(#(###(/ (###/.*///////*  *, ,,,
(,,,      ////*   .#%%%(.....     /&&&%,   ,####./####(. (###/ /////*        ,,,
(,,,      ////*   .#%%%%%%%(      /####,   ,***/((###/   (###/   *////*      ,,,
(,,,..... ////*....//**#((,......./####,...,****. /****,.(***/ ....*////,....,,,
(,,,......////*....////(........../####,...*****,../***/.(***/......*////*...,,,
(**,......////*....(///////////(../####,...****/,..../*/.(////.*/////////,...,**
(**,......////*......(####(((((//,/%%%%,...*##((,.....*/.#((//.///////*,.....,**
(**,.........................................................................***
(***************************,.......................,***************************
                         ***,.......................,**,
                         ***,.......................,**,
                         ***,,,,,,,,,,,,,,,,,,,,,,,,,**,
                         *//,,,,,,,,,,,,,,,,,,,,,,,,,//,
                         *//,,,,,,,,,,,,,,,,,,,,,,,,,//,
                         *//,,,,,,,,,,,,,,,,,,,,,,,,,//,
                         *//,,,,,,,,,,,,,,,,,,,,,,,,,//,
                         *//,,,,,,,,,,,,,,,,,,,,,,,,,//,
                         *//*,,,,,,,,,,,,,,,,,,,,,,,,//,
                         */////////////////////////////,




TETRIS GAME IN RACKET LANGUAGE

DEVELOPED BY:

- Davide Frova
- Costanza Rodriguez Gavazzi
- Greta Miglietti
- Lorenzo Guideri

DURING THE 1'ST SEMESTER OF THE
BACHELOR OF SCIENCE IN INFORMATICS
AT USI (Universita' della Svizzera Italiana), CH
Course: Programming Fundamentals 1


|#

;; --------------------------------------------------------------------------

;; CONSTANTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; COLORS

(define EMPTY-COLOR (make-color 30 30 30))
(define YELLOW (make-color 242 240 184))
(define ORANGE (make-color 253 207 179))
(define RED (make-color 244 113 116))
(define PINK (make-color 246 207 250))
(define LILAC (make-color 176 189 245))
(define BLUE (make-color 196 237 245))
(define GREEN (make-color 200 224 152))
(define GREY (make-color 200 200 200))
(define SCORE-COLOR (make-color 249 140 182))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BACKGROUND IMAGE

(define WIDTH-BG 560)
(define HEIGHT-BG 800)
(define BACKGROUND (rectangle WIDTH-BG HEIGHT-BG "solid" EMPTY-COLOR))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; NUMBER OF BLOCKS IN GRID

(define BLOCKS-IN-WIDTH 10)
(define BLOCKS-IN-HEIGHT 24)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GAME-OVER-PAGE IMAGE

(define GAME-OVER-PAGE
  (overlay/align/offset
   "middle" "middle" (text/font "press 'r' to restart" 30 ORANGE #f 'swiss 'normal 'bold #f)
   +15 -50
   (overlay/align/offset
    "middle" "middle" (text/font "press 'q' to quit" 30 YELLOW #f 'swiss 'normal 'bold #f)
    +15 -100
    (overlay/align/offset
     "middle" "middle"
     (text/font "GAME OVER" 60 RED #f 'swiss 'normal 'bold #f)
     +15 100
     BACKGROUND))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; PAUSE-PAGE IMAGE

(define PAUSE-PAGE
  (overlay/align/offset
   "middle" "middle" (text/font "press 'esc' to resume" 30 PINK #f 'swiss 'normal 'bold #f)
   +15 -50
   (overlay/align/offset
    "middle" "middle" (text/font "press 'r' to restart" 30 LILAC #f 'swiss 'normal 'bold #f)
    +15 -100
    (overlay/align/offset
     "middle" "middle"
     (text/font "GAME IS PAUSED" 50 BLUE #f 'swiss 'normal 'bold #f)
     +15 100
     BACKGROUND))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; WELCOME IMAGE

(define WELCOME
  (overlay/align/offset
   "middle" "middle" (text/font "press 'space' to start" 30 "white" #f 'swiss 'normal 'bold #f)
   +15 -50
   (overlay/align/offset
    "middle" "middle"
    (beside (text/font "T " 60 YELLOW #f 'swiss 'normal 'bold #f)
            (text/font "E " 60 ORANGE #f 'swiss 'normal 'bold #f)
            (text/font "T " 60 PINK #f 'swiss 'normal 'bold #f)
            (text/font "R " 60 LILAC #f 'swiss 'normal 'bold #f)
            (text/font "I " 60 BLUE #f 'swiss 'normal 'bold #f)
            (text/font "S" 60 GREEN #f 'swiss 'normal 'bold #f))
    +15 100
    BACKGROUND)))


;; --------------------------------------------------------------------------

;; DATA TYPES

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Block is a Structure (make-block color is-falling)
; where:
;       - color is one of predefined BLOCK COLORS
;
;       - is-falling is a Boolean containing the position of the block in the grid
;                - #true when the block is falling
;                - #false when the block is not falling

(define-struct block [color is-falling] #:transparent)

; Examples

(define FYB (make-block YELLOW #true)) ; Falling Yellow Bloc
(define FOB (make-block ORANGE #true)) ; Falling Orange Block
(define FRB (make-block RED #true)) ; Falling Red Block
(define FPB (make-block PINK #true)) ; Falling Pink Block
(define FLB (make-block LILAC #true)) ; Falling Lilac Block
(define FBB (make-block BLUE #true)) ; Falling Blue Block
(define FGB (make-block GREEN #true)) ; Falling Green Block

(define NFEB (make-block EMPTY-COLOR #false)) ;Non-Falling Empty Block

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Piece is a Vector<Vector<Block>> where there the first Vector contains 4 Vectors of 10 Blocks each
;        - A piece is the combination of 4 blocks to form a tetromino
;        - This pieces will be spawned on top of the playing field and will fall down until it reaches the bottom or another piece
;        - The pieces are predefined

; PREDEFINED PIECES

(define O-PIECE (vector (vector NFEB NFEB NFEB NFEB FYB FYB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FYB FYB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define L-PIECE (vector (vector NFEB NFEB NFEB NFEB NFEB NFEB FOB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FOB FOB FOB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define Z-PIECE (vector (vector NFEB NFEB NFEB NFEB FRB FRB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB NFEB FRB FRB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define T-PIECE (vector (vector NFEB NFEB NFEB FPB FPB FPB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FPB NFEB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define J-PIECE (vector (vector NFEB NFEB NFEB NFEB FLB NFEB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FLB FLB FLB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define I-PIECE (vector (vector NFEB NFEB NFEB FBB FBB FBB FBB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define S-PIECE (vector (vector NFEB NFEB NFEB NFEB FGB FGB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB FGB FGB NFEB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))


; PREDEFINED FALLING-BLOCKS-POSITIONS
; When it's spawned, every piece has a predefined initial position.
; This is used to then move the blocks forming the piece to the left/right or to rotate them
; We predefined the blocks positions in order to avoid screening the whole grid to find the falling blocks that
; needed to be rotated. This way we can keep track of every falling block and its positions and we can use this
; information to move it around.

(define O-PIECE-POSITIONS (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)))
(define L-PIECE-POSITIONS (vector (make-posn 6 1) (make-posn 5 1) (make-posn 4 1) (make-posn 6 0)))
(define Z-PIECE-POSITIONS (vector (make-posn 6 1) (make-posn 5 1) (make-posn 5 0) (make-posn 4 0)))
(define T-PIECE-POSITIONS (vector (make-posn 4 1) (make-posn 5 0) (make-posn 4 0) (make-posn 3 0)))
(define J-PIECE-POSITIONS (vector (make-posn 6 1) (make-posn 5 1) (make-posn 4 1) (make-posn 4 0)))
(define I-PIECE-POSITIONS (vector (make-posn 6 0) (make-posn 5 0) (make-posn 4 0) (make-posn 3 0)))
(define S-PIECE-POSITIONS (vector (make-posn 4 1) (make-posn 3 1) (make-posn 5 0) (make-posn 4 0)))


(define FALLING-BLOCKS-POSITIONS (vector O-PIECE-POSITIONS L-PIECE-POSITIONS Z-PIECE-POSITIONS T-PIECE-POSITIONS J-PIECE-POSITIONS I-PIECE-POSITIONS S-PIECE-POSITIONS))


; PIECES-VECTOR

(define PIECES (vector O-PIECE L-PIECE Z-PIECE T-PIECE J-PIECE I-PIECE S-PIECE))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Grid is a Vector<Vector<Block>> (make-vector 10 (make-vector 24 Block))
;     - It represent a grid of width = 10 blocks, height = 24 blocks (of which only 20 visible)
;     - The grid is the playing field where the pieces will fall
;     - The main vector will be the rows of the grid, each row is a vector of blocks
;
; Examples

(define INITIAL-GRID (make-vector BLOCKS-IN-HEIGHT (make-vector BLOCKS-IN-WIDTH NFEB)))
(define FULL-ROW-EXAMPLE (make-vector BLOCKS-IN-WIDTH FPB))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Score is a Non-Negative-Integer
;        - It represents the number of lines completed by the user (1 line = 100 points)
;        - If the user completes more then one line at the same time,
;          the score will be increased by a special factor (All the way up to 4 lines at the same time)
;        - The score also increases while fast-dropping a piece

(define INITIAL-SCORE 0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATION-OFFSETS
; is a Vector<Vector<Vector<Posn>>>
;
; The first vector contains 6 different vectors as the number of pieces (O-PIECE EXCLUDED).
; The second degree vector contains 4 vectors, as the numer of possible rotations.
; The third degree vector contains 4 Posns that contain the offset value needed to update the
; coordinates of every single block forming the pieces in order to perform a rotation
; from the previous rotation status.
; Important note:
; in order to rotate - for example - to pos 3, the blocks have to go through all of the positions sequentially:
; starting from position 0 (which is the one thay are spawned into), then pos 1, then pos 2, then pos 3.

(define ROTATION-OFFSETS (vector
                          (vector ; L-piece
                           (vector (make-posn 1 1) (make-posn 0 0) (make-posn -1 -1) (make-posn 2 0))
                           (vector (make-posn -1 1) (make-posn 0 0) (make-posn 1 -1) (make-posn 0 2))
                           (vector (make-posn -1 -2) (make-posn 0 -1) (make-posn 1 0) (make-posn -2 -1))
                           (vector (make-posn 1 0) (make-posn 0 1) (make-posn -1 2) (make-posn 0 -1)))
                          (vector ; Z-piece
                           (vector (make-posn 1 1) (make-posn 0 0) (make-posn 1 -1) (make-posn 0 -2))
                           (vector (make-posn -1 1) (make-posn 0 0) (make-posn 1 1) (make-posn 2 0))
                           (vector (make-posn -1 -2) (make-posn 0 -1) (make-posn -1 0) (make-posn 0 1))
                           (vector (make-posn 1 0) (make-posn 0 1) (make-posn -1 0) (make-posn -2 1)))
                          (vector ; T-piece
                           (vector (make-posn -1 0) (make-posn 1 0) (make-posn 0 -1) (make-posn -1 -2))
                           (vector (make-posn -1 0) (make-posn -1 2) (make-posn 0 1) (make-posn 1 0))
                           (vector (make-posn 1 -1) (make-posn -1 -1) (make-posn 0 0) (make-posn 1 1))
                           (vector (make-posn 1 1) (make-posn 1 -1) (make-posn 0 0) (make-posn -1 1)))
                          (vector ; J-piece
                           (vector (make-posn 1 1) (make-posn 0 0) (make-posn -1 -1) (make-posn 0 -2))
                           (vector (make-posn -2 1) (make-posn -1 0) (make-posn 0 -1) (make-posn 1 0))
                           (vector (make-posn 0 -2) (make-posn 1 -1) (make-posn 2 0) (make-posn 1 1))
                           (vector (make-posn 1 0) (make-posn 0 1) (make-posn -1 2) (make-posn -2 1)))
                          (vector ; I-piece
                           (vector (make-posn 0 0) (make-posn -1 -1) (make-posn -2 -2) (make-posn -3 -3))
                           (vector (make-posn -3 3) (make-posn -2 2) (make-posn -1 1) (make-posn 0 0))
                           (vector (make-posn 0 -3) (make-posn 1 -2) (make-posn 2 -1) (make-posn 3 0))
                           (vector (make-posn 3 0) (make-posn 2 1) (make-posn 1 2) (make-posn 0 3)))
                          (vector ; S-piece
                           (vector (make-posn -1 0) (make-posn -2 -1) (make-posn 1 0) (make-posn 0 -1))
                           (vector (make-posn -1 0) (make-posn 0 -1) (make-posn -1 2) (make-posn 0 1))
                           (vector (make-posn 1 -1) (make-posn 2 0) (make-posn -1 -1) (make-posn 0 0))
                           (vector (make-posn 1 1) (make-posn 0 2) (make-posn 1 -1) (make-posn 0 0)))
                          ))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; WORLD-STATE
; A World-state is a Structure with the followings elements inside:
;      background:   Image that contains the grid, score and all the visual elements
;      grid:         The Grid containing all the blocks. Empty or not
;      score:        The score is a non-negative integer which represents the score of the player
;      should-quit:  Boolean value that represents if the application should quit or not
;      should-spawn: Boolean value that represents if a Piece should be generated at the top of the grid
;      is-paused:    Boolean value that represents if the game should be paused or not (Show pause menu)
;      falling-blocks: Vector of Posn that represents the position of the falling blocks in the grid
;      game-over:    Boolean value that represents if the player lost (#true) or not (#false)
;      tick:         Number that represents the number of times the function "tick-function" has been called
;                    This way we can keep track of how much time has passed (since time is measured in ticks).
;                    In order to define our personalized tick so that the game moves at a certain speed.
;                    It's only set to 0 once the game starts (or re-starts: press 'r'),
;                    to show the WELCOME PAGE (nothing happens in the game).
;                    When we press 'space' the tick is incremtented and the game starts.
;      tick-delay:   Number that represents how many ticks need to happen until the functions inside of the
;                    function "tick-function" are called. (Which means: until something happens in the game)
;      rotation-index: Number that represents the current rotation of the falling piece
;                      (0 = starting point, 1 = left, 2 = up, 3 = right)
;      piece-index:  Number that represents which piece is currently falling:
;                       0 = O-PIECE
;                       1 = L-PIECE
;                       2 = Z-PIECE
;                       3 = T-PIECE
;                       4 = J-PIECE
;                       5 = I-PIECE
;                       6 = S-PIECE
;      down-pressed:   Boolean that represents whether the down key is pressed or not (necessary for updating score)

(define-struct world-state [background grid score should-quit should-spawn is-paused falling-blocks game-over tick tick-delay rotation-index piece-index down-pressed] #:transparent)

; Examples
(define DEFAULT-TICK-DELAY 10)

(define INITIAL-STATE (make-world-state BACKGROUND INITIAL-GRID INITIAL-SCORE #false #true #false (make-vector 0) #false 0 DEFAULT-TICK-DELAY 0 0 #false))
(define EXAMPLE-STATE (make-world-state BACKGROUND INITIAL-GRID 100 #false #false #false O-PIECE-POSITIONS #false 0 DEFAULT-TICK-DELAY 0 0 #false))
(define TEST-STATE (shared ((-15- (make-block (make-color 253 207 179 255) #true))
                            (-18- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)) (-4- (make-block (make-color 30 30 30 255) #false)))
                     (make-world-state BACKGROUND (vector (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                          (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                          (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                          (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                          (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -15- -4- -4- -4-)
                                                          (vector -4- -4- -4- -4- -15- -15- -15- -4- -4- -4-) -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18-)
                                       0 #false #false #false (vector (make-posn 6 10) (make-posn 5 10) (make-posn 4 10) (make-posn 6 9)) #false 109 10 0 1 #false)))

;; -------------------------------------------------------------------------------------------------------------------

;; FUNCTIONS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; AUXILIARY FUNCTIONS TO UPDATE WORLD-STATE DATA

; All the functions take a World-state and a value return a World-state
; The element of the world-state the function is named after is updated with the value given as input.
; Value can be: Boolean, Number, Vector<Posn> (vopsn) or Vector<Vector<Block>>(vovob)
; update-xx: World-state
; (define (update-score 100) (make-world-state BACKGROUND INITIAL-GRID 100 #false #false #false #false))

; UPDATE-SCORE
(define (update-score world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) number
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)
                    (world-state-down-pressed world-state)))

; UPDATE-SHOULD-QUIT
(define (update-should-quit world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    boolean (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)
                    (world-state-down-pressed world-state)))

; UPDATE-SHOULD-SPAWN
(define (update-should-spawn world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) boolean (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)
                    (world-state-down-pressed world-state)))

; UPDATE-IS-PAUSED
(define (update-is-paused world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) boolean
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)
                    (world-state-down-pressed world-state)))

; UPDATE-FALLING-BLOCKS
(define (update-falling-blocks world-state vopsn)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    vopsn (world-state-game-over world-state) (world-state-tick world-state) (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state) (world-state-down-pressed world-state)))

; UPDATE-GRID
(define (update-grid world-state vovob)
  (make-world-state (world-state-background world-state) vovob (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)
                    (world-state-down-pressed world-state)))

; UPDATE-GAME-OVER
(define (update-game-over world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) boolean (world-state-tick world-state) (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state) (world-state-down-pressed world-state)))

; UPDATE-TICK
(define (update-tick world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) number (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state) (world-state-down-pressed world-state)))

; UPDATE-TICK-DELAY
(define (update-tick-delay world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state) number
                    (world-state-rotation-index world-state) (world-state-piece-index world-state) (world-state-down-pressed world-state)))

; UPDATE-ROTATION-INDEX
(define (update-rotation-index world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) number (world-state-piece-index world-state) (world-state-down-pressed world-state)))

; UPDATE-PIECE-INDEX
(define (update-piece-index world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) number (world-state-down-pressed world-state)))
; UPDATE-DOWN-PRESSED
(define (update-down-pressed world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state) boolean))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; VECTOR-SET

; takes a vector, a position (Number) and a value (Number) and returns a Vector with the new value at the indicated position
; vector-set: Vector Number Number -> Vector
; (define (vector-set (vector 1 2 3) 3 4)) (vector 1 2 4)

(check-expect (vector-set (vector 1 2 3 4 5) 3 4)
              (vector 1 2 3 4 5))

(define (vector-set vec pos value)
  (local (
          (define VEC-LEN (vector-length vec))
          (define (set-value vec pos value)
            (cond
              [(= pos 0) (vector-append (vector value) (vector-take-right vec (sub1 VEC-LEN)))]
              [(= pos (sub1 VEC-LEN)) (vector-append (vector-take vec (sub1 VEC-LEN)) (vector value))]
              [else (vector-append (vector-take vec pos) (vector value) (vector-take-right vec (- (sub1 VEC-LEN) pos)))]))
          ) (set-value vec pos value)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SET-GRID-BLOCK FUNCTION

; takes a Block, a Grid and a Posn and edits the Grid with a Block at the coordinates given as inputs in the Posn
; set-grid-block: Block Grid Posn -> Grid
; (define (set-grid-block FGB CIPPI-GRID (make-posn 3 2) CIPPI-GRID2)
; (define (set-grid-block block grid posn)

(check-expect (set-grid-block FPB INITIAL-GRID (make-posn 9 9))
              (shared ((-1- (vector -2- -2- -2- -2- -2- -2- -2- -2- -2- -2-))
                       (-2- (make-block (make-color 30 30 30 255) #false)))
                (vector -1- -1- -1- -1- -1- -1- -1- -1- -1-
                        (vector -2- -2- -2- -2- -2- -2- -2- -2- -2-
                                (make-block (make-color 246 207 250 255) #true)) -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1-)))

(define (set-grid-block block grid posn)
  (set-grid-row grid (posn-y posn)
                (vector-set (get-grid-row grid (posn-y posn)) (posn-x posn) block)))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SET-GRID-ROW FUNCTION

; Takes a Grid, a Number and a Vector. At the position Number of the Grid it inserts the Vector given as input
; set-grid-row: Grid Number Grid -> Grid
; (define (set-grid-row grid y vect) )

(check-expect (set-grid-row INITIAL-GRID 3 FULL-ROW-EXAMPLE) (vector
                                                              (vector 
                                                               (block (color 30 30 30 255) #f) 
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t)
                                                               (block (color 246 207 250 255) #t))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))
                                                              (vector
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f)
                                                               (block (color 30 30 30 255) #f))))

(define (set-grid-row grid y vect)
  (cond
    [(= y 0) (vector-append (vector vect) (vector-take-right grid (sub1 BLOCKS-IN-HEIGHT)))]
    [(= y (sub1 BLOCKS-IN-HEIGHT)) (vector-append (vector-take grid (sub1 BLOCKS-IN-HEIGHT)) (vector vect))]
    [else (vector-append (vector-take grid y) (vector vect) (vector-take-right grid (- (sub1 BLOCKS-IN-HEIGHT) y)))]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GET-GRID-BLOCK FUNCTION

; takes a Grid, x and y and returns the block at those coordinates
; get-grid-block: Grid Number Number -> Block
; (define (get-grid-block Grid Number Number) FEB)

(check-expect (get-grid-block INITIAL-GRID 5 6) (block (color 30 30 30 255) #f))

(define (get-grid-block grid x y)
  (vector-ref (vector-ref grid y) x))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GET-GRID-ROW FUNCTION

; takes a Grid and a y coordinate and returns a Vector representing the row of the grid at that coordinate
; get-grid-row: Grid Number -> Vector
; (define (get-grid-row Grid Number) (make-vector ..))

(check-expect (get-grid-row INITIAL-GRID 4)
              (vector
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)
               (block (color 30 30 30 255) #f)))

(define (get-grid-row grid y)
  (vector-ref grid y))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ADD-PIECE-TO-WORLD-STATE FUNCTION

; Receives a World-state and a Piece as inputs and adds the Piece at the top of the Grid (in the center)
; add-piece-to-world-state: World-state Piece -> World-state
; (define (add-piece-to-world-state world-state piece) INITIAL-STATE)

(check-expect (add-piece-to-world-state INITIAL-STATE O-PIECE)
              (world-state
               BACKGROUND
               (vector
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)))
               0
               #f
               #t
               #f
               '#()
               #f
               0
               10
               0
               0
               #f))

 
(define (add-piece-to-world-state world-state piece)
  (update-grid world-state
               (vector-append
                (vector
                 (vector-ref piece 0)
                 (vector-ref piece 1)
                 (vector-ref piece 2)
                 (vector-ref piece 3))
                (vector-take-right (world-state-grid world-state) (- BLOCKS-IN-HEIGHT 4)))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-BLOCKS-OFFSET FUNCTION

; Takes a World-state and 2 coordinates and:
; - removes from the grid the blocks at coordinates in falling-block (in the world-state)
; - updates the new posns (in falling-blocks) with the coordinates in inputs 
; - calls add-blocks-to-falling-blocks-posns that adds the blocks to the grid in the posn coordinates in falling-blocks
; it's necessary to move the blocks left, right, down (move-x calls it)
; move-blocks-offset: World-state Number Number -> World-state
; (define (move-blocks-offset world-state x-offset y-offset) INITIAL-STATE)

(check-expect (add-piece-to-world-state INITIAL-STATE O-PIECE)
              (world-state
               BACKGROUND
               (vector
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)))
               0
               #f
               #t
               #f
               '#()
               #f
               0
               10
               0
               0
               #f))

(define (move-blocks-offset world-state x-offset y-offset)
  (add-blocks-to-falling-blocks-posns
   (update-posns-in-falling-blocks (remove-blocks-in-posn world-state) x-offset y-offset)
   ))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SPAWN-PIECE FUNCTION

; Takes a World-state and does this:
; Set rotation-index to 0 and update piece-index with a random number between 0 and 7.
; Then add the corresponding piece with add-piece-to-worldstate.
; Then update-should-spawn (to false) and update-falling-blocks with the new positions (found in FALLING-BLOCKS-POSITIONS).
; spawn-piece: World-state -> World-state
; (define (spawn-piece world-state) INITIAL-STATE)

(check-expect (add-piece-to-world-state INITIAL-STATE O-PIECE)
              (world-state
               BACKGROUND
               (vector
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)))
               0
               #f
               #t
               #f
               '#()
               #f
               0
               10
               0
               0
               #f))


(define (spawn-piece world-state)
  (local (
          (define (omegaFunction world-state num)
            (update-falling-blocks (update-should-spawn (add-piece-to-world-state (update-piece-index (update-rotation-index world-state 0) num)
                                                                                  (vector-ref PIECES num))
                                                        #false)
                                   (vector-ref FALLING-BLOCKS-POSITIONS num))))
    (omegaFunction world-state (random 7)))

  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; FB-TO-NFB

; takes a World-state and returns a World-state where the falling blocks that reach the bottom of the grid
; are turned into non falling blocks
; fb-to-nfb: World-state -> World-state
; (define (fb-to-nfb world-state) CIPPI-WORLD-STATE)

(check-expect (add-piece-to-world-state INITIAL-STATE O-PIECE)
              (world-state
               BACKGROUND
               (vector
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 242 240 184 255) #t)
                 (block (color 242 240 184 255) #t)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f))
                (vector
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)
                 (block (color 30 30 30 255) #f)))
               0
               #f
               #t
               #f
               '#()
               #f
               0
               10
               0
               0
               #f))


(define (fb-to-nfb world-state)
  (local (
          (define FALLING-BLOCKS (world-state-falling-blocks world-state))
          (define LEN (vector-length FALLING-BLOCKS))
          (define (intra world-state x)
            (cond
              [(= x (sub1 LEN)) (update-grid world-state
                                             (set-grid-block (make-block
                                                              (block-color (get-grid-block (world-state-grid world-state)
                                                                                           (posn-x (vector-ref FALLING-BLOCKS x))
                                                                                           (posn-y (vector-ref FALLING-BLOCKS x))))
                                                              #false)
                                                             (world-state-grid world-state) (vector-ref FALLING-BLOCKS x)))]
              [else (update-grid world-state
                                 (set-grid-block (make-block
                                                  (block-color (get-grid-block (world-state-grid world-state)
                                                                               (posn-x (vector-ref FALLING-BLOCKS x))
                                                                               (posn-y (vector-ref FALLING-BLOCKS x))))
                                                  #false)
                                                 (world-state-grid (intra world-state (add1 x))) (vector-ref FALLING-BLOCKS x)
                                                 ))]
              ))) (intra world-state 0) ))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; IS-NEW-DESTINATION-IN-GRID? FUNCTION

; Takes a World-state and returns a Boolean in the following way:
; Checks if the destination position (the current position + the offsets) is in the grid
; is-new-destination-in-grid?: World-state -> Boolean
; (define (is-new-destination-in-grid? world-state) #true)

(check-expect (is-new-destination-in-grid? EXAMPLE-STATE 4 7) #true)
(check-expect (is-new-destination-in-grid? EXAMPLE-STATE 11 26) #false)

(define (is-new-destination-in-grid? world-state x-offset y-offset)
  (local (
          (define FALLING-BLOCKS-TEMP (world-state-falling-blocks world-state))
          (define POSN-LEN (vector-length FALLING-BLOCKS-TEMP))
          (define (check-if-valid x)
            (cond
              [(= x (sub1 POSN-LEN)) (and (< (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) BLOCKS-IN-WIDTH)
                                          (>= (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) 0)
                                          (< (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) BLOCKS-IN-HEIGHT)
                                          (> (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) 0)
                                          (can-block-fall? world-state (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset)
                                                           (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset)))]
              
              
              [else (and (< (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) BLOCKS-IN-WIDTH)
                         (>= (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) 0)
                         (< (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) BLOCKS-IN-HEIGHT)
                         (> (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) 0)
                         (can-block-fall? world-state (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset)
                                          (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset))
                         (check-if-valid (add1 x)))]
              ))
          ) (check-if-valid 0)))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; UPDATE-POSNS-IN-FALLING-BLOCKS FUNCTION

; Takes a World-state and returns a World-state where the posn-x and posn-x of the Posns in vector of Posn are shifted by offSet
; update-posns-in-falling-blocks: World-state Number Number -> World-state
; (define (update-posns-in-falling-blocks world-state 0 1) INITIAL-STATE)

(check-expect (update-posns-in-falling-blocks EXAMPLE-STATE 4 5)
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  100 #false #false #false (vector (make-posn 9 6) (make-posn 8 6) (make-posn 9 5) (make-posn 8 5)) #false 0 10 0 0 #false)))

(define (update-posns-in-falling-blocks world-state x-offset y-offset)
  (update-falling-blocks world-state
                         (vector-map
                          (lambda (posn) (make-posn (+ (posn-x posn) x-offset) (+ (posn-y posn) y-offset)))
                          (world-state-falling-blocks world-state))))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CAN-BLOCK-FALL? FUNCTION

; takes a World-state, x and y coordinates and returns true if the Block (add1 y)
; at the coordinates x y in the Grid can fall
; can-block-fall?: World-state Number Number -> Boolean
; (define (can-block-fall? World-state x y) #true)
;

(check-expect (can-block-fall? EXAMPLE-STATE 1 5) #true)

(define (can-block-fall? world-state x y)
  (cond
    [(and (not (block-is-falling (get-grid-block (world-state-grid world-state) x y)))
          (not (is-block-empty? (get-grid-block (world-state-grid world-state) x y)))) #false]
    [else #true]))

; AUX IS-BLOCK-EMPTY?

(define (is-block-empty? block)
  (equal? (block-color block) EMPTY-COLOR))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; CAN-BLOCKS-ROTATE? FUNCTION

; Takes a World-state and returns #true if the blocks can rotate, otherwise returns #false
; can-blocks-rotate?: World-state -> Boolean
; (define (can-blocks-rotate? world-state) #true)

(check-expect (can-blocks-rotate? TEST-STATE) #true)


(define (can-blocks-rotate? world-state)
  (if (and

       ; checks if the coordinates are in the grid
       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
           1
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
          (sub1 BLOCKS-IN-HEIGHT)
          )


       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
           1
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
          (sub1 BLOCKS-IN-HEIGHT)
          )


       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
           1
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
          (sub1 BLOCKS-IN-HEIGHT)
          )



       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
           1
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
          (sub1 BLOCKS-IN-HEIGHT)
          )


       ; is the destination free?
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 0) 0))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 1) 1))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 2) 2))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3))))

       )
      ; can rotate
      #true

      ; can-t rotate
      #false
      ))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; UPDATE-POSNS-FOR-ROTATION FUNCTION

; Takes a World-state and returns a World-state with the falling-blocks updated in the following way:
; it adds the posns in the falling-blocks vector and the posns in the rotation-offsets for every block in the piece
; (which piece? the one in piece-index!)
; update-posns-for-rotation: World-state -> World-state
; (define (update-posns-for-rotation world-state) INITIAL-STATE)

(check-expect (update-posns-for-rotation TEST-STATE)
              (shared ((-15- (make-block (make-color 253 207 179 255) #true))
                       (-18- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -15- -4- -4- -4-) (vector -4- -4- -4- -4- -15- -15- -15- -4- -4- -4-)
                                                     -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18- -18-)
                                  0 #false #false #false (vector (make-posn 7 11) (make-posn 5 10) (make-posn 3 9) (make-posn 8 9)) #false 109 10 0 1 #false)))


(define (update-posns-for-rotation world-state)
  (update-falling-blocks world-state
                         (vector
                          (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
                                        (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0)))
                                     (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
                                        (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 0))))
                          (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
                                        (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1)))
                                     (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
                                        (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 1))))
                          (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
                                        (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2)))
                                     (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
                                        (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 2))))
                          (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
                                        (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3)))
                                     (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
                                        (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) 3))))
                          )
                         )
  )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; ADD-BLOCKS-TO-FALLING-BLOCKS-POSNS FUNCTION

; Takes a World-state and returns a World-state updated in the following way:
; the falling blocks in the grid have been added to the position listed in falling-blocks (in the world-state). Needed for move-blocks-offset and rotate-cw.
; add-blocks-to-falling-blocks-posns: World-state -> World-state
; (define (add-blocks-to-falling-blocks-posns world-state) EXAMPLE-STATE)

(check-expect (add-blocks-to-falling-blocks-posns EXAMPLE-STATE)
              (shared ((-4- (make-block (make-color 30 30 30 255) #false))
                       (-6- (make-block (make-color 242 240 184 255) #true)) (-9- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)))
                (make-world-state BACKGROUND (vector (vector -4- -4- -4- -4- -6- -6- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -6- -6- -4- -4- -4- -4-)
                                                     -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9- -9-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (add-blocks-to-falling-blocks-posns world-state)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))
          (define PIECE-INDEX (world-state-piece-index world-state))

          (define (add-blocks-to-grid world-state x)
            (cond
              [(= x (sub1 BLOCKS-LENGTH)) (update-grid world-state
                                                       (set-grid-block
                                                        (cond
                                                          [(= PIECE-INDEX 0) FYB]
                                                          [(= PIECE-INDEX 1) FOB]
                                                          [(= PIECE-INDEX 2) FRB]
                                                          [(= PIECE-INDEX 3) FPB]
                                                          [(= PIECE-INDEX 4) FLB]
                                                          [(= PIECE-INDEX 5) FBB]
                                                          [(= PIECE-INDEX 6) FGB]
                                                          )

                                                        (world-state-grid world-state)
                                                        (vector-ref (world-state-falling-blocks world-state) x)
                                                        )
                                                       )
                                          ]
              [else
               (update-grid world-state
                            (set-grid-block
                             (cond
                               [(= PIECE-INDEX 0) FYB]
                               [(= PIECE-INDEX 1) FOB]
                               [(= PIECE-INDEX 2) FRB]
                               [(= PIECE-INDEX 3) FPB]
                               [(= PIECE-INDEX 4) FLB]
                               [(= PIECE-INDEX 5) FBB]
                               [(= PIECE-INDEX 6) FGB]
                               )

                             (world-state-grid (add-blocks-to-grid world-state (add1 x)))
                             (vector-ref (world-state-falling-blocks world-state) x)
                             )
                            )
               ]
              )
            )
          ) (add-blocks-to-grid world-state 0)))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; REMOVE-BLOCKS-IN-POSN

; takes a World-state and returns a World-state with the blocks that were falling removed. Needed for move-blocks-offset and rotate-cw
; remove-blocks-in-posn: World-state -> World-state
; (define (remove-blocks-in-posn world-state) INITIAL-STATE)

(check-expect (remove-blocks-in-posn EXAMPLE-STATE)
              (shared ((-4- (make-block (make-color 30 30 30 255) #false))
                       (-7- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)))
                (make-world-state BACKGROUND (vector (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7- -7-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (remove-blocks-in-posn world-state)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))

          (define (remove-blocks world-state x)
            (cond

              [(= x (sub1 BLOCKS-LENGTH))
               (update-grid world-state
                            (set-grid-block
                             NFEB
                             (world-state-grid world-state)
                             (vector-ref (world-state-falling-blocks world-state) x)
                             ))]
              
              [else
               (update-grid world-state
                            (set-grid-block
                             NFEB
                             (world-state-grid (remove-blocks world-state (add1 x)))
                             (vector-ref (world-state-falling-blocks world-state) x)
                             ))]
              ))) 

    (remove-blocks world-state 0))
  )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATE-CW FUNCTION

; Takes a world-state and returns the same world-state, but the falling blocks are rotated clock-wise
; rotate-cw : World-state -> World-state
; (define (rotate-cw world-state) INITIAL-STATE)

(check-expect (rotate-cw TEST-STATE)
              (shared ((-15- (make-block (make-color 253 207 179 255) #true))
                       (-17- (make-block (make-color 30 30 30 255) #false)) (-21- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -15- -17- -4- -4- -4-)
                                                     (vector -4- -4- -4- -4- -17- -15- -17- -4- -4- -4-) (vector -4- -4- -4- -4- -4- -15- -15- -4- -4- -4-)
                                                     -21- -21- -21- -21- -21- -21- -21- -21- -21- -21- -21- -21-)
                                  0 #false #false #false (vector (make-posn 5 11) (make-posn 5 10) (make-posn 5 9) (make-posn 6 11)) #false 109 10 1 1 #false)))


(define (rotate-cw world-state)
  (if (can-blocks-rotate? (update-rotation-index world-state
                                                 (if (= (world-state-rotation-index world-state) 3)
                                                     0
                                                     (add1 (world-state-rotation-index world-state))
                                                     )))

      ; can rotate

      (add-blocks-to-falling-blocks-posns
       ; update coordinates in falling-blocks with the added offset (using update-posns-for-rotation)
       (update-posns-for-rotation
        (update-rotation-index
         ; delete the blocks at coordinates old world-state-fallin-blocks
         (remove-blocks-in-posn world-state)
         ; update rotation index
         (if (= (world-state-rotation-index world-state) 3)
             0
             (add1 (world-state-rotation-index world-state))
             )
         )
        ))

      ; can-t rotate: do nothing
      world-state
      )
  )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; FOR TESTS

(define CIPPI-GRID (set-grid-row (world-state-grid EXAMPLE-STATE) 17 FULL-ROW-EXAMPLE))
(define CIPPI-WORLD-STATE (update-grid EXAMPLE-STATE CIPPI-GRID))

(define CIPPI-GRID2 (set-grid-row (world-state-grid EXAMPLE-STATE) 4 FULL-ROW-EXAMPLE))
(define CIPPI-WORLD-STATE2 (update-grid EXAMPLE-STATE CIPPI-GRID2))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROW-FULL FUNCTION

; takes a World-state and determines if there are any full rows (if there is a row where all the blocks have a color
; that is not EMPTY-COLOR), it returns the number of row that is full or #false if there are now full rows
; row-full: World-state -> Number/Boolean
; (define (row-full world-state) 5)

(check-expect (row-full CIPPI-WORLD-STATE) 17)
(check-expect (row-full CIPPI-WORLD-STATE2) 4)
(check-expect (row-full INITIAL-STATE) #false)


(define (row-full world-state)

  (local
    (
     (define (row-full-int world-state y)
       (cond
         [(= y 4) (if (boolean? (vector-member
                                 NFEB (get-grid-row (world-state-grid world-state) y)))
                      y
                      #false
                      )]
         [else (if (boolean? (vector-member
                              NFEB (get-grid-row (world-state-grid world-state) y)))
                   y
                   (row-full-int world-state (sub1 y)))
               ]
         )))
    (row-full-int world-state (sub1 BLOCKS-IN-HEIGHT))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; PUSH-DOWN-ROWS

; take a World-state and a y and returns a World-state where the whole grid, from y upwards, has been
; pushed down by one
; push-down-rows: World-state -> World-state
; (define (push-down-rows world-state) EXAMPLE-STATE)

(check-expect (push-down-rows CIPPI-WORLD-STATE 17) EXAMPLE-STATE)
(check-expect (push-down-rows CIPPI-WORLD-STATE2 4) EXAMPLE-STATE)

(define (push-down-rows world-state y)
  (update-grid world-state
               (cond
                 [(= y 4) (vector-append (vector-take (world-state-grid world-state) 4)
                                         (vector (make-vector 10 NFEB))
                                         (vector-take-right (world-state-grid world-state) (- BLOCKS-IN-HEIGHT 5)))]
                 [else (vector-append (vector-take (world-state-grid world-state) 4)
                                      (vector (make-vector 10 NFEB))
                                      (vector-copy (world-state-grid world-state) 4 y)
                                      (vector-copy (world-state-grid world-state) (add1 y) BLOCKS-IN-HEIGHT)
                                      )])))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ANY-FULL-ROWS

; takes a World-state and returns a World-state in the following way:
; if there are full rows in the grid, deletes them and pushes all the rows above down by 1
; and checks again if there are full rows in the grid
; deleted-until-now is needed to keep track of the deleted lines in order to update the score
; if there aren't any full rows, returns the World-state given as input
; any-full-rows: World-state Number -> World-state
; (define (any-full-rows world-state) CIPPI-WORLD-STATE)

(check-expect (any-full-rows EXAMPLE-STATE 2)
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  400 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (any-full-rows world-state deleted-until-now)
  (cond
    [(boolean? (row-full world-state)) (cond
                                         [(= 0 deleted-until-now) world-state]
                                         [(= 1 deleted-until-now) (update-score world-state (+ (world-state-score world-state) 100))]
                                         [(= 2 deleted-until-now) (update-score world-state (+ (world-state-score world-state) 300))]
                                         [(= 3 deleted-until-now) (update-score world-state (+ (world-state-score world-state) 500))]
                                         [(= 4 deleted-until-now) (update-score world-state (+ (world-state-score world-state) 800))])]
    [else (any-full-rows (push-down-rows world-state (row-full world-state)) (add1 deleted-until-now))]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; LOSER FUNCTION

; takes a World-state and checks if the 4th row has Blocks whose color is not EMPTY-COLOR
; if true: returns World-state with game-over turned to #true, should-spawn turned to #false
; loser: World-state -> World-state
; (define (loser world-state) EXAMPLE-STATE)
; (define (loser world-state)

(check-expect (loser EXAMPLE-STATE)
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))



(define (loser world-state)
  (if
   (vector-member #true (vector-map is-block-nonempty?
                                    (get-grid-row (world-state-grid world-state) 3)))
   (update-game-over world-state #true)
   world-state))


; AUX IS-BLOCK-NONEMPTY?

(define (is-block-nonempty? block)
  (not (equal? (block-color block) EMPTY-COLOR)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-X

; Takes a World-state, checks if the new destination is valid and then calls move-blocks-offset to move the blocks.
; IMPORTANT: direction = 1 moves right, direction = -1 moves left
; move-x: World-state Number -> World-state
; (define (move-x world-state direction) CIPPI-WORLD-STATE)

(check-expect (move-x EXAMPLE-STATE 1)
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (move-x world-state direction) ;1 right, -1 left
  (if (is-new-destination-in-grid? world-state direction 0)
      (move-blocks-offset world-state direction 0)
      world-state)
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; TICK-FUNCTION

; takes a World-state and, if flag should-spawn is true adds a Piece to the Grid:
;     - add-piece-to-world-state with a random piece
;     - turns to #false should-spawn
;     - update-falling-blocks with the predefined position of the random piece that was selected
; Every tick increments the world-state tick by 1. After world-state-tick-delay ticks the game advances once.
; tick-function: World-state -> World-state
; (define (tick-function world-state) CIPPI-WORLD-STATE)

(check-expect (tick-function EXAMPLE-STATE)
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (tick-function world-state)
  (if (= 0 (world-state-tick world-state))
      world-state
      ; increment tick
      (update-tick
       ; if we reach the necessary amount of ticks in order for something to happen in the game the modulo of the tick and the tick-delay is 0
       (if (= 0 (modulo (world-state-tick world-state) (world-state-tick-delay world-state)))
           ; if game is paused or over return world-state
           (if (or (world-state-is-paused world-state) (world-state-game-over world-state))
               ; return world-state (nothing happens)
               world-state
               ; if should-spawn is true
               (if (world-state-should-spawn world-state)
                   ; spawn a piece
                   (spawn-piece world-state)
                   ; else move-falling-blocks-down-by-1
                   ; if the new positions with the offset applied are available to be filled with blocks
                   (if (is-new-destination-in-grid? world-state 0 1)
                       ; move the blocks to the new positions
                       (move-blocks-offset (if (world-state-down-pressed world-state) (update-score world-state (add1 (world-state-score world-state))) world-state) 0 1)
                       ; else: check if you lost after getting rid of possible full rows
                         
                       (if (world-state-game-over (loser (any-full-rows world-state 0)))
                           ; if you lost: turns should-spawn to false, turns the falling blocks in non falling blocks, 
                           ; sets game-over to true and deletes full rows, if down-key is pressed updates score
                           (update-should-spawn (fb-to-nfb (update-game-over (any-full-rows 
                                                                              (if (world-state-down-pressed world-state) (update-score world-state (add1 (world-state-score world-state))) world-state) 0) #true)) #false)
                           ; if you didn't lose, a new block will spawn at the top in the next cycle
                           (update-should-spawn (fb-to-nfb (any-full-rows 
                                                            (if (world-state-down-pressed world-state) (update-score world-state (add1 (world-state-score world-state))) world-state) 0)) #true)
                           )
                       )
                   )
               )
           world-state)
       (add1 (world-state-tick world-state)))
      )
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; HANDLE-KEY FUNCTION

; takes a World-state and a key-event and returns an updated World-state in the following way:
; if key-event is left, moves non-empty FALLING blocks that are in grid to the left
; if key-event is right, moves non-empty FALLING blocks that are in grid to the right
; if key-event is down, moves non-empty FALLING blocks that are in grid faster down
; if key-event is up, rotates FALLING PIECE clock-wise
; handle-key: World-state -> World-state
; (define (handle-key world-state) CIPPI-WORLD-STATE)

(check-expect (handle-key EXAMPLE-STATE "right")
              (shared ((-3- (vector -4- -4- -4- -4- -4- -4- -4- -4- -4- -4-))
                       (-4- (make-block (make-color 30 30 30 255) #false)))
                (make-world-state BACKGROUND (vector -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3- -3-)
                                  100 #false #false #false (vector (make-posn 5 1) (make-posn 4 1) (make-posn 5 0) (make-posn 4 0)) #false 0 10 0 0 #false)))


(define (handle-key world-state key)
  (cond
    [(key=? key "left") (move-x world-state -1)]
    [(key=? key "right") (move-x world-state 1)]
    [(key=? key "down") (update-tick-delay (update-down-pressed world-state #T) 1)]
    [(key=? key "up") (if (or (= 0 (world-state-piece-index world-state)) (world-state-game-over world-state) (world-state-is-paused world-state)) world-state (rotate-cw world-state))]
    [(key=? key "r") (if (or (world-state-game-over world-state) (world-state-is-paused world-state)) (update-tick INITIAL-STATE (world-state-tick-delay INITIAL-STATE)) world-state)]
    [(key=? key "escape") (if (world-state-game-over world-state) world-state (update-is-paused world-state (not (world-state-is-paused world-state))))]
    [(key=? key "q") (update-should-quit world-state #true)]
    [(key=? key " ") (if (= 0 (world-state-tick world-state)) (update-tick world-state (world-state-tick-delay world-state)) world-state)]
    [else world-state]
    ))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; HANDLE-RELEASE

; takes a World-state and a String and returns the world-state with the tick-delay updated to 1
; handle-release: World-state String -> World-state
; (define (handle-release world-state key) CIPPI-WORLD-STATE)

(define (handle-release world-state key)
  (if (equal? key "down") (update-tick-delay (update-down-pressed world-state #false) DEFAULT-TICK-DELAY)
      world-state))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; QUIT? FUNCTION

; Takes a world-state and determines if the game has been quit
; quit?: World-state -> Boolean
; (define (quit? world-state) #false)

(check-expect (quit? EXAMPLE-STATE) #false)


(define (quit? world-state)
  (world-state-should-quit world-state))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCK-TO-IMAGE FUNCTION

; Renders a single Block with a black outline
; block-to-image: Block -> Image
; (define (block-to-image block) (rectangle 28 28 "solid" "black")

(define (block-to-image block)
  (overlay (rectangle 28 28 "solid" (block-color block)) (rectangle 30 30 "solid" "black")))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GRID-ROW-IMAGE FUNCTION

; Returns the requested row of the given grid as an image
; grid-row-to-image: Grid Number -> Image
; (define (grid-row-to-image Grid Number) (rectangle 28 28 "solid" "black"))

(define (grid-row-image grid y)
  (local (
          (define (grid-row-to-image grid x y)
            (if (< x (sub1 BLOCKS-IN-WIDTH))
                (beside (block-to-image (get-grid-block grid x y)) (grid-row-to-image grid (add1 x) y))
                (block-to-image (get-grid-block grid x y))
                )
            )
          ) (grid-row-to-image grid 0 y)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GRID-TO-IMAGE FUNCTION

; Renders the grid in the world state as an Image
; Grid-to-image: Grid -> Image
; (define (grid-to-image grid) (rectangle 28 28 "solid" "black"))

(define (grid-to-image grid)
  (local (
          (define (grid-to-image-inner grid y)
            (if (< y (sub1 BLOCKS-IN-HEIGHT))
                (above (grid-row-image grid y) (grid-to-image-inner grid (add1 y)))
                (grid-row-image grid y))))
    (grid-to-image-inner grid 4)))                         ; CHANGE THIS TO 0 TO SEE THE TOP PART, OTHERWISE PUT 4

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SCORE-TO-IMAGE FUNCTION

; Takes a Score and turns it into an Image
; score-to-image: WorldState -> Image
; (define (score-to-image (world-state-score world-state) (rectangle 28 28 "solid" "black"))
;
;
(define (score-to-image world-state)
  (text/font (string-append "SCORE: " (number->string (world-state-score world-state))) 30 SCORE-COLOR #f 'swiss 'normal 'bold #f))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; DRAW FUNCTION

; Takes a WorldState and renders the background and the grid
; * if game over is true: render game over page
; * if is-paused is true: render pause page
; * else: regular game page
; draw: WorldState -> Image
; (define (draw world-state) (rectangle 28 28 "solid" "black"))

(define (draw world-state)
  (cond
    [(if (= 0 (world-state-tick world-state))
         WELCOME
         (cond [(world-state-game-over world-state) (overlay/align/offset "middle" "middle" (text/font ( string-append "SCORE: " (number->string (world-state-score world-state))) 40 LILAC #f 'swiss 'normal 'bold #f) +15 +20 GAME-OVER-PAGE)]
               [(world-state-is-paused world-state) PAUSE-PAGE]
               [else (overlay/offset
                      (text/font "press 'q' to quit"  15 GREY
                                 #f 'swiss 'normal 'bold #f)
                      0
                      -360
                      (overlay/offset
                       (text/font "press 'esc' to pause"  15 "white"
                                  #f 'swiss 'normal 'bold #f)
                       0
                       -330
                       (overlay/offset (score-to-image world-state)
                                       150
                                       350
                                       (overlay (grid-to-image (world-state-grid world-state))
                                                (rectangle 302 602 "solid" "black")
                                                (world-state-background world-state)))))]))]
    ))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BIG-BANG

(define (tetris initial-state)
  (big-bang initial-state
    [on-tick tick-function]
    [on-key handle-key]
    [on-release handle-release]
    [stop-when quit?]
    [close-on-stop #true]
    [to-draw draw]
    ))

(define (run funct arg) (if (funct arg) (display "Bye bye!\n") (display "Bye bye!\n")))
(run tetris INITIAL-STATE)
