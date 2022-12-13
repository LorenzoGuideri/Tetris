#lang htdp/asl

(require 2htdp/universe)
(require 2htdp/image)
(require racket/vector)
(require racket/base)

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

(define COLORS (vector YELLOW ORANGE RED PINK LILAC BLUE GREEN))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BACKGROUND

(define WIDTH-BG 560)
(define HEIGHT-BG 800)
(define BACKGROUND (rectangle WIDTH-BG HEIGHT-BG "solid" EMPTY-COLOR))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCKS IN GRID

(define BLOCKS-IN-WIDTH 10)
(define BLOCKS-IN-HEIGHT 24)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GAME-OVER-PAGE

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

; PAUSE-PAGE

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

; WELCOME

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

(define FEB (make-block EMPTY-COLOR #true)) ; Falling Empty Block
(define FYB (make-block YELLOW #true)) ; Falling Yellow Bloc
(define FOB (make-block ORANGE #true)) ; Falling Orange Block
(define FRB (make-block RED #true)) ; Falling Red Block
(define FPB (make-block PINK #true)) ; Falling Pink Block
(define FLB (make-block LILAC #true)) ; Falling Lilac Block
(define FBB (make-block BLUE #true)) ; Falling Blue Block
(define FGB (make-block GREEN #true)) ; Falling Green Block

(define NFEB (make-block EMPTY-COLOR #false)) ;Non-Falling Empty Block
(define NFYB (make-block YELLOW #false)) ; Non-Falling Yellow Bloc
(define NFOB (make-block ORANGE #false)) ; Non-Falling Orange Block
(define NFRB (make-block RED #false)) ; Non-Falling Red Block
(define NFPB (make-block PINK #false)) ; Non-Falling Pink Block
(define NFLB (make-block LILAC #false)) ; Non-Falling Lilac Block
(define NFBB (make-block BLUE #false)) ; Non-Falling Blue Block
(define NFGB (make-block GREEN #false)) ; Non-Falling Green Block

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Piece is a Vector<Vector<Block>> where there the first Vector contains 4 Vectors of 10 Blocks each
;        - A piece is the combination of various blocks to form the well known tetromin
;        - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece
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

; a Score is a Natural
;        - It represents the number of lines completed by the user (1 line = 100 points)
;        - If the user completes more then one line at the same time,
;          the score will be increased by a special factor (All the way up to 4 lines at the same time)
; Examples

(define INITIAL-SCORE 0)

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Grid is a Vector<Vector<Block>> (make-vector 10 (make-vector 40 Block))
;     - It represent a grid of width = 10 blocks, height = 40 blocks (of which only 20 visible)
;     - The grid is the playing field where the pieces will fall
;     - The main list will be the rows of the grid, each row is a list of blocks
;
; Examples

(define GRID-EXAMPLE (make-vector BLOCKS-IN-HEIGHT (make-vector BLOCKS-IN-WIDTH NFEB)))
(define FULL-ROW-EXAMPLE (make-vector BLOCKS-IN-WIDTH FPB))
(define EMPTY-GRID (make-vector 0 (make-vector 0)))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; WORLD-STATE
; A World-state is a Structure with the followings elements inside:
;      background:   Image that contains the grid, score and all the visual elements
;      grid:         The Grid containing all the blocks. empty or not
;      Score:        The score is a non-negative integer which represents the score of the player
;      should-quit:  Boolean value that represents if the application should quit or not
;      should-spawn: Boolean value that represents if a Piece should be generetated at the top of the grid
;      is-paused:    Boolean value that represents if the game should be paused or not (Show pause menu)
;      falling-blocks: Vector of Posn that represents the position of the falling blocks in the grid
;      game-over:    Boolean value that represents if the player lost (#true) or not (#false)
;      tick:         Number that represents the number of times the function "tick" has been called
;      tick-delay:   Number that represents how many ticks need to happen until the functions inside of the function "tick" are called
;      rotation-index: Number that represents the current rotation of the falling piece (0 = starting point, 1 = left, 2 = up, 3 = right)
;      piece-index:  Number that represents which piece is currently falling:
;                       0 = O-PIECE
;                       1 = L-PIECE
;                       2 = Z-PIECE
;                       3 = T-PIECE
;                       4 = J-PIECE
;                       5 = I-PIECE
;                       6 = S-PIECE
; Header

(define-struct world-state [background grid score should-quit should-spawn is-paused falling-blocks game-over tick tick-delay rotation-index piece-index] #:transparent)

; Examples

(define INITIAL-STATE (make-world-state BACKGROUND GRID-EXAMPLE 0 #false #true #false (make-vector 0) #false 0 10 0 0))
(define EXAMPLE-STATE (make-world-state BACKGROUND GRID-EXAMPLE 100 #false #false #false O-PIECE-POSITIONS #false 0 10 0 0))
(define GAME-OVER-STATE (make-world-state GAME-OVER-PAGE EMPTY-GRID 0 #false #false #false (make-vector 0) #true 0 10 0 0))
(define PAUSED-STATE (make-world-state PAUSE-PAGE EMPTY-GRID 0 #false #false #true (make-vector 0) #false 0 10 0 0))


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
                           (vector (make-posn 1 1) (make-posn 0 0) (make-posn -1 -1) (make-posn -2 0))
                           (vector (make-posn -1 1) (make-posn 0 0) (make-posn 1 -1) (make-posn 0 2))
                           (vector (make-posn 0 -2) (make-posn 1 -1) (make-posn 2 0) (make-posn -1 -1))
                           (vector (make-posn 0 -2) (make-posn 0 1) (make-posn -1 2) (make-posn 0 1)))
                          (vector ; Z-piece
                           (vector (make-posn -1 -1) (make-posn 0 0) (make-posn 1 -1) (make-posn 0 -2))
                           (vector (make-posn -1 1) (make-posn 0 0) (make-posn 1 -1) (make-posn -2 0))
                           (vector (make-posn -1 -2) (make-posn 0 -1) (make-posn -1 0) (make-posn 0 1))
                           (vector (make-posn 1 0) (make-posn 0 1) (make-posn -1 0) (make-posn -2 1)))
                          (vector ; T-piece
                           (vector (make-posn -1 0) (make-posn 1 0) (make-posn 0 -1) (make-posn -1 -2))
                           (vector (make-posn -1 0) (make-posn -1 2) (make-posn 0 1) (make-posn 1 0))
                           (vector (make-posn 1 -1) (make-posn -1 -1) (make-posn 0 0) (make-posn 1 1))
                           (vector (make-posn 1 1) (make-posn 1 -1) (make-posn 0 0) (make-posn -1 1)))
                          (vector ; J-piece
                           (vector (make-posn 1 1) (make-posn 0 0) (make-posn 1 -1) (make-posn 0 -2))
                           (vector (make-posn -2 1) (make-posn -1 0) (make-posn 0 -1) (make-posn 1 0))
                           (vector (make-posn 0 -2) (make-posn 1 -1) (make-posn 2 0) (make-posn 1 1))
                           (vector (make-posn 1 0) (make-posn 0 1) (make-posn -1 0) (make-posn -1 1)))
                          (vector ; I-piece
                           (vector (make-posn 0 0) (make-posn -1 -1) (make-posn -2 -2) (make-posn -3 -3))
                           (vector (make-posn -3 3) (make-posn -2 2) (make-posn -1 1) (make-posn 0 0))
                           (vector (make-posn 0 -3) (make-posn 1 -2) (make-posn 2 -1) (make-posn 3 0))
                           (vector (make-posn 3 0) (make-posn 2 1) (make-posn 1 2) (make-posn 0 3)))
                          (vector ; S-piece
                           (vector (make-posn -1 0) (make-posn -2 -1) (make-posn 1 0) (make-posn 0 -1))
                           (vector (make-posn -1 0) (make-posn 0 -1) (make-posn 1 -2) (make-posn 0 1))
                           (vector (make-posn 1 -1) (make-posn 2 0) (make-posn -1 -1) (make-posn 0 0))
                           (vector (make-posn 1 1) (make-posn 0 2) (make-posn 1 -1) (make-posn 0 0)))
                          ))

;; -------------------------------------------------------------------------------------------------------------------

;; FUNCTIONS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; RANDOM PIECE FUNCTION
;
; Retrive a random piece from the Pieces Vector
; random-piece: Void -> Piece
; (define (random-piece) O-PIECE)
; (define (random-piece)
;  (vector-ref ... (random ...))

(define (random-piece)
  (vector-ref PIECES (random 0 6)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SET-GRID-BLOCK FUNCTION

; takes a Block, a Grid and a Posn and edits the Grid with a Block at the coordinates given as inputs in the Posn
; set-grid-block: Block Grid Posn -> Grid
; (define (set-grid-block FGB CIPPI-GRID (make-posn 3 2) CIPPI-GRID2)
;(define (set-grid-block block grid posn)
;  (set-grid-row grid (... posn)
;                (... (get-grid-row grid (... posn)) (... posn) block)))

(check-expect (set-grid-block FPB GRID-EXAMPLE (make-posn 9 9))
              (shared ((-1- (vector -2- -2- -2- -2- -2- -2- -2- -2- -2- -2-))
                       (-2- (make-block (make-color 30 30 30 255) #false)))
                (vector -1- -1- -1- -1- -1- -1- -1- -1- -1-
                        (vector -2- -2- -2- -2- -2- -2- -2- -2- -2-
                                (make-block (make-color 246 207 250 255) #true)) -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1- -1-)))

(define (set-grid-block block grid posn)
  (set-grid-row grid (posn-y posn)
                (vector-set (get-grid-row grid (posn-y posn)) (posn-x posn) block)))


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

; SET-GRID-ROW FUNCTION

; Takes a Vector, a Number and a Grid. At the position Number of the Grid it inserts the Vector given as input
; set-grid-row: Grid Number Grid -> Grid
; (define (set-grid-row grid y src) )

(define (set-grid-row grid y vect)
  (cond
    [(= y 0) (vector-append (vector vect) (vector-take-right grid (sub1 BLOCKS-IN-HEIGHT)))]
    [(= y (sub1 BLOCKS-IN-HEIGHT)) (vector-append (vector-take grid (sub1 BLOCKS-IN-HEIGHT)) (vector vect))]
    [else (vector-append (vector-take grid y) (vector vect) (vector-take-right grid (- (sub1 BLOCKS-IN-HEIGHT) y)))]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ADD-PIECE-TO-WORLD-STATE FUNCTION

; Receives a World-state and a Piece as inputs and adds the Piece at the top of the Grid
; add-piece-to-world-state: World-state Piece -> World-state
; (define (add-piece-to-world-state world-state piece) INITIAL-STATE)

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

; GET-GRID-BLOCK FUNCTION

; takes a Grid, x and y and returns the block
; get-grid-block: Grid Number Number -> Block
; (define (get-grid-block Grid Number Number) FEB)

(define (get-grid-block grid x y)
  (vector-ref (vector-ref grid y) x))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GET-GRID-ROW FUNCTION

; takes a Grid and a y coordinate and returns a Vector representing the row of the grid
; get-grid-row: Grid Number -> Vector
; (define (get-grid-row Grid Number) (make-vector ..))

(define (get-grid-row grid y)
  (vector-ref grid y))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GET-GRID-COLUMN FUNCTION

; takes a Grid and an x coordinate and returns a Vector representing the column of the Grid
; grid-column; Grid Number -> Vector
; (define (get-grid-columns Grid Number) (make-vector ..))

(define (get-grid-columns grid x)
  (local (
          (define y 0)
          (define (get-grid-column grid x y)
            (if (= y BLOCKS-IN-HEIGHT)
                '()
                (cons (get-grid-block grid x y) (get-grid-column grid x (add1 y))))
            )) (list->vector (get-grid-column grid x y))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCK-TO-IMAGE FUNCTION

; renders a single Block with a black outline
; block-to-image: Block -> Image
; (define (block-to-image block) (rectangle 28 28 "solid" "black")

(define (block-to-image block)
  (overlay (rectangle 28 28 "solid" (block-color block)) (rectangle 30 30 "solid" "black")))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; GRID-ROW-TO-IMAGE FUNCTION

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

; takes a Score and turns it into an Image
; score-to-image: WorldState -> Image
; (define (score-to-image (world-state-score world-state) (rectangle 28 28 "solid" "black"))
;
;
(define (score-to-image world-state)
  (text/font (string-append "SCORE: " (number->string (world-state-score world-state))) 30 SCORE-COLOR #f 'swiss 'normal 'bold #f))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; DRAW FUNCTION

; takes a WorldState and renders the background and the grid
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

; TICK FUNCTION

; takes a World-state and, if flag should-spawn is true adds a Piece to the Grid:
;     - add-piece-to-world-state with a random piece
;     - turns to #false should-spawn
;     - update-falling-blocks with the predefined position of the random piece that was selected
; Every tick increments the world-state tick by 1. After world-state-tick-delay ticks the game advances once.


(define (tick world-state)
  (if (= 0 (world-state-tick world-state))
      world-state
      (update-tick
       (if (= 0 (modulo (world-state-tick world-state) (world-state-tick-delay world-state)))
           (if (or (world-state-is-paused world-state) (world-state-game-over world-state))
               world-state
               (if (world-state-should-spawn world-state)
                   (local (
                           (define (omegaFunction world-state num)
                             (update-falling-blocks (update-should-spawn (add-piece-to-world-state (update-piece-index (update-rotation-index world-state 0) num)
                                                                                                   (vector-ref PIECES num))
                                                                         #false)
                                                    (vector-ref FALLING-BLOCKS-POSITIONS num))))
                     (omegaFunction world-state (random 7)))
                   (if (check-new-posn-offset world-state 0 1)
                       (move-blocks-offset (update-score world-state (+ 1 (world-state-score world-state))) 0 1)
                       (if (world-state-game-over (loser (any-full-rows world-state)))
                           (update-should-spawn (fb-to-nfb (loser (any-full-rows (update-score world-state (+ 1 (world-state-score world-state)))))) #false)
                           (update-should-spawn (fb-to-nfb (loser (any-full-rows (update-score world-state (+ 1 (world-state-score world-state)))))) #true))
                       ))
               )
           world-state)
       (add1 (world-state-tick world-state)))
      )
  )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; FB-TO-NFB
; takes a World-state and returns a World-state where the falling blocks that reach the bottom of the grid
; are turned into non falling blocks
; FB-TO-NFB World-state -> World-state
; (define (fb-to-nfb world-state) CIPPI-WORLD-STATE)

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

; CHECK-NEW-POSN-OFFSET
; Takes a World-state and returns a Boolean in the following way:
; 

(define (check-new-posn-offset world-state x-offset y-offset)
  (local (
          (define FALLING-BLOCKS-TEMP (world-state-falling-blocks world-state))
          (define POSN-LEN (vector-length FALLING-BLOCKS-TEMP))
          (define (check-if-valid x)
            (cond
              [(= x (sub1 POSN-LEN)) (and (< (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) BLOCKS-IN-WIDTH) (>= (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) 0) (< (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) BLOCKS-IN-HEIGHT) (> (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) 0) (can-block-fall? world-state (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset)))]
              [else (and (< (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) BLOCKS-IN-WIDTH) (>= (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) 0) (< (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) BLOCKS-IN-HEIGHT) (> (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset) 0) (can-block-fall? world-state (+ (posn-x (vector-ref FALLING-BLOCKS-TEMP x)) x-offset) (+ (posn-y (vector-ref FALLING-BLOCKS-TEMP x)) y-offset)) (check-if-valid (add1 x)))]
              ))
          ) (check-if-valid 0)))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CHANGE-POSN-IN-WORLD-STATE FUNCTION

; Takes a World-state and returns a World-state where the posn-x and posn-x of the Posns in vector of Posn are shifted by offSet
; change-posn-in-world-state: World-state Number Number -> World-state
; (define (change-posn-in-world-state world-state 0 1) INITIAL-STATE)

(define (change-posn-in-world-state world-state x-offset y-offset)
  (update-falling-blocks world-state
                         (vector-map
                          (lambda (posn) (make-posn (+ (posn-x posn) x-offset) (+ (posn-y posn) y-offset)))
                          (world-state-falling-blocks world-state))))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; move-blocks-to-falling-blocks FUNCTION

; Takes a World-state and returns a World-state with grid updated in the following way:
; the falling blocks in the grid have been moved to the position of falling-blocks
; block-falls-down: World-state -> World-state
; (define (block-falls-down world-state) EXAMPLE-STATE)


(define (move-blocks-to-falling-blocks world-state x-offset y-offset)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))
          (define (block-falls-down-int world-state x)

            (if (or (= 0 (world-state-rotation-index world-state)) (= 3 (world-state-rotation-index world-state)))
            
                (if (< x-offset 0)
                    (cond
                      [(= x 0) (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x))]
                      [else (block-falls-down-int (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x)) (sub1 x))])


                    (cond
                      [(= x (sub1 BLOCKS-LENGTH)) (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x))]
                      [else (block-falls-down-int (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x)) (add1 x))])

                    )

            
                (if (> x-offset 0)
                    (cond
                      [(= x 0) (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x))]
                      [else (block-falls-down-int (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x)) (sub1 x))])


                    (cond
                      [(= x (sub1 BLOCKS-LENGTH)) (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x))]
                      [else (block-falls-down-int (swap-block world-state (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x)) x-offset) (- (posn-y (vector-ref (world-state-falling-blocks world-state) x)) y-offset)) (vector-ref (world-state-falling-blocks world-state) x)) (add1 x))])

                    )
                )
            )
          ) (if (< x-offset 0) (block-falls-down-int world-state 3) (block-falls-down-int world-state 0))))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(define (move-blocks-after-rotation world-state)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))
          (define FALLING-BLOCKS (world-state-falling-blocks world-state))
          (define PIECE-INDEX (world-state-piece-index world-state))
  
          (define (add-blocks world-state x)
            (cond
              [(= x (sub1 BLOCKS-LENGTH))
               (update-grid world-state 
                            (set-grid-block 
                             (cond 
                               [(= PIECE-INDEX 1) FOB]
                               [(= PIECE-INDEX 2) FRB]
                               [(= PIECE-INDEX 3) FPB]
                               [(= PIECE-INDEX 4) FLB]
                               [(= PIECE-INDEX 5) FBB]
                               [(= PIECE-INDEX 6) FGB]
                               ) 
                             (world-state-grid world-state)
                             (vector-ref FALLING-BLOCKS x)
                             ))
               ]
              [else
               (update-grid (add-blocks world-state (add1 x))
                            (set-grid-block 
                             (cond 
                               [(= PIECE-INDEX 1) FOB]
                               [(= PIECE-INDEX 2) FRB]
                               [(= PIECE-INDEX 3) FPB]
                               [(= PIECE-INDEX 4) FLB]
                               [(= PIECE-INDEX 5) FBB]
                               [(= PIECE-INDEX 6) FGB]
                               ) 
                             (world-state-grid world-state)
                             (vector-ref FALLING-BLOCKS x)
                             ))
               ]
              )
            )

          ) (add-blocks (remove-blocks-rotation world-state) 0))
  )


(define (remove-blocks-rotation world-state)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))
          (define FALLING-BLOCKS (world-state-falling-blocks world-state))
  
          (define (remove-blocks world-state x)
            (cond
              [(= x (sub1 BLOCKS-LENGTH))
               (update-grid world-state 
                            (set-grid-block 
                             NFEB 
                             (world-state-grid world-state)
                             (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x))
                                           (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) x)))
                                        (- (posn-y (vector-ref (world-state-falling-blocks world-state) x))
                                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) x))))
                             ))
               ]
              [else
               (update-grid (remove-blocks world-state (add1 x))
                            (set-grid-block 
                             NFEB 
                             (world-state-grid world-state) 
                             (make-posn (- (posn-x (vector-ref (world-state-falling-blocks world-state) x))
                                           (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) x)))
                                        (- (posn-y (vector-ref (world-state-falling-blocks world-state) x))
                                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (world-state-rotation-index world-state)) x))))
                             ))
               ]
              )
            )

          ) (remove-blocks world-state 0))
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-BLOCKS-OFFSET
(define (move-blocks-offset world-state x-offset y-offset)
  (move-blocks-to-falling-blocks (change-posn-in-world-state world-state x-offset y-offset) x-offset y-offset))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


; SWAP-BLOCK FUNCTION

; Takes a World-state and a Posn and returns a World-state in which the grid's block
; at Posn-src coordinates is swapped with the block in the other coordinates
; swap-block: World-state Posn Posn -> World-state
; (define (swap-block world-state posn-src posn-dst) EXAMPLE-STATE)

(define (swap-block world-state posn-src posn-dst)
  (local (
          (define SRC-BLOCK (get-grid-block (world-state-grid world-state) (posn-x posn-src) (posn-y posn-src)))
          (define DST-BLOCK (get-grid-block (world-state-grid world-state) (posn-x posn-dst) (posn-y posn-dst)))
          (define (swap)
            (update-grid
             world-state
             (set-grid-block DST-BLOCK (world-state-grid (update-grid world-state (set-grid-block SRC-BLOCK (world-state-grid world-state) posn-dst))) posn-src) ; Block Grid Posn
             ))
          ) (swap))
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; AUXILIARY FUNCTIONS TO UPDATE WORLD-STATE DATA

; All the functions take a World-state and a value return a World-state
; The element of the world-state the function is named after is updated with the value given as input.
; Value can be: Boolean, Number, Vector<Posn> (vopsn) or Vector<Vector<Block>>(vovob)
; update-xx: World-state
; (define (update-score 100) (make-world-state BACKGROUND GRID-EXAMPLE 100 #false #false #false #false))

; UPDATE-SCORE
(define (update-score world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) number
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-SHOULD-QUIT
(define (update-should-quit world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    boolean (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-SHOULD-SPAWN
(define (update-should-spawn world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) boolean (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-IS-PAUSED
(define (update-is-paused world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) boolean
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-FALLING-BLOCKS
(define (update-falling-blocks world-state vopsn)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    vopsn (world-state-game-over world-state) (world-state-tick world-state) (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-GRID
(define (update-grid world-state vovob)
  (make-world-state (world-state-background world-state) vovob (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-GAME-OVER
(define (update-game-over world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) boolean (world-state-tick world-state) (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-TICK
(define (update-tick world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) number (world-state-tick-delay world-state)
                    (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-TICK-DELAY
(define (update-tick-delay world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state) number
                    (world-state-rotation-index world-state) (world-state-piece-index world-state)))

; UPDATE-ROTATION-INDEX
(define (update-rotation-index world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) number (world-state-piece-index world-state)))

; UPDATE-PIECE-INDEX
(define (update-piece-index world-state number)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state) (world-state-game-over world-state) (world-state-tick world-state)
                    (world-state-tick-delay world-state) (world-state-rotation-index world-state) number))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CAN-BLOCK-FALL? FUNCTION

; takes a World-state, x and y coordinates and returns true if the Block (add1 y)
; at the coordinates x y in the Grid can fall
; can-block-fall?: World-state Number Number -> Boolean
; (define (can-block-fall? World-state x y) #true)
;

(define (can-block-fall? world-state x y)
  (cond
    [(and (not (block-is-falling (get-grid-block (world-state-grid world-state) x y)))
          (not (is-block-empty? (get-grid-block (world-state-grid world-state) x y)))) #false]
    [else #true]))

; AUX IS-BLOCK-EMPTY?

(define (is-block-empty? block)
  (equal? (block-color block) EMPTY-COLOR))

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
; if there aren't any full rows, returns the World-state given as input
; any-full-rows: World-state -> World-state
; (define (any-full-rows world-state) CIPPI-WORLD-STATE)

(define (any-full-rows world-state)
  (cond
    [(boolean? (row-full world-state)) world-state]
    [else (any-full-rows (push-down-rows world-state (row-full world-state)))]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; LOSER FUNCTION

; takes a World-state and checks if the 4th row has Blocks whose color is not EMPTY-COLOR
; if true: returns World-state with game-over turned to #true, should-spawn turned to #false
; loser: World-state -> World-state
; (define (loser world-state) EXAMPLE-STATE)
; (define (loser world-state)
; (if
; (... (get-grid-row (world-state-grid world-state) ... )
; (update-game-over world-state #true)
; world-state))

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

; IF-GAME-OVER-DONT-SPAWN

; takes a World-state and checks if the user lost, if they did
; it returns a World-state with the should-spawn flag changed to #false
; if-game-over-dont-spawn: World-state -> World-state
; (define (if-game-over-dont-spawn) CIPPI-WORLD-STATE)
; (define (if-game-over-dont-spawn)
;    (if
;     (world-state-game-over)... (update-should-spawn) world-state))

(define (if-game-over-dont-spawn world-state)
  (if (world-state-game-over world-state)
      (update-should-spawn world-state #false)
      world-state))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-X
(define (move-x world-state direction) ;1 right, -1 left
  (if (check-new-posn-offset world-state direction 0)
      (move-blocks-offset world-state direction 0)
      world-state)
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

(define (handle-key world-state key)
  (cond
    [(key=? key "left") (move-x world-state -1)]
    [(key=? key "right") (move-x world-state 1)]
    [(key=? key "down") (update-tick-delay world-state 1)]
    [(key=? key "up") (if (or (= 0 (world-state-piece-index world-state)) (world-state-game-over world-state) (world-state-is-paused world-state)) world-state (rotate-cw world-state))]
    ;[(key=? key "z") (rotate-back world-state)]
    ;[(key=? key "h") (hard-drop world-state)]
    [(key=? key "r") (if (or (world-state-game-over world-state) (world-state-is-paused world-state)) (update-tick INITIAL-STATE (world-state-tick-delay INITIAL-STATE)) world-state)]
    [(key=? key "escape") (if (world-state-game-over world-state) world-state (update-is-paused world-state (not (world-state-is-paused world-state))))]
    [(key=? key "q") (update-should-quit world-state #true)]
    [(key=? key " ") (if (= 0 (world-state-tick world-state)) (update-tick world-state (world-state-tick-delay world-state)) world-state)]
    [else world-state]
    ))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATE-FRONT FUNCTION
; Takes a world-state and returns the same world-state, but the falling blocks are rotated clock-wise
; rotate-cw : World-state -> World-state
; (define (rotate-cw world-state) INITIAL-STATE)

(define (rotate-cw world-state)
  (if (can-blocks-rotate? world-state)
      ; can rotate
      (move-blocks-after-rotation (update-rotation-index (update-falling-blocks world-state
                                                                                (vector
                                                                                 (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
                                                                                               (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
                                                                                            (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
                                                                                               (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0))))
                                                                                 (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
                                                                                               (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
                                                                                            (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
                                                                                               (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1))))
                                                                                 (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
                                                                                               (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
                                                                                            (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
                                                                                               (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2))))
                                                                                 (make-posn (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
                                                                                               (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
                                                                                            (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
                                                                                               (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3))))
                                                                                 )
                                                                                ) (if (< (world-state-rotation-index world-state) 3) (add1 (world-state-rotation-index world-state)) 0)))

      ; can-t rotate
      world-state
      )

  )



(define (can-blocks-rotate? world-state)
  (if (and 

       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
           0
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
          BLOCKS-IN-HEIGHT
          )
          

       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
           0
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
          BLOCKS-IN-HEIGHT
          )

          
       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
           0
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
          BLOCKS-IN-HEIGHT
          )
                                           


       (>= (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
              (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
           0
           )
       (< (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
             (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
          BLOCKS-IN-WIDTH
          )
       (>= (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
              (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
           0
           )
       (< (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
             (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
          BLOCKS-IN-HEIGHT
          )                              
                                           
                                           
                                           
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 0))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 0)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 0))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 0) 0))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 1))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 1)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 1))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 1) 1))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 2))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 2)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 2))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) 2) 2))))
       (can-block-fall? world-state (+ (posn-x (vector-ref (world-state-falling-blocks world-state) 3))
                                       (posn-x (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3)))
                        (+ (posn-y (vector-ref (world-state-falling-blocks world-state) 3))
                           (posn-y (vector-ref (vector-ref (vector-ref ROTATION-OFFSETS (sub1 (world-state-piece-index world-state))) (add1 (world-state-rotation-index world-state))) 3))))

       )
      ; can rotate
      #true

      ; can-t rotate
      #false
      )
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATE-BACK FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; HARD-DROP FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; HANDLE-RELEASE
; takes a World-state and a String and returns the world-state with the tick-delay updated to 1
; handle-release: World-state String -> World-state
; (define (handle-release world-state key) CIPPI-WORLD-STATE)

(define (handle-release world-state key)
  (if (equal? key "down") (update-tick-delay world-state 10) world-state))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; QUIT? FUNCTION
(define (quit? world-state)
  (world-state-should-quit world-state))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BIG-BANG

(define (tetris initial-state)
  (big-bang initial-state
    [on-tick tick]
    [to-draw draw]
    [on-key handle-key]
    [on-release handle-release]
    [stop-when quit?]
    [close-on-stop #true]
    ))

(define (run funct arg) (if (funct arg) (display "Bye bye!\n") (display "Bye bye!\n")))
(tetris INITIAL-STATE)
;(run tetris INITIAL-STATE)

;;; TO DO:

;;; * handle-key:
;;;   rotate
;;; * la situa dello score
;;; * fare template e check-expect


;;; * README
;;; * user guide - almost done
;;; * developer guide