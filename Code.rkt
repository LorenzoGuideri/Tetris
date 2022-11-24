;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Code) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)
(require racket/vector)

;; CONSTANTS

; BLOCK COLORS
(define YELLOW (make-color 242 240 184))
(define ORANGE (make-color 253 207 179))
(define PINK (make-color 246 207 250))
(define PURPLE (make-color 176 189 245))
(define BLUE (make-color 196 237 245))
(define GREEN (make-color 200 224 152))

(define COLORS (vector YELLOW ORANGE PINK PURPLE BLUE GREEN)) 

; BACKGROUND
(define BACKGROUND (overlay (add-line 0 0 0 500 "white")
                            (add-line 0 0 300 0 "white")
                            (rectangle 300 500 "solid" "grey")))
  
;; DATA TYPES

; a Block is a Structure (make-block type position is-falling)
; where:
;       - type is one of
;                - #false
;                - (make-color r g b)
;
;       - position is a Posn (make-posn Number Number)
;                - it contains the position of the block in the grid 
;
;       - is-falling is a Boolean containing the position of the block in the grid
;                - #true when the block is falling
;                - #false when the block is not falling
;
(define-struct block [type position is-falling])
;
; Examples
;
(define FALLING-EMPTY-BLOCK (make-block #false (make-posn 0 0) #true))
(define FALLING-COLOR-BLOCK (make-block PINK (make-posn 1 1) #true))
(define NONFALLING-EMPTY-BLOCK (make-block #false (make-posn 9 8) #false))
(define NONFALLING-COLOR-BLOCK (make-block PURPLE (make-posn 3 4) #true))


; a Piece is a Vector<Vector<Block>> where both vectors have size 4 (make-vector 4 (make-vector 4 Block))
;        - A piece is the combination of various blocks to form the well known tetromin
;        - This pieces will be spawned on top of the playing field and will fall down until they reach the bottom or another piece
;        - The pieces are predefined
;
; Examples
;
(define VECTOR-EXAMPLE (make-vector 4 [(make-vector 4 [FALLING-COLOR-BLOCK FALLING-COLOR-BLOCK FALLING-COLOR-BLOCK FALLING-COLOR-BLOCK])]))



