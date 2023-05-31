* @ValidationCode : MjotOTk5NTYwOTE4OkNwMTI1MjoxNjgwMTkwMTYwMjYwOklUU1M6LTE6LTE6MTc3OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 177
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.RATE(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.E.NOF.DATCUST
* Attached as     : ROUTINE
* Primary Purpose : To return value of AA ARRANGEMENT ACTIVITY>EFFECTIVE.DATE  field
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
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - No changes
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.INTEREST.ACCRUALS

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
    CALL F.READ(FN.AA.INT.ACCRUALS,Y.ARRG.ID,R.AA.INT.ACCRUALS,F.AA.INT.ACCRUALS,"")
    IF R.AA.INT.ACCRUALS THEN
        AA.ARR = R.AA.INT.ACCRUALS<AA.INT.ACC.RATE,1>
    END
RETURN
*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    Y.ARRG.ID = AA.ID:"-PRINCIPALINT"

    FN.AA.INT.ACCRUALS = "F.AA.INTEREST.ACCRUALS"
    F.AA.INT.ACCRUALS  = ""
    R.AA.INT.ACCRUALS  = ""
    AA.ARR = 'NULO'
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.AA.INT.ACCRUALS, F.AA.INT.ACCRUALS)
RETURN
*------------
END
