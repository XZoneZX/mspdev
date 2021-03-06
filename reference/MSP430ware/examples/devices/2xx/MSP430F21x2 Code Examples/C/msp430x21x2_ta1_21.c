//******************************************************************************
//  MSP430F21x2 Demo - Timer1_A2, PWM TA1_1, Up/Down Mode, HF XTAL ACLK
//
//  Description: This program generates one PWM output on P3.7 using
//  Timer1_A2 configured for up/down mode. The value in TA1CCR0, 128, defines the
//  PWM period/2 and the values in TA1CCR1 the PWM duty cycle.
//  Using HF XTAL ACLK as TA1CLK, the timer period is HF XTAL/256 with a 75%
//  duty cycle on P3.7.
//  ACLK = MCLK = TA1CLK = HF XTAL
//  /* HF XTAL REQUIRED AND NOT INSTALLED ON FET */
//  /* Min Vcc required varies with MCLK frequency - refer to datasheet */
//
//               MSP430F21x2
//            -----------------
//        /|\|              XIN|-
//         | |                 | HF XTAL (3 � 16MHz crystal or resonator)
//         --|RST          XOUT|-
//           |                 |
//           |       P3.7/TA1_1|--> TA1CCR1 - 75% PWM
//           |                 |
//
//  A. Dannenberg
//  Texas Instruments Inc.
//  April 2006
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 4.10A
//******************************************************************************
#include "msp430x21x2.h"

void main(void)
{
  volatile unsigned int i;
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  BCSCTL1 |= XTS;                           // ACLK= LFXT1= HF XTAL
  BCSCTL3 |= LFXT1S1;                       // LFXT1S1 = 3-16MHz

  do
  {
    IFG1 &= ~OFIFG;                         // Clear OSCFault flag
    for (i = 0xFF; i > 0; i--);             // Time for flag to set
  }
  while (IFG1 & OFIFG);                     // OSCFault flag still set?

  BCSCTL2 |= SELM_3;                        // MCLK= LFXT1 (safe)
  P3DIR |= 0x80;                            // P1.2 and P1.3 output
  P3SEL |= 0x80;                            // P1.2 and P1.3 TA1/2 otions
  TA1CCR0 = 128;                             // PWM Period/2
  TA1CCTL1 = OUTMOD_6;                       // TACCR1 toggle/set
  TA1CCR1 = 32;                              // TACCR1 PWM duty cycle

  TA1CTL = TASSEL_1 + MC_3;                  // ACLK, up-down mode

  __bis_SR_register(LPM0_bits);             // Enter LPM0
}

