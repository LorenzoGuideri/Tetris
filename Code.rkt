;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Code) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)
(require racket/vector)
(require racket/base)

;; CONSTANTS

; BLOCK COLORS
(define EMPTY-COLOR (color 64 64 64))
(define YELLOW (make-color 242 240 184))
(define ORANGE (make-color 253 207 179))
(define RED (make-color 244 113 116))
(define PINK (make-color 246 207 250))
(define LILAC (make-color 176 189 245))
(define BLUE (make-color 196 237 245))
(define GREEN (make-color 200 224 152))

(define COLORS (vector YELLOW ORANGE RED PINK LILAC BLUE GREEN)) 


; BACKGROUND
(define WIDTH-BG 560)
(define HEIGHT-BG 800)
(define BACKGROUND (rectangle WIDTH-BG HEIGHT-BG "solid" EMPTY-COLOR))


; BLOCKS IN GRID
(define BLOCKS-IN-WIDTH 10)
(define BLOCKS-IN-HEIGHT 40)



;; DATA TYPES

; a Block is a Structure (make-block color position is-falling)
; where:
;       - color is one of predefined BLOCK COLORS
;
;       - position is a Posn (make-posn Number Number)
;                - it contains the position of the block in the grid 
;
;       - is-falling is a Boolean containing the position of the block in the grid
;                - #true when the block is falling
;                - #false when the block is not falling
;
(define-struct block [color position is-falling])
;
; Examples
;
(define FEB (make-block EMPTY-COLOR (make-posn 0 0) #true)) ; Falling Empty Block
(define FYB (make-block YELLOW (make-posn 1 1) #true)) ; Falling Yellow Bloc
(define FOB (make-block ORANGE (make-posn 1 1) #true)) ; Falling Orange Block
(define FRB (make-block RED (make-posn 1 1) #true)) ; Falling Red Block
(define FPB (make-block PINK (make-posn 1 1) #true)) ; Falling Pink Block
(define FLB (make-block LILAC (make-posn 1 1) #true)) ; Falling Lilac Block
(define FBB (make-block BLUE (make-posn 1 1) #true)) ; Falling Blue Block
(define FGB (make-block GREEN (make-posn 1 1) #true)) ; Falling Green Block

(define NFEB (make-block #false (make-posn 9 8) #false)) ;Non-Falling Empty Block
(define NFLB (make-block LILAC (make-posn 3 4) #false)) ;Non-Falling Lilac Block


; a Piece is a Vector<Vector<Block>> where both vectors have size 4 (make-vector 4 (make-vector 4 Block))
;        - A piece is the combination of various blocks to form the well known tetromin
;        - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece
;        - The pieces are predefined
;
; PREDEFINED PIECES
;
(define O-PIECE (vector (vector 4 NFEB) (vector NFEB FYB FYB NFEB) (vector NFEB FYB FYB NFEB) (vector 4 NFEB)))
(define L-PIECE (vector (vector FOB NFEB NFEB NFEB) (vector FOB NFEB NFEB NFEB) (vector FOB NFEB NFEB NFEB) (vector FOB FOB NFEB NFEB)))
(define Z-PIECE (vector (vector 4 NFEB) (vector NFEB FRB FRB NFEB) (vector NFEB NFEB FRB FRB) (vector 4 NFEB)))
(define T-PIECE (vector (vector FPB FPB FPB NFEB) (vector NFEB FPB NFEB NFEB) (vector 4 NFEB) (vector 4 NFEB)))
(define J-PIECE (vector (vector NFEB NFEB NFEB FLB) (vector NFEB NFEB NFEB FLB) (vector NFEB NFEB NFEB FLB) (vector NFEB NFEB FLB FLB)))
(define I-PIECE (vector (vector 4 FBB) (vector 4 NFEB) (vector 4 NFEB) (vector 4 NFEB)))
(define S-PIECE (vector (vector 4 NFEB) (vector NFEB FGB FGB NFEB) (vector FGB FGB NFEB NFEB) (vector 4 NFEB)))
;
; PIECES-VECTOR
(define PIECES (vector O-PIECE L-PIECE Z-PIECE T-PIECE J-PIECE I-PIECE S-PIECE))



; a Score is a Natural
;        - It represents the number of lines completed by the user (1 line = 100 points)
;        - If the user completes more then one line at the same time,
;          the score will be increased by a special factor (All the way up to 4 lines at the same time)



; a Grid is a Vector<Vector<Block>> (make-vector 10 (make-vector 40 Block))
;     - It represent a grid of width = 10 blocks, height = 40 blocks (of which only 20 visible) ;(come lo facciamo? boh)
;     - The grid is the playing field where the pieces will fall
;     - The main list will be the rows of the grid, each row is a list of blocks
;
; Examples
;
(define GRID-EXAMPLE (make-vector BLOCKS-IN-WIDTH (make-vector BLOCKS-IN-HEIGHT FEB)))



; WORLD-STATE
; A world-state is a Structure with the followings elements inside:
;      background:   Image that contains the grid, score and all the visual elements
;      grid:         The Grid containing all the blocks. empty or not
;      score:        The score is a non-negative integer which represents the score of the player
;      should-quit:  Boolean value that represents if the application should quit or not
;      should-spawn: Boolean value that represents if a Piece should be generetated at the top of the grid
;      is-paused:    Boolean value that represents if the game should be paused or not (Show pause menu)
;
; Header 
(define-struct world-state [background grid score should-quit should-spawn is-paused])
;
; Examples of data
(define INITIAL-STATE (make-world-state BACKGROUND GRID-EXAMPLE 0 #false #false #false))



;; FUNCTIONS

; SET-GRID-BLOCK FUNCTION
; takes a Block a Grid and x y coordinates and edith the Grid with a Block at the coordinates given as inputs
; set-grid-block: Block Grid Number Number -> Void

(define (set-grid-block grid x y block)
  (vector-set! (vector-ref grid y) x block))



; BLOCK-TO-IMAGE FUNCTION
; renders a single block with a black outline

(define (block-to-image block)
  (overlay (rectangle 28 28 "solid" (block-color block)) (rectangle 30 30 "solid" "black")))



; GRID-ROW FUNCTION
; takes a grid and a y coordinate and returns a vector representing the row of the grid

(define (grid-row grid y)
  (vector-ref grid y))


; GRID-BLOCK FUNCTION
; takes a grid and x and y and returns the block

(define (grid-block grid x y)
  (vector-ref (vector-ref grid x) y))



; GRID-COLUMN FUNCTION
; takes a grid and an x coordinate and returns a vector representing the column of the grid

(define (grid-column grid x)
  (local (
          (define y 0)
          (define (get-grid-column grid x y)
            (if (= y BLOCKS-IN-HEIGHT)
                '()
                (cons (grid-block grid x y) (get-grid-column grid x (add1 y))))
            )) (list->vector (get-grid-column grid x y))))



; GRID-TO-IMAGE FUNCTION
; Renders the grid in the world state as an Image
; Grid-to-image: Vector<Vector<Block>> -> Image
;
;(define (grid-to-image grid x y temp-image)
;  (... (vector-ref x (vector-ref y grid)) ...))



; RANDOM-PIECE FUNCTION
; Retrive a random piece from the Pieces Vector
; random-piece: Void -> Piece
; Header
;(define random-piece O-PIECE)
;
; Code
(define (random-piece)
  (vector-ref PIECES (random 0 6)))


; ADD-PIECE-TO-GRID FUNCTION
; Recevies a Grid and a Piece as inputs and returns the Grid with the Piece at the top in the middle
; add-piece-to-grid: Grid Piece -> Grid
; (define (add-piece-to-grid grid piece) grid)

(define (add-piece-to-grid grid piece)
  (vector-copy! grid (- (/ BLOCKS-IN-WIDTH 2) 2) piece)) 



; DRAW FUNCTION 
(define (draw world-state)
  (overlay/offset (beside (overlay (rectangle 28 28 "solid" PINK) (rectangle 30 30 "solid" "black"))
                          (overlay (rectangle 28 28 "solid" BLUE) (rectangle 30 30 "solid" "black")))
                  15 0 (world-state-background world-state)))



; TICK FUNCTION



; HANDLE-KEY FUNCTION



; QUIT? FUNCTION

; BIG-BANG
;
(define (tetris initial-state)
  (big-bang initial-state
    [to-draw draw]
    ;[on-tick tick]
    ;[on-mouse handle-mouse]
    ;[on-key handle-key]
    ;[stop-when quit?]
    ))



