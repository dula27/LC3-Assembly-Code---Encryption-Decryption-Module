.ORIG	x3000
    AND R0, R0, #0  ;
    AND R1, R1, #0  ; clear R0, R1, R2, R4
    AND R2, R2, #0  ;
    AND R4, R4, #0  ;
; *** Step 0 ***
; Starting Program
;
    LEA	R0,	StartP ; Prompt start message
    PUTS
Start 
    LEA	R0,	prompt ; prompt for input
    PUTS
    IN
    OUT
    ADD R1, R0, #0  ; copy R0 into R1 for check
; *** Step 1 ***
; Check the input
;
Test
    ;
    JSR	StoreIn
    ;
    LD R3, negX         ; Check for X
    ADD R4, R3, R1
    BRz Exit
    ;
    LD R3, negE         ; Check for E
    ADD R4, R3, R1
    BRz EDprompt
    LD R3, negE         ; Check for E
    LDI R2, charSt
    AND R4, R4, #0      ; clear out R4
    ADD R4, R3, R2      
    BRz tenChar
    ;
    LD R3, negD         ; Check for D
    ADD R4, R3, R1
    BRz EDprompt
    JSR Decryption
    ;
    LEA R0, invalid     ; Invalid prompt
    PUTS
    BRnzp Start
    ;
    ; For no 9-bit error, initialized above
    ;
    negE    .FILL	    #-69    ; E
    posE    .FILL       #69     ; E
    negD    .FILL	    #-68    ; D
    negX    .FILL	    xFFA8   ; X
    negEnt  .FILL       #-10    ; <enter>
    negZero .FILL	    #-48
    edToPr    .STRINGZ    "\nEnter input plain text of length at most 10. When done press < enter >\n"
    prompt  .STRINGZ	"\nENTER: E TO ENCRYPT,D TO DECRYPT, X TO EXIT: \n"
    StartP  .STRINGZ	"Starting PrivacyModule\n"
    invalid .STRINGZ    "\nINVALID ENTRY. PLEASE TRY AGAIN.\n"
    charSt  .FILL	    x6000
;
; Store Input
;
StoreIn
    STI R0, charSt      ; Store user input at x6000
    RET
    ;
;
; Exit section
;
Exit
    LEA R0, exitp
    PUTS
    HALT

; *** Step 2 ***
; E or D prompt
;
EDprompt
    LEA R0, keyPr       ; Prompt input message
    PUTS
    LEA R1, keySt       ; Store in space
    AND R4, R4, #0      ; Clear out R4
    ADD R4, R4, #5      ; Space of 5
cLoop
    GETC
    OUT
    STR	R0,	R1,	#0      ; Store in space address
    ADD R1, R1, #1      ; increment address
    ADD R4, R4, #-1     ; decrement loop

    BRnz exLoop
    BRnzp cLoop
exLoop
    RET
;
;Decryption
;
Decryption
    LEA R0, edToSt1
    PUTS
    BRnzp Start
    RET
;
; MESSAGE TO STORE
;
tenChar
    LEA R0, edToPr       ; Prompt input message
    PUTS
    LEA R1, edToSt      ; Store in space
    LEA R2, edToSt1
    AND R4, R4, #0      ; Clear out R4
    ADD R4, R4, #10     ; Space of 10
cLoop1
    GETC
    OUT
    LD  R3, negEnt      ; load -10 <enter>
    ADD R3, R3, R0      ; CHECK FOR <enter>
    STR	R0,	R1,	#0      ; Store in space address
    STR R0, R2, #0
    BRz exLoop1
    ADD R1, R1, #1      ; increment address
    ADD R2, R2, #1
    ADD R4, R4, #-1     ; decrement loop

    BRnz exLoop1
    BRnzp cLoop1
exLoop1
    BRnzp Vigenere

; *** Step 4 ***
; Encryption
;
; Vigenere cipher
;
Vigenere
    LEA R0, keySt
    LDR R1, R0, #1      ; load x1 into K
    ST  R1, k
    STI R1, kst
    AND R4, R4, #0      ; clear R4
    ADD R4, R4, #10     ; counter for string
    ; check end of string
    LEA R0, edToSt
xloop
    LDR R6, R0, #0      ; 1st char
    LDI R1, kst         ; x1 char
    LD  R3, #0
    LD  R3, negZero
    ADD R3, R3, R1
    BRz Ceaser
    LD  R3, #0
    LD  R3, negEnt      ; load -10 <enter>
    ADD R3, R3, R6      ; CHECK FOR <enter>
    BRz endString
    JSR xor             ; perform XOR on 2 numbers
Estore
    STR R3, R0, #0      ; store in edToSt for now
    ADD R0, R0, #1      ; increment
    ADD R4, R4, #-1     ; decrement -10
    BRnz endString
    BRnzp xloop
endString
    ;BRnzp read
    
;
; Ceaser cipher
;
Ceaser
    ;1ST DIGIT
    LEA R2, keySt       ;stores 1nd digit in asciibuff for ASCIItoBinary
    ADD R2, R2, #2
    LEA R3, ASCIIBUFF
    LDR R4, R2, #0
    STR R4, R3, #0
    ;2ND DIGIT
    ADD R3, R3, #1      ;stores 2nd digit in asciibuff for ASCIItoBinary
    ADD R2, R2, #1
    LDR R4, R2, #0
    STR R4, R3, #0
    ;3RD DIGIT
    ADD R3, R3, #1      ;stores 3rd digit in asciibuff for ASCIItoBinary
    ADD R2, R2, #1
    LDR R4, R2, #0
    STR R4, R3, #0
    ;ASCII TO BIANRY
    AND R0, R0, #0      ;clear register
    AND R1, R1, #0      ;clear register
    ADD R1, R1, #3      ;3 DIGITS TO COUNT
    AND R2, R2, #0      ;clear register
    AND R3, R3, #0      ;clear register
    AND R4, R4, #0      ;clear register
    AND R5, R5, #0      ;clear register
    AND R6, R6, #0      ;clear register
    JSR ASCIItoBinary   ;convert 3 ascii to a binary number to add 
    STI R0, int         ;store Binary converted into x4500
    ;MODULO
    LEA R3, edToSt      ;load the address of 'u'
    AND R4, R4, #0      
    ADD R4, R4, #10     ;10 counter
    LDI R6, int         ;load K into R6
bloop
    LDR R0, R3, #0      ; load with value 1 of edToSt
    ADD R0, R0, R6      ; load R0 with sum to modulo with 128
    LD  R1, one28       ; load R1 with 128
    JSR modulo          ; mod of R0 modulo 128
    STR R2, R3, #0      ; replace store in edToSt
    ADD R3, R3, #1
    ADD R4, R4, #-1
    BRnz next
    BRnzp bloop
next
    LEA R1, edToSt      ; store address of message
    LD  R2, MESSAGE     ; store address of encrypted
    AND	R3,	R3,	#0      
    ADD R3, R3, #10
vloop  
    LDR R4, R1, #0
    STR R4, R2, #0
    ADD R1, R1, #1
    ADD R2, R2, #1
    ADD R3, R3, #-1
    BRnz    read
    BRnzp   vloop

    
;
; MODUL0
;
modulo  NOT R5, R1
        ADD R5, R5, #1 ; set R3= -R1
        ; this modulo subroutine  assumes N and K are positive integers.
        ADD R2, R0, #0  ; initialize R2=R0 (and then keep subtracting R0 from it)
loop    BRn exit1    ; if R2 is negative then goto exit which adds value K (in R1) to current value
        ADD R2, R2, R5  ; R2= R0-R1
        BRnzp loop
exit1    ADD R2, R2, R1  ; add R1 to R2 when R2 negative
      RET
      one28     .FILL   #128
;
; XOR
;
xor
    ;inputs have to be in R6, R1 before computing XOR
    NOT R2, R6  ; R2 = NOT R6
    AND R5, R2, R1  ; R5 = NOT RO AND R1
    NOT R2, R1  ; R2 = NOT R1
    ;
    AND R1, R1, #0  ; callee save reg4
    ADD R1, R4, #0
    ;
    AND R4, R6, R2  ; R4 = R6 AND NOT R1
    NOT R5, R5  ; NOT R5
    NOT R4, R4  ; NOT R4
    AND R3, R5, R4  ; R3 = (NOT R5) AND (NOT R4)
    NOT R3, R3  ; R3 = NOT ((NOT R5) AND (NOT R4)) = R5 OR R4
    ;
    AND R4, R4, #0 ; callee restore
    ADD R4, R1, #0
    ;
    RET
read
    LEA R0, edToSt
    PUTS
    LEA R0, CHECK       ; Prompt debug message
    PUTS
    JSR Start
;
;  This algorithm takes an ASCII string of three decimal digits and 
;  converts it into a binary number.  R0 is used to collect the result.
;  R1 keeps track of how many digits are left to process.  ASCIIBUFF
;  contains the most significant digit in the ASCII string.
;
ASCIItoBinary  AND    R0,R0,#0      ; R0 will be used for our result 
               ADD    R1,R1,#0      ; Test number of digits.
               BRz    DoneAtoB      ; There are no digits
;
               LD     R3,NegASCIIOffset  ; R3 gets xFFD0, i.e., -x0030
               LEA    R2,ASCIIBUFF
               ADD    R2,R2,R1
               ADD    R2,R2,#-1     ; R2 now points to "ones" digit
;              
               LDR    R4,R2,#0      ; R4 <-- "ones" digit
               ADD    R4,R4,R3      ; Strip off the ASCII template
               ADD    R0,R0,R4      ; Add ones contribution
;
               ADD    R1,R1,#-1
               BRz    DoneAtoB      ; The original number had one digit
               ADD    R2,R2,#-1     ; R2  now points to "tens" digit
;
               LDR    R4,R2,#0      ; R4 <-- "tens" digit
               ADD    R4,R4,R3      ; Strip off ASCII  template
               LEA    R5,LookUp10   ; LookUp10 is BASE of tens values
               ADD    R5,R5,R4      ; R5 points to the right tens value
               LDR    R4,R5,#0
               ADD    R0,R0,R4      ; Add tens contribution to total
;
               ADD    R1,R1,#-1
               BRz    DoneAtoB      ; The original number had two digits
               ADD    R2,R2,#-1     ; R2 now points to "hundreds" digit
;        
               LDR    R4,R2,#0      ; R4 <-- "hundreds" digit
               ADD    R4,R4,R3      ; Strip off ASCII template
               LEA    R5,LookUp100  ; LookUp100 is hundreds BASE
               ADD    R5,R5,R4      ; R5 points to hundreds value
               LDR    R4,R5,#0
               ADD    R0,R0,R4      ; Add hundreds contribution to total
;         
DoneAtoB       RET
NegASCIIOffset .FILL  xFFD0
ASCIIBUFF      .BLKW  #4
LookUp10       .FILL  #0
               .FILL  #10
               .FILL  #20
               .FILL  #30
               .FILL  #40
               .FILL  #50
               .FILL  #60
               .FILL  #70
               .FILL  #80
               .FILL  #90
;
LookUp100      .FILL  #0
               .FILL  #100
               .FILL  #200
               .FILL  #300
               .FILL  #400
               .FILL  #500
               .FILL  #600
               .FILL  #700
               .FILL  #800
               .FILL  #900
int            .FILL  x4500

;
; Initializing Stuff
;
    
    k       .BLKW       #1
    keySt   .BLKW	    #5
    garb0   .FILL       x0000
    edToSt  .BLKW       #10         ; encryption decryption to store character
    garb    .FILL       x0000
    edToSt1 .BLKW       #10
    garb2   .FILL       x0000
    MESSAGE .FILL       x4000
    MESS    .FILL       x3900
    kst     .FILL       x6001
    negEOL  .FILL	    xFFF6
    neg10   .FILL       #-10
    neg100  .FILL       #-100
    neg20   .FILL       #-20
    pos100  .FILL       #100
    
    CHECK   .STRINGZ    "\nWorks.\n"
    exitp   .STRINGZ    "\nExiting program\n"
    keyPr   .STRINGZ	"\nENTER KEY (Length 5, single digit less than 8 followed by non-numeric character or the number 0 followed by a 3 digit number between 0 and 127).\n"
    

.END