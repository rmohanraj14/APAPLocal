* @ValidationCode : MjoyMTE3MTY0MjY0OkNwMTI1MjoxNjgxMzAyMjI4OTM5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:53:48
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
SUBROUTINE REDO.V.AUTH.ADJ.SUSP.BAL
*********************************************************************
*Company Name  : APAP
*First Release : R15 Upgrade
*Developed for : APAP
*Developed by  : Edwin Charles D
*Date          : 21/06/2017
*--------------------------------------------------------------------------------------------
*
* Subroutine Type       : PROCEDURE
* Attached to           : VERSION  - AA.ARRANGEMENT.ACTIVITY,ADJ.AUTH
* Attached as           : ID ROUTINE
* Primary Purpose       : When a transaction is authorised, we are replacing the arrangement status
* Modified              : R15 Upgrade
*--------------------------------------------------------------------------------------------
* Modification Details:
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     = TO EQ
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*--------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
*
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.AA.UNC.PENDING

*
*************************************************************************

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:
*----
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
    FN.REDO.AA.UNC.PENDING = 'F.REDO.AA.UNC.PENDING'
    F.REDO.AA.UNC.PENDING = ''
    CALL OPF(FN.REDO.AA.UNC.PENDING, F.REDO.AA.UNC.PENDING)

RETURN

PROCESS:
*-------
    R.AA.ARRANGEMENT = ''
    ARR.ERR = ''
    AA.ARR.ID = ''
    AA.ARR.ID = R.NEW(AA.ARR.ACT.ARRANGEMENT)
    CALL F.READ(FN.AA.ARRANGEMENT,AA.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    CALL F.READ(FN.REDO.AA.UNC.PENDING,AA.ARR.ID,R.REDO.AA.UNC.PENDING,F.REDO.AA.UNC.PENDING,UNC.ERR)
    IF AA.ARR.ID AND R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> EQ 'CURRENT' AND R.REDO.AA.UNC.PENDING<AA.UN.ARR.STATUS> EQ 'PENDING.CLOSURE' THEN
        R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> = 'PENDING.CLOSURE'
        CALL F.WRITE(FN.AA.ARRANGEMENT,AA.ARR.ID,R.AA.ARRANGEMENT)
    END
    CALL F.DELETE(FN.REDO.AA.UNC.PENDING,AA.ARR.ID)
RETURN
END
