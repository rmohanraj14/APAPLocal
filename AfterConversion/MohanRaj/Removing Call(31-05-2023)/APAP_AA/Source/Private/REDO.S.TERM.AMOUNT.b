* @ValidationCode : MjotMzA3OTA1MDM4OkNwMTI1MjoxNjgwMTkwMTYwOTM1OklUU1M6LTE6LTE6LTIxOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -21
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.TERM.AMOUNT
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :H GANESH
*Program   Name    :REDO.S.TERM.AMOUNT
*---------------------------------------------------------------------------------

*DESCRIPTION       :Raising an Error Message by checking the Maximum amount is present in
*                   AA.ARR.TERM.AMOUNT
*LINKED WITH       : NA
* -----------------------------------------------------------------------------------------
* Modification History:
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, FM TO @FM
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT

    GOSUB INIT
    GOSUB PROCESS
RETURN
* ----------------------------------------------------------------------------------
INIT:
* ----------------------------------------------------------------------------------

    LOC.REF.APPLICATION='AA.PRD.DES.TERM.AMOUNT'
    LOC.REF.FIELDS='L.AA.MIN.AMOUNT':@VM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.TIME':@VM:'L.AA.MAX.TIME'    ;** R22 Auto conversion - VM TO @VM
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    TERM.MIN.AMT=LOC.REF.POS<1,1>
    TERM.MAX.AMT=LOC.REF.POS<1,2>
    TERM.MIN.TIME=LOC.REF.POS<1,3>
    TERM.MAX.TIME=LOC.REF.POS<1,4>


RETURN
* ----------------------------------------------------------------------------------
PROCESS:
* ----------------------------------------------------------------------------------

    T.MIN.AMT=R.NEW(AA.AMT.LOCAL.REF)<1,TERM.MIN.AMT>
    T.MAX.AMT=R.NEW(AA.AMT.LOCAL.REF)<1,TERM.MAX.AMT>
    T.MIN.TIME=R.NEW(AA.AMT.LOCAL.REF)<1,TERM.MIN.TIME>
    T.MAX.TIME=R.NEW(AA.AMT.LOCAL.REF)<1,TERM.MAX.TIME>


    IF (T.MIN.AMT GT 100 OR T.MIN.AMT LT 0) AND T.MIN.AMT NE '' THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MIN.AMT
        ETEXT="EB-TIME.AMT.CHECK":@FM:'AMOUNT' ;** R22 Auto conversion - FM TO @FM
        CALL STORE.END.ERROR
    END
    IF (T.MAX.AMT GT 100 OR T.MAX.AMT LT 0) AND T.MAX.AMT NE '' THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MAX.AMT
        ETEXT="EB-TIME.AMT.CHECK":@FM:'AMOUNT'        ;** R22 Auto conversion - FM TO @FM
        CALL STORE.END.ERROR
    END
    IF (T.MIN.TIME GT 100 OR T.MIN.TIME LT 0) AND T.MIN.TIME NE '' THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MIN.TIME
        ETEXT="EB-TIME.AMT.CHECK":@FM:'TIME'       ;** R22 Auto conversion - FM TO @FM
        CALL STORE.END.ERROR
    END

    IF (T.MAX.TIME GT 100 OR T.MAX.TIME LT 0) AND T.MAX.TIME NE '' THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MAX.TIME
        ETEXT="EB-TIME.AMT.CHECK":@FM:'TIME'   ;** R22 Auto conversion - FM TO @FM
        CALL STORE.END.ERROR
    END
    IF T.MIN.AMT GT T.MAX.AMT THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MIN.AMT
        ETEXT='EB-MAX.TIME.AMT.CHK':@FM:"AMOUNT":@VM:"AMOUNT"    ;** R22 Auto conversion - VM TO @VM
        CALL STORE.END.ERROR
    END

    IF T.MIN.TIME GT T.MAX.TIME THEN
        AF=AA.AMT.LOCAL.REF
        AV=TERM.MIN.TIME
        ETEXT='EB-MAX.TIME.AMT.CHK':@FM:"TIME":@VM:"TIME"         ;** R22 Auto conversion - FM TO @FM, VM TO @VM
        CALL STORE.END.ERROR
    END

RETURN
END
