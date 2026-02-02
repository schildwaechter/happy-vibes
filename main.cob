       IDENTIFICATION DIVISION.
       PROGRAM-ID. HAPPY-NUMBERS.
       AUTHOR. AI ASSISTANT.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-BOUND                PIC 9(10).
       01  WS-CURRENT-NUM          PIC 9(10).
       01  WS-HAPPY-COUNT          PIC 9(10) VALUE 0.
       01  WS-PERCENTAGE           PIC ZZ9.99.
       01  WS-PERCENTAGE-COMP      COMP-2.
       
       01  WS-ARG-COUNT            PIC 9(2).
       01  WS-ARG-VALUE            PIC X(20).
       
       01  WS-RESULT               PIC 9.
           88  IS-HAPPY-NUM        VALUE 1.
           88  NOT-HAPPY-NUM       VALUE 0.
       
       01  WS-OUTPUT-LINE.
           05  FILLER              PIC X(21) VALUE 
               "Happy numbers from 1".
           05  FILLER              PIC X(4) VALUE " to ".
           05  WS-OUT-BOUND        PIC Z(9)9.
           05  FILLER              PIC X(2) VALUE ": ".
           05  WS-OUT-COUNT        PIC Z(9)9.
           05  FILLER              PIC X(2) VALUE " (".
           05  WS-OUT-PERCENT      PIC ZZ9.99.
           05  FILLER              PIC X(2) VALUE "%)".
       
       01  WS-SEEN-ARRAY.
           05  WS-SEEN-ITEM        PIC 9(10) OCCURS 1000 TIMES.
       01  WS-SEEN-COUNT           PIC 9(4) VALUE 0.
       01  WS-SEEN-IDX             PIC 9(4).
       01  WS-FOUND                PIC 9 VALUE 0.
       
       01  WS-TEMP-NUM             PIC 9(10).
       01  WS-DIGIT                PIC 9.
       01  WS-SUM                  PIC 9(10).
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           ACCEPT WS-ARG-COUNT FROM ARGUMENT-NUMBER
           
           IF WS-ARG-COUNT NOT = 1
               DISPLAY "Usage: happy_cobol BOUND" UPON SYSERR
               DISPLAY "  BOUND: positive integer to check " &
                       "happy numbers from 1 to BOUND" UPON SYSERR
               STOP RUN RETURNING 1
           END-IF
           
           ACCEPT WS-ARG-VALUE FROM ARGUMENT-VALUE
           
           IF FUNCTION TEST-NUMVAL(WS-ARG-VALUE) NOT = 0
               DISPLAY "Error: BOUND must be a valid integer" 
                   UPON SYSERR
               STOP RUN RETURNING 1
           END-IF
           
           MOVE FUNCTION NUMVAL(WS-ARG-VALUE) TO WS-BOUND
           
           IF WS-BOUND < 1
               DISPLAY "Error: BOUND must be a positive integer " &
                       "(greater than 0)" UPON SYSERR
               STOP RUN RETURNING 1
           END-IF
           
           MOVE 0 TO WS-HAPPY-COUNT
           
           PERFORM VARYING WS-CURRENT-NUM FROM 1 BY 1
               UNTIL WS-CURRENT-NUM > WS-BOUND
               
               PERFORM CHECK-IF-HAPPY
               
               IF IS-HAPPY-NUM
                   ADD 1 TO WS-HAPPY-COUNT
               END-IF
           END-PERFORM
           
           COMPUTE WS-PERCENTAGE-COMP = 
               (WS-HAPPY-COUNT / WS-BOUND) * 100
           MOVE WS-PERCENTAGE-COMP TO WS-PERCENTAGE
           
           MOVE WS-BOUND TO WS-OUT-BOUND
           MOVE WS-HAPPY-COUNT TO WS-OUT-COUNT
           MOVE WS-PERCENTAGE TO WS-OUT-PERCENT
           
           DISPLAY WS-OUTPUT-LINE
           
           STOP RUN.
       
       CHECK-IF-HAPPY.
           MOVE 0 TO WS-SEEN-COUNT
           MOVE WS-CURRENT-NUM TO WS-TEMP-NUM
           MOVE 0 TO WS-RESULT
           
           PERFORM UNTIL WS-TEMP-NUM = 1
               MOVE 0 TO WS-FOUND
               
               PERFORM VARYING WS-SEEN-IDX FROM 1 BY 1
                   UNTIL WS-SEEN-IDX > WS-SEEN-COUNT OR WS-FOUND = 1
                   
                   IF WS-SEEN-ITEM(WS-SEEN-IDX) = WS-TEMP-NUM
                       MOVE 1 TO WS-FOUND
                   END-IF
               END-PERFORM
               
               IF WS-FOUND = 1
                   MOVE 0 TO WS-RESULT
                   EXIT PERFORM
               END-IF
               
               IF WS-SEEN-COUNT < 1000
                   ADD 1 TO WS-SEEN-COUNT
                   MOVE WS-TEMP-NUM TO WS-SEEN-ITEM(WS-SEEN-COUNT)
               ELSE
                   MOVE 0 TO WS-RESULT
                   EXIT PERFORM
               END-IF
               
               PERFORM CALC-SUM-OF-SQUARES
               MOVE WS-SUM TO WS-TEMP-NUM
           END-PERFORM
           
           IF WS-TEMP-NUM = 1
               MOVE 1 TO WS-RESULT
           END-IF.
       
       CALC-SUM-OF-SQUARES.
           MOVE 0 TO WS-SUM
           
           PERFORM UNTIL WS-TEMP-NUM = 0
               COMPUTE WS-DIGIT = FUNCTION MOD(WS-TEMP-NUM, 10)
               COMPUTE WS-SUM = WS-SUM + (WS-DIGIT * WS-DIGIT)
               DIVIDE WS-TEMP-NUM BY 10 GIVING WS-TEMP-NUM
           END-PERFORM.
