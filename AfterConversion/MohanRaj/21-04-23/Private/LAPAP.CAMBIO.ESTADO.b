* @ValidationCode : Mjo2NTM4OTcwMzA6Q3AxMjUyOjE2ODIwNjk5NDk3MDM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:09:09
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CAMBIO.ESTADO

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT

    GOSUB MAIN.PROCESS
RETURN

MAIN.PROCESS:

    Y.ID = ID.NEW.LAST
    FN.AA.STATUS = 'F.ST.L.APAP.ARR.ESTATUS$NAU'
    FV.AA.STATUS = ''
    CALL OPF(FN.AA.STATUS,FV.AA.STATUS)
    CALL F.READ(FN.AA.STATUS,Y.ID,R.SS,FV.AA.STATUS,AA.SS.ERR)
    Y.STATUS = R.SS<2>
    AA.ID = R.SS<1>
    GOSUB SET.PROCESO
SET.PROCESO:
    FN.AA.ARR='F.AA.ARRANGEMENT'
    F.AA.ARR=''
    CALL OPF(FN.AA.ARR,F.AA.ARR)
    CALL F.READ(FN.AA.ARR,AA.ID,R.AA,F.AA.ARR,AA.ARR.ERR)
    R.AA<AA.ARR.ARR.STATUS>=Y.STATUS
    CALL F.WRITE(FN.AA.ARR,AA.ID,R.AA)
* CALL JOURNAL.UPDATE("")
    AA.ID = ""
    Y.STATUS = ""
RETURN

END
