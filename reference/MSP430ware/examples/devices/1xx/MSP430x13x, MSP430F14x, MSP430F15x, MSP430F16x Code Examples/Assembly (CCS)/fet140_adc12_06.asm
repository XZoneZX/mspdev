;******************************************************************************
;   MSP-FET430P140 Demo - ADC12, Repeated Sequence of Conversions
;
;   Description: This program will show how to perform a repeated sequence of
;                conversions using the "repeat sequence-of-channels" mode.
;
;   This example shows how to perform a repeated sequence of conversions using
;   "repeat sequence-of-channels" mode.  AVcc is used for the reference and
;   repeated sequence of conversions is performed on Channels A0, A1, A2, and
;   A3. Each conversion result is stored in ADC12MEM0, ADC12MEM1, ADC12MEM2,
;   and ADC12MEM3 respectively. After each sequence, the 4 conversion results
;   are moved to ram locations.  The conversion results for channel A0 are
;   moved to ram addresses 0x200 - 0x20E, A1 results are moved to addresses
;   0x210 - 0x21E, A2 results are moved to addresses 0x220 - 0x22E, and A3
;   results are moved to 0x230 - 0x23E. Test by applying voltages to channels
;   A0 - A3. Open a memory window in debugger and view the memory contents at
;   the above locations after stopping program execution. Remember the
;   conversion results are 12-bits so you must set the memory window to 16-bit
;   mode.
;
;   Note that a sequence has no restrictions on which channels are converted.
;   For example, a valid sequence could be A0, A3, A2, A4, A2, A1, A0, and A7.
;   See the MSP430x1xx User's Guide for instructions on using the ADC12.
;
;   *Note*  This example only functions on MSP production silicon, not PMS
;   pre-production silicon.  Production silicon will be noted on the chip as
;   "M430F149" whereas pre-production silicon will be marked "P430F149."
;
;
;                MSP430F149
;            -----------------
;           |                 |
;   Vin0 -->|P6.0/A0          |
;   Vin1 -->|P6.1/A1          |
;   Vin2 -->|P6.2/A2          |
;   Vin3 -->|P6.3/A3          |
;           |                 |
;
;
;   M. Mitchell / G. Morton
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x14x.h"

A0result      .equ    0200h                 ; Channel A0 results
A1result      .equ    0210H                 ; Channel A1 results
A2result      .equ    0220H                 ; Channel A2 results
A3result      .equ    0230H                 ; Channel A3 results
                                            ;
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov     #0A00h,SP               ; Initialize stackpointer
StopWDT     mov     #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog
            bis.b   #BIT0+BIT1+BIT2+BIT3,&P6SEL ; Enable A/D inputs
                                            ;
SetupADC12  mov     #SHT0_8+MSC+ADC12ON,&ADC12CTL0
                                            ; Turn on ADC12, use int. osc.
                                            ; extend sampling time so won't
                                            ; get overflow
                                            ; set MSC so conversions triggered
                                            ; automatically
            mov     #SHP+CONSEQ_3,&ADC12CTL1
                                            ; Use sampling timer, set mode
            mov     #BIT3,&ADC12IE          ; Enable ADC12IFG.3 for ADC12MEM3
            mov.b   #INCH_0,ADC12MCTL0      ; A0 goes to MEM0
            mov.b   #INCH_1,ADC12MCTL1      ; A1 goes to MEM1
            mov.b   #INCH_2,ADC12MCTL2      ; A2 goes to MEM2
            mov.b   #EOS+INCH_3,ADC12MCTL3  ; A3 goes to MEM3, .end of sequence
                                            ;
            clr     R5                      ; Clear pointer
                                            ;
Mainloop    bis     #ENC,&ADC12CTL0         ; Enable conversions
            bis     #ADC12SC,&ADC12CTL0     ; Start conversions
            bis     #CPUOFF+GIE,SR          ; Hold in LPM0, Enable interrupts
                    nop                     ; Need only for debug
                                            ;
;------------------------------------------------------------------------------
ADC12ISR    ; Interrupt Service Routine for ADC12
;------------------------------------------------------------------------------
            mov     &ADC12MEM0,A0result(R5) ; Move results to RAM
            mov     &ADC12MEM1,A1result(R5) ; Move results to RAM
            mov     &ADC12MEM2,A2result(R5) ; Move results to RAM
            mov     &ADC12MEM3,A3result(R5) ; Move results to RAM, IFG reset
            incd    R5                      ; Increment results table pointer
            and     #0Eh,R5                 ; Modulo pointer
            reti
;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect   ".int07"                ; ADC12 Interrupt Vector
            .short  ADC12ISR                ;
            .end