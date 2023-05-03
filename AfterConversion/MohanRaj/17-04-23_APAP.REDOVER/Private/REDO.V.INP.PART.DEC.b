* @ValidationCode : MjoxMzQ2MjUzNzU5OkNwMTI1MjoxNjgxNzMxOTkyNDQzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:16:32
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
SUBROUTINE REDO.V.INP.PART.DEC
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is an authorisation routine attached to below versions,
*TELLER,COLLECT.AA.REPAY

* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 10-11-2010        JEEVA T        ODR-2010-08-0017    Baselined after few logic changes
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.MULTI.TRANSACTION.SERVICE


    GOSUB INIT
    GOSUB PROCESS
RETURN

******
INIT:
******
*Initialize all the variables

    FN.MULTI.TRANSACTION.SERVICE = 'F.MULTI.TRANSACTION.SERVICE'
    F.MULTI.TRANSACTION.SERVICE = ''
    CALL OPF(FN.MULTI.TRANSACTION.SERVICE,F.MULTI.TRANSACTION.SERVICE)

RETURN
*********
PROCESS:
*********
* Removal of Transaction ID from the local table

    Y.AMT = R.NEW(REDO.MTS.TRANSACTION.AMT)
    Y.COUNT =DCOUNT(Y.AMT,@VM)
    Y.OD.AMT = R.NEW(REDO.MTS.OD.AMT)

    CHANGE @VM TO @FM IN Y.AMT
    CHANGE @VM TO @FM IN Y.OD.AMT
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE Y.COUNT
        R.NEW(REDO.MTS.TRANSACTION.AMT)<1,Y.CNT> = FMT(Y.AMT<Y.CNT>,"R2#10")
        R.NEW(REDO.MTS.OD.AMT)<1,Y.CNT>          = FMT(Y.OD.AMT<Y.CNT>,"R2#10")
        Y.CNT += 1
    REPEAT

    Y.TOT.AMT = R.NEW(REDO.MTS.TOTAL.AMT)
    Y.CASH.AMT = R.NEW(REDO.MTS.CASH.AMT)
    Y.CHQ.AMT = R.NEW(REDO.MTS.CHEQUE.AMT)
    Y.TRA.AMT = R.NEW(REDO.MTS.TRANSFER.AMT)
    Y.NET.AMT = R.NEW(REDO.MTS.NET.AMOUNT)
    Y.OD.AMT = R.NEW(REDO.MTS.OD.AMT)
    Y.REM.AMT = R.NEW(REDO.MTS.REMAINDER.AMT)
    Y.AMT.TO.BE.AMT = R.NEW(REDO.MTS.AMT.TO.BE.PAID)
    R.NEW(REDO.MTS.TOTAL.AMT)       = FMT(Y.TOT.AMT,"R2#10")
    R.NEW(REDO.MTS.CASH.AMT)        = FMT(Y.CASH.AMT,"R2#10")
    R.NEW(REDO.MTS.CHEQUE.AMT)      = FMT(Y.CHQ.AMT,"R2#10")
    R.NEW(REDO.MTS.TRANSFER.AMT)    = FMT(Y.TRA.AMT,"R2#10")
    R.NEW(REDO.MTS.NET.AMOUNT)      = FMT(Y.NET.AMT,"R2#10")
    R.NEW(REDO.MTS.REMAINDER.AMT)   = FMT(Y.REM.AMT,"R2#10")
    R.NEW(REDO.MTS.AMT.TO.BE.PAID)  = FMT(Y.AMT.TO.BE.AMT,"R2#10")
RETURN
*******************************************************************************************
END
