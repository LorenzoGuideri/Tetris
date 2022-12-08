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
(define NFLB (make-block LILAC #false)) ;Non-Falling Lilac Block

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; a Piece is a Vector<Vector<Block>> where there the first Vector contains 4 Vectors of 10 Blocks each
;        - A piece is the combination of various blocks to form the well known tetromin
;        - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece
;        - The pieces are predefined

; PREDEFINED PIECES

(define O-PIECE (vector (make-vector 10 NFEB) (vector NFEB NFEB NFEB NFEB FYB FYB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FYB FYB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB)))
(define L-PIECE (vector (vector NFEB NFEB NFEB NFEB NFEB NFEB FOB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FOB FOB FOB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define Z-PIECE (vector (make-vector 10 NFEB) (vector NFEB NFEB NFEB NFEB FRB FRB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB NFEB FRB FRB NFEB NFEB NFEB) (make-vector 10 NFEB)))
(define T-PIECE (vector (vector NFEB NFEB NFEB FPB FPB FPB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FPB NFEB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define J-PIECE (vector (vector NFEB NFEB NFEB NFEB FLB NFEB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB NFEB FLB FLB FLB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define I-PIECE (vector (vector NFEB NFEB NFEB FBB FBB FBB FBB NFEB NFEB NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB) (make-vector 10 NFEB)))
(define S-PIECE (vector (make-vector 10 NFEB) (vector NFEB NFEB NFEB NFEB FGB FGB NFEB NFEB NFEB NFEB) (vector NFEB NFEB NFEB FGB FGB NFEB NFEB NFEB NFEB NFEB) (make-vector 10 NFEB)))


; PREDEFINED FALLING-BLOCKS-POSITIONS

(define O-PIECE-POSITIONS (vector (make-posn 5 2) (make-posn 4 2) (make-posn 5 1) (make-posn 4 1)))
(define L-PIECE-POSITIONS (vector (make-posn 6 1) (make-posn 5 1) (make-posn 4 1) (make-posn 6 0)))
(define Z-PIECE-POSITIONS (vector (make-posn 6 2) (make-posn 5 2) (make-posn 5 1) (make-posn 4 1)))
(define T-PIECE-POSITIONS (vector (make-posn 4 1) (make-posn 5 0) (make-posn 4 0) (make-posn 3 0)))
(define J-PIECE-POSITIONS (vector (make-posn 6 1) (make-posn 5 1) (make-posn 4 1) (make-posn 4 0)))
(define I-PIECE-POSITIONS (vector (make-posn 6 0) (make-posn 5 0) (make-posn 4 0) (make-posn 3 0)))
(define S-PIECE-POSITIONS (vector (make-posn 4 2) (make-posn 3 2) (make-posn 5 1) (make-posn 4 1)))


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
;
; Header

(define-struct world-state [background grid score should-quit should-spawn is-paused falling-blocks] #:transparent)
;
; Examples

(define INITIAL-STATE (make-world-state BACKGROUND GRID-EXAMPLE 0 #false #true #false (make-vector 0)))
(define EXAMPLE-STATE (make-world-state BACKGROUND GRID-EXAMPLE 100 #false #false #false O-PIECE-POSITIONS))

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
    [(= y (sub1 BLOCKS-IN-HEIGHT)) (vector-append (vector-take (sub1 BLOCKS-IN-HEIGHT)) vect)]
    [else (vector-append (vector-take grid y) (vector vect) (vector-take-right grid (- (sub1 BLOCKS-IN-HEIGHT) y)))]))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; ADD-PIECE-TO-WORLD-STATE FUNCTION V.2
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
; takes a WorldState and renders the background and the grid
; draw: WorldState -> Image
; (define (draw world-state) (rectangle 28 28 "solid" "black"))

(define (draw world-state)
  (overlay/offset (score-to-image world-state) 0 -350
                  (overlay (grid-to-image (world-state-grid world-state))
                           (rectangle 302 602 "solid" "black")
                           (world-state-background world-state))))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; TICK FUNCTION
; takes a World-state and, if flag should-spawn is true adds a Piece to the Grid:
;     - add-piece-to-world-state with a random piece
;     - turns to #false should-spawn
;     - update-falling-blocks with the predefined position of the random piece that was selected


(define (tick world-state)
  ;world-state
  (if (world-state-should-spawn world-state)
      (local (
              (define (omegaFunction world-state num)
                (update-falling-blocks (update-should-spawn (add-piece-to-world-state world-state
                                                                                      (vector-ref PIECES num)) ; perché nn usiamo random-piece?
                                                            #false)
                                       (vector-ref FALLING-BLOCKS-POSITIONS num))))
        (omegaFunction world-state (random 0 6)))
      world-state
      ))

; 1. metto il pezzo nel world-state
; 2. lo passo ad update-should-spawn che mi mette #false in should-spawn,
; 3. questo nuovo world-state lo passo ad update-falling-blocks insieme al vettore di posn che contiene
;   le posizioni che il pezzo ha assunto nel mentre cadeva durante tutta la durata del gioco
;   (questa posizione la recupero dal vettore di vettori di posn che si chiama FALLING-BLOCKS-POSITIONS
;    grazie al numero che io gli ho dato
;         (che rappresenta il blocco casuale che ho scelto nella main function))

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; CHANGE-POSN-IN-WORLD-STATE FUNCTION
; Takes a World-state and returns a World-state where the posn-y of the Posns in vector of Posn is shifted down by one
; change-posn-in-world-state: World-state -> World-state
; (define (change-posn-in-world-state world-state) INITIAL-STATE)

(define (change-posn-in-world-state world-state)
  (vector-map
   (lambda (posn) (make-posn (posn-x posn) (add1 (posn-y posn))))
   (world-state-falling-blocks world-state)))


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BLOCK-FALLS-DOWN FUNCTION
; Takes a World-state and returns a World-state with grid updated in the following way:
; the falling blocks in the grid have been moved down by one
; block-falls-down: World-state -> World-state
; (define (block-falls-down world-state) EXAMPLE-STATE)


(define (block-falls-down world-state)
  (local (
          (define BLOCKS-LENGHT (vector-length (world-state-falling-blocks world-state)))
          (define (block-falls-down-int world-state x)
            (cond
              [(= x (sub1 BLOCKS-LENGHT) (swap-block world-state (vector-ref (world-state-falling-blocks world-state) x)))]
              [else (block-falls-down-int (swap-block world-state (vector-ref (world-state-falling-blocks world-state) x)) (add1 x))]))
          ) (block-falls-down-int world-state 0)))
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; swap-block FUNCTION
; Takes a World-state and a Posn and returns a World-state in which the grid's block
; at PosnSource coordinates is swapped with the block in the other coordinates
; swap-block: World-state Posn Posn -> World-state
; (define (swap-block world-state posnSrc posnDst) EXAMPLE-STATE)

(define (swap-block world-state posnSrc posnDst)
  (local (
          (define SRC-BLOCK (get-grid-block (world-state-grid world-state) (posn-x posnSrc) (posn-y posnSrc)))
          (define DST-BLOCK (get-grid-block (world-state-grid world-state) (posn-x posnDst) (posn-y posnDst)))
          (define (swap)
            (update-grid
                world-state
                (set-grid-block DST-BLOCK (world-state-grid (update-grid world-state (set-grid-block SRC-BLOCK (world-state-grid world-state) posnDst))) posnSrc) ; Block Grid Posn
             ))
          ) (swap))
  )

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; AUXILIARY FUNCTIONS TO UPDATE WORLD-STATE DATA

; UPDATE-SCORE
; takes a World State and a Number and updates the Score
; update-score: Wordld-state Number -> WorldState
; (define (update-score 100) (make-world-state BACKGROUND GRID-EXAMPLE 100 #false #false #false))

(define (update-score world-state n)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) n
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state)
                    (world-state-falling-blocks world-state)))

; UPDATE-SHOULD-QUIT
(define (update-should-quit world-state value)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    value (world-state-should-spawn world-state) (world-state-is-paused world-state) (world-state-falling-blocks world-state)))

; UPDATE-SHOULD-SPAWN
(define (update-should-spawn world-state value)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) value (world-state-is-paused world-state) (world-state-falling-blocks world-state)))

; UPDATE-IS-PAUSED
(define (update-is-paused world-state value)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) value (world-state-falling-blocks world-state)))

; UPDATE-FALLING-BLOCKS
; updates falling-blocks which is a Vector in the World-state
(define (update-falling-blocks world-state value)
  (make-world-state (world-state-background world-state) (world-state-grid world-state) (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state) value))

; UPDATE-GRID
(define (update-grid world-state value)
  (make-world-state (world-state-background world-state) value (world-state-score world-state)
                    (world-state-should-quit world-state) (world-state-should-spawn world-state) (world-state-is-paused world-state) (world-state-falling-blocks world-state)))

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
; that is not EMPTY-COLOR), it returns the number of the row that is full
; row-full: World-state -> Number
; (define (row-full world-state) EXAMPLE-STATE)

;;; prendo la grid dal world-state,
;;; prendo l'ultima row (y = 23) (che è un vettore di block)
;;; e faccio vector-member della row e gli passo il NFEB, se mi returna true vado a quella dopo
;;; se mi returna false gli faccio mettere set-grid-row con la grid, la y e get-grid-row della grid e (sub1 y)

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


; HANDLE-KEY FUNCTION
;








; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; QUIT? FUNCTION











; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; BIG-BANG
;
(define (tetris initial-state)
  (big-bang initial-state
    [to-draw draw]
    [on-tick tick]
    ;[on-key handle-key]
    ;[stop-when quit?]
    ))




#|


TO DO:

* il piece cade da solo (tick)
* i pezzi si fermano
* i pezzi si impilano
* se la riga (y) è completa: sposta giù di uno quello che c'è sopra (set-grid-row)
* se la riga 20 non ha solo blocchi vuoti: hai perso
     * non spawnano piu pezzi
     * ti esce un messaggio
     * press key to restart (forse)
* frecce muovono il piece (handle-key)
* I PEZZI RUOTANO!!!!!!!! :S
* aggiungere il tick interno al worldstate
* fare template e check-expect

|#

