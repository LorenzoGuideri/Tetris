#lang htdp/asl

(require 2htdp/universe)
(require 2htdp/image)
(require racket/vector)
(require racket/base)

;; --------------------------------------------------------------------------

;; CONSTANTS

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCK COLORS

(define EMPTY-COLOR (make-color 64 64 64))
(define YELLOW (make-color 242 240 184))
(define ORANGE (make-color 253 207 179))
(define RED (make-color 244 113 116))
(define PINK (make-color 246 207 250))
(define LILAC (make-color 176 189 245))
(define BLUE (make-color 196 237 245))
(define GREEN (make-color 200 224 152))

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
 "middle" "middle" (text/font "press 'r' to restart" 30 "Light Turquoise" #f 'swiss 'normal 'bold #f)
 +15 -50
 (overlay/align/offset 
 "middle" "middle" 
  (text/font "GAME OVER" 60 "Light Red" #f 'swiss 'normal 'bold #f)
  +15 100
  BACKGROUND)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; PAUSE-PAGE

(define PAUSE-PAGE
(overlay/align/offset
 "middle" "middle" (text/font "press 'r' to restart" 30 "Light Turquoise" #f 'swiss 'normal 'bold #f)
 +15 -50
 (overlay/align/offset 
 "middle" "middle" 
  (text/font "GAME IS PAUSED" 50 "Light Blue" #f 'swiss 'normal 'bold #f)
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

(define O-PIECE-POSITIONS (vector (make-posn 4 1) (make-posn 5 1) (make-posn 4 0) (make-posn 5 0)))
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
;
; Header

(define-struct world-state [background grid score should-quit should-spawn is-paused falling-blocks game-over] #:transparent)
;
; Examples

(define INITIAL-STATE (make-world-state BACKGROUND GRID-EXAMPLE 0 #false #true #false (make-vector 0) #false))
(define EXAMPLE-STATE (make-world-state BACKGROUND GRID-EXAMPLE 100 #false #false #false O-PIECE-POSITIONS #false))
(define GAME-OVER-STATE (make-world-state GAME-OVER-PAGE EMPTY-GRID 0 #false #false #false (make-vector 0) #true))
(define PAUSED-STATE (make-world-state PAUSE-PAGE EMPTY-GRID 0 #false #false #true (make-vector 0) #false))

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


(define (set-grid-block block grid posn)
  (set-grid-row grid (posn-y posn)
                (vector-set (get-grid-row grid (posn-y posn)) (posn-x posn) block)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; VECTOR-SET

; takes a vector, a position (Number) and a value (Number) and returns a Vector with the new value at the indicated position
; vector-set: Vector Number Number -> Vector
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
    [(= y (sub1 BLOCKS-IN-HEIGHT)) (vector-append (vector-take grid (sub1 BLOCKS-IN-HEIGHT)) vect)]
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
  (text/font (string-append "SCORE: " (number->string (world-state-score world-state))) 30 "deep pink"
             #f 'swiss 'normal 'bold #f))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; DRAW FUNCTION

; takes a WorldState and renders the background and the grid if the 
; draw: WorldState -> Image
; (define (draw world-state) (rectangle 28 28 "solid" "black"))

; * if game over is true: render game over page

(define (draw world-state)
  (cond 
  [(world-state-game-over world-state) GAME-OVER-PAGE]
  [(world-state-is-paused world-state) PAUSE-PAGE]
  [else (overlay/offset (score-to-image world-state) 0 -350
                  (overlay (grid-to-image (world-state-grid world-state))
                           (rectangle 302 602 "solid" "black")
                           (world-state-background world-state)))]))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; TICK FUNCTION

; takes a World-state and, if flag should-spawn is true adds a Piece to the Grid:
;     - add-piece-to-world-state with a random piece
;     - turns to #false should-spawn
;     - update-falling-blocks with the predefined position of the random piece that was selected


(define (tick world-state)
  (if (world-state-should-spawn world-state)
      (local (
              (define (omegaFunction world-state num)
                (update-falling-blocks (update-should-spawn (add-piece-to-world-state world-state
                                                                                      (vector-ref PIECES num))
                                                            #false)
                                       (vector-ref FALLING-BLOCKS-POSITIONS num))))
        (omegaFunction world-state (random 0 6)))
      (update-score (block-falls-down (change-posn-y-in-world-state world-state)) (add1 (world-state-score world-state)))
      )
  ;(update-score world-state (add1 (world-state-score world-state)))
  ;(if (not (= (vector-length (world-state-falling-blocks world-state)) 0)) (vector-ref (world-state-falling-blocks world-state) 0) world-state)
  )

; 1. metto il pezzo nel world-state
; 2. lo passo ad update-should-spawn che mi mette #false in should-spawn,
; 3. questo nuovo world-state lo passo ad update-falling-blocks insieme al vettore di posn che contiene
;   le posizioni che il pezzo ha assunto nel mentre cadeva durante tutta la durata del gioco
;   (questa posizione la recupero dal vettore di vettori di posn che si chiama FALLING-BLOCKS-POSITIONS
;    grazie al numero che io gli ho dato
;         (che rappresenta il blocco casuale che ho scelto nella main function))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CHANGE-POSN-Y-IN-WORLD-STATE FUNCTION

; Takes a World-state and returns a World-state where the posn-y of the Posns in vector of Posn is shifted down by one
; change-posn-y-in-world-state: World-state -> World-state
; (define (change-posn-y-in-world-state world-state) INITIAL-STATE)

(define (change-posn-y-in-world-state world-state)
  (update-falling-blocks world-state
                         (vector-map
                          (lambda (posn) (make-posn (posn-x posn) (add1 (posn-y posn))))
                          (world-state-falling-blocks world-state))))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCK-FALLS-DOWN FUNCTION

; Takes a World-state and returns a World-state with grid updated in the following way:
; the falling blocks in the grid have been moved to the position of falling-blocks
; block-falls-down: World-state -> World-state
; (define (block-falls-down world-state) EXAMPLE-STATE)


(define (block-falls-down world-state)
  (local (
          (define BLOCKS-LENGTH (vector-length (world-state-falling-blocks world-state)))
          (define (block-falls-down-int world-state x)
            (cond
              [(= x (sub1 BLOCKS-LENGTH)) (swap-block world-state (make-posn (posn-x (vector-ref (world-state-falling-blocks world-state) x)) (sub1 (posn-y (vector-ref (world-state-falling-blocks world-state) x)))) (vector-ref (world-state-falling-blocks world-state) x))]
              [else (block-falls-down-int (swap-block world-state (make-posn (posn-x (vector-ref (world-state-falling-blocks world-state) x)) (sub1 (posn-y (vector-ref (world-state-falling-blocks world-state) x)))) (vector-ref (world-state-falling-blocks world-state) x)) (add1 x))]))
          ) (block-falls-down-int world-state 0)))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; SWAP FUNCTION

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
             (set-grid-block DST-BLOCK (world-state-grid (update-grid world-state (set-grid-block SRC-BLOCK (world-state-grid world-state) posnDst))) posnSrc) ; Block Grid Posn
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
                    (world-state-falling-blocks world-state) (world-state-game-over world-state)))

; UPDATE-SHOULD-QUIT

(define (update-should-quit world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    boolean (world-state-should-spawn world-state) (world-state-is-paused world-state) (world-state-falling-blocks world-state) (world-state-game-over world-state)))

; UPDATE-SHOULD-SPAWN

(define (update-should-spawn world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) boolean (world-state-is-paused world-state) (world-state-falling-blocks world-state) (world-state-game-over world-state)))

; UPDATE-IS-PAUSED

(define (update-is-paused world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) boolean (world-state-falling-blocks world-state) (world-state-game-over world-state)))

; UPDATE-FALLING-BLOCKS

(define (update-falling-blocks world-state vopsn)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state) vector-of-posn (world-state-game-over world-state)))

; UPDATE-GRID

(define (update-grid world-state vovob)
  (make-world-state (world-state-background world-state) vovob (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state) (world-state-falling-blocks world-state) (world-state-game-over world-state)))

; UPDATE-GAME-OVER

(define (update-game-over world-state boolean)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state) (world-state-falling-blocks world-state) boolean))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CAN-BLOCK-FALL? FUNCTION

; takes a World-state, x and y coordinates and returns true if the Block (add1 y) at the coordinates x y in the Grid can fall
; can-block-fall?: World-state Number Number -> Boolean
; (define (can-block-fall? World-state x y) #true)
;

(define (can-block-fall? world-state x y)
  (cond
    [(not (< (+ y 1) BLOCKS-IN-HEIGHT)) #false]
    [(and (not (block-is-falling (get-grid-block (world-state-grid world-state) x (add1 y))))
          (not (is-block-empty? (get-grid-block (world-state-grid world-state) x (add1 y))))) #false]
    [else #true]))

; AUX IS-BLOCK-EMPTY?

(define (is-block-empty? block)
  (equal? (block-color block) EMPTY-COLOR))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROW-FULL FUNCTION

; takes a World-state and determines if there are any full rows (if there is a row where all the blocks have a color
; that is not EMPTY-COLOR), it returns World-state with the Grid updated in the following way:
; if any row was full, it's removed and all the rows above pushed down by 1
; row-full: World-state -> Number
; (define (row-full world-state) EXAMPLE-STATE)


(define CIPPI (set-grid-row (world-state-grid EXAMPLE-STATE) 17 FULL-ROW-EXAMPLE))
(define CIPPI-WORLD-STATE (update-grid EXAMPLE-STATE CIPPI))

; (check-expect (row-full CIPPI-WORLD-STATE) (make-world-state BACKGROUND ...))

(define (row-full world-state)

  (local
    ((define y (sub1 BLOCKS-IN-HEIGHT))

     (define (row-full-int world-state y)

       (cond
         [(vector-member
           NFEB (get-grid-row (world-state-grid world-state) y))
          (row-full-int world-state (sub1 y))]

         [else
          (update-grid world-state (set-grid-row
                                    (world-state-grid world-state)
                                    y
                                    (get-grid-row (world-state-grid world-state)
                                                  (sub1 y))))])))
    (row-full-int world-state y)))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; LOSER FUNCTION

; takes a World-state and checks if the 21st row has Blocks whose color is not EMPTY-COLOR
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
                                  (get-grid-row (world-state-grid world-state) (sub1 BLOCKS-IN-HEIGHT)))) 
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

; HANDLE-KEY FUNCTION

; takes a World-state and a key-event and returns an updated World-state in the following way:
; if key-event is left, moves non-empty FALLING blocks that are in grid to the left
; if key-event is right, moves non-empty FALLING blocks that are in grid to the right
; if key-event is down, moves non-empty FALLING blocks that are in grid faster down 
; if key-event is up, rotates FALLING PIECE clock-wise

(define (handle-key world-state key)
(cond
[(key=? key "left") (move-left world-state)]
[(key=? key "right") (move-right world-state)]
;[(key=? key "down") (move-down world-state)]
;[(key=? key "up") (rotate-front world-state)]
;[(key=? key "z") (rotate-back world-state)]
;[(key=? key "h") (hard-drop world-state)]
[(key=? key "r") (tetris INITIAL-STATE)]
[(key=? key "escape") (tetris PAUSED-STATE)]
[(key=? key "q") (update-should-quit world-state #true)]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-RIGHT FUNCTION

; takes a World-state and returns a World-state where blocks in grid are moved to the right by 1
; move-right: World-state -> World-state
; (define (move-right world-state) CIPPI-WORLD-STATE)

(define (move-right world-state)
(swap world-state 
      (vector-ref falling-blocks 0) 
      (make-posn (add1 (posn-x (vector-ref falling-block-0))) 
                 (posn-y (vector-ref falling-block-0)))))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-LEFT FUNCTION

; takes a World-state and returns a World-state where blocks in grid are moved to the right by 1
; move-leftt: World-state -> World-state
; (define (move-right world-state) CIPPI-WORLD-STATE)

(define (move-left world-state)
(swap world-state 
      (vector-ref falling-blocks 0) 
      (make-posn (sub1 (posn-x (vector-ref falling-block-0))) 
                 (posn-y (vector-ref falling-block-0)))))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; MOVE-DOWN FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATE-FRONT FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ROTATE-BACK FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; HARD-DROP FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; QUIT? FUNCTION

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BIG-BANG

(define (tetris initial-state)
  (big-bang initial-state
    [to-draw draw]
    [on-tick tick]
    [on-key handle-key]
    ;[stop-when quit?]
    ))



;;; TO DO:

;;; * stop-falling
;;; * i pezzi si impilano
;;; * handle-key: 
;;;   (move-down) freccia giu va giu veloce
;;;   (rotate) freccia su ruota in senso orario
;;; * aggiungere il tick interno al worldstate
;;; * fare template e check-expect


;;; * README
;;; * user guide
;;; * developer guide