* @ValidationCode : MjoxMjI1ODUyNzcyOkNwMTI1MjoxNjgxNzMxOTQwNjA4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:15:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.INP.OVRRIDE
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This subroutine would show a override message, which would deliver
* the user a message if the option for the field, STOPPAYMENT.STATUS has been
* selected as Non-Confirmed OR CONFIRMED
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who           Reference            Description
* 25-Nov-2009       SHANKAR RAJU                            Initial Creation
*30-SEP-2011        JEEVA T          PACS00134605         trim is used for removing leading zero's
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.CHEQUE.STOP.PARA

*------------------------------MAIN------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------------

*------------------------------INIT------------------------------------------
INIT:

    FN.REDO.CHEQUE.STOP.PARA = 'F.REDO.CHEQUE.STOP.PARA'
    F.REDO.CHEQUE.STOP.PARA = ''

    CALL OPF(FN.REDO.CHEQUE.STOP.PARA,F.REDO.CHEQUE.STOP.PARA)
RETURN
*----------------------------------------------------------------------------
PROCESS:


    CHEQUE.NO1=R.NEW(FT.CHEQUE.NUMBER)
    Y.CHEQ.NUM = DCOUNT(CHEQUE.NO1,@VM)

    IF CHEQUE.NO1 NE '' THEN

        DEBT.AC.NO = R.NEW(FT.DEBIT.ACCT.NO)

        COUNTER.LOOP = 1
        LOOP
        WHILE COUNTER.LOOP LE Y.CHEQ.NUM

            FIRST.CHQ.NO=CHEQUE.NO1<1,COUNTER.LOOP>
            FIRST.CHQ.NO = TRIM(FIRST.CHQ.NO,'0','L')
            Y.ID = DEBT.AC.NO:"*":FIRST.CHQ.NO
            CALL F.READ(FN.REDO.CHEQUE.STOP.PARA,Y.ID,R.REDO.CHEQUE.STOP.PARA,F.REDO.CHEQUE.STOP.PARA,Y.ERR)
            IF R.REDO.CHEQUE.STOP.PARA THEN
                Y.STATUS = R.REDO.CHEQUE.STOP.PARA<CHQ.STOP.STATUS>
                GOSUB DISPLAY.MESSAGE
            END
            COUNTER.LOOP += 1 ;*R22 Auto code conversion

        REPEAT
    END

RETURN

RETURN
*-----------------------------------------------------------------------------------------------------
DISPLAY.ERROR:

    AF = FT.CHEQUE.NUMBER
    AV = COUNTER.LOOP
    ETEXT='EB-DESC.CHEQUE.STATUS':@FM:FIRST.CHQ.NO
    CALL STORE.END.ERROR
    GOSUB END.ROU

RETURN
*----------------------------------------------------------------------------------------------------
DISPLAY.OVERRIDE:

    TEXT='STATUS.OF.CHEQUE':@FM:FIRST.CHQ.NO
    CALL STORE.OVERRIDE(CURR.NO+1)
    GOSUB END.ROU
RETURN
*---------------------------------------------------------------------------------------------------
DISPLAY.MESSAGE:

    CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM)

    IF Y.STATUS EQ 'NONCONFIRMED' THEN


        GOSUB DISPLAY.OVERRIDE

    END ELSE
        IF Y.STATUS EQ 'CONFIRMED' THEN

            GOSUB DISPLAY.ERROR
        END
    END
RETURN

*---------------------------------------------------------------------------------------------------
END.ROU:

END
*-----------------------------------------------------------------------------------------------------
