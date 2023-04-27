* @ValidationCode : MjoxNDAyOTA4MTU6Q3AxMjUyOjE2ODEyMTUxNjA4NzI6SVRTUzotMTotMToxNzk6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 179
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.GET.FUNDS.IN.TRANSIT
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : Martin Macias
* Program Name :
*-----------------------------------------------------------------------------
* Description    :  This routine will get all funds in transit for a Customer Acct
* Linked with    :
* In Parameter   :
* Out Parameter  :
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* 10-APR-2023     Conversion tool   R22 Auto conversion     ++ to +=, I to I.VAR
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System

    $INSERT I_F.REDO.CLEARING.OUTWARD

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*----------*
INITIALISE:
*----------*

    FN.REDO.CLEARING.OUTWARD = "F.REDO.CLEARING.OUTWARD"
    F.REDO.CLEARING.OUTWARD = ''

    ACCT.NO = O.DATA
    AMT.FUNDS = 0

RETURN

*----------*
OPEN.FILES:
*----------*

    CALL OPF(FN.REDO.CLEARING.OUTWARD,F.REDO.CLEARING.OUTWARD)

RETURN

*--------*
PROCESS:
*--------*

    SEL.CMD = "SELECT ":FN.REDO.CLEARING.OUTWARD:" WITH CHQ.STATUS EQ 'DEPOSITED' AND ACCOUNT EQ ":ACCT.NO
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,Y.ERR)


    I.VAR = 1
    LOOP
    WHILE I.VAR LE NO.OF.REC
        CALL F.READ(FN.REDO.CLEARING.OUTWARD,SEL.LIST<I.VAR>,R.FUNDS,F.REDO.CLEARING.OUTWARD,FUNDS.ERR)
        AMT.FUNDS += R.FUNDS<CLEAR.OUT.AMOUNT>
        I.VAR += 1
    REPEAT

    O.DATA = AMT.FUNDS

RETURN

END
