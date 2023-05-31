* @ValidationCode : MjotMTExMzI5MzE4NDpDcDEyNTI6MTY4MDE5MDE2MDU4ODpJVFNTOi0xOi0xOjI3MjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 272
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.REPAY.REF(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose :
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
* AA.ARR - data returned to the routine
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            :
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, I TO I.VAR
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACTIVITY.HISTORY

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    AA.ARRANGEMENT.ERR = ''; R.AA.ARRANGEMENT = ''
    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARRG.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARRANGEMENT.ERR)
    STAR.DATE.VAL = R.AA.ARRANGEMENT<AA.ARR.START.DATE>

    REQD.MODE = ''; EFF.DATE = STAR.DATE.VAL; R.AA.ACTIVITY.HISTORY = ''
    CALL AA.READ.ACTIVITY.HISTORY(Y.ARRG.ID, REQD.MODE, EFF.DATE, R.AA.ACTIVITY.HISTORY)

*  CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.ARRG.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,"")
    IF R.AA.ACTIVITY.HISTORY THEN
        NRO.ACT = DCOUNT(R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE>,@VM)         ;** R22 Auto conversion - VM TO @VM
        FOR I.VAR= 1 TO NRO.ACT                      ;** R22 Auto conversion - I TO I.VAR
            LOCATE Y.ACT.REF IN R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY,I.VAR,1> SETTING Y.AH.ACT.POS THEN  ;** R22 Auto conversion - I TO I.VAR
                AA.ARR =  R.AA.ACTIVITY.HISTORY<AA.AH.SYSTEM.DATE,I.VAR,Y.AH.ACT.POS>        ;** R22 Auto conversion - I TO I.VAR
                BREAK
            END
        NEXT
    END

RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    B.CONT = 0
    Y.ARRG.ID = AA.ID
    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY  = ''
    R.AA.ACTIVITY.HISTORY = ''
    Y.ACT.REF = "LENDING-APPLYPAYMENT-PR.REPAYMENT"
    AA.ARR = "NULO"
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'; F.AA.ARRANGEMENT = ''
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
RETURN
*------------
END
