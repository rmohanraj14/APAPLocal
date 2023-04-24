* @ValidationCode : MjoyMTAyOTQyNjA3OkNwMTI1MjoxNjgxMjE1MjM5ODQxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:43:59
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.PAYMENT.RULE
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.PAYMENT.RULE
*---------------------------------------------------------------------------------

*DESCRIPTION       :Raising an Error Message by checking the Maximum amount is present in Both
*                   AA.ARR.TERM.AMOUNT and  AA.ARR.PAYMENT.SCHEDULE application
*LINKED WITH       : NA
* ----------------------------------------------------------------------------------
* Modification History:
*
* Issue to be raised:
* Desc: Unable to input an arrangement, shows interest rate mandatory error
* Solution: Changed the routine logic, such that instead of calling from PAYMENT.SCHEDULE, this
*           routine is called from ACTIVITY.PRESENTATION

* 29.06.2011          Marimuthu S              PACS00080543
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM,VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*---------------------------------------------------------------------------------------------------

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

*-----*
INIT:
*-----*
*intilaise the variables


*IF OPERATOR EQ 'TEM.5' THEN DEBUG


    LOC.REF.APPLICATION='AA.PRD.DES.PAYMENT.SCHEDULE':@FM:'AA.PRD.DES.TERM.AMOUNT'
    LOC.REF.FIELDS='L.AA.MIN.AMOUNT':@VM:'L.AA.MAX.AMOUNT':@FM:'L.AA.MIN.AMOUNT':@VM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.TIME':@VM:'L.AA.MAX.TIME'
    LOC.REF.POS=''

    ARR.ID=c_aalocArrId
    EFF.DATE=''
    PROP.CLASS='TERM.AMOUNT'


    GET.PROP.CLASS='PAYMENT.SCHEDULE'

    PROPERTY=''
    R.Condition=''
    ERR.MSG=''
RETURN

*--------*
PROCESS:
*--------*
    CALL REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG)
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

* PACS00080543  - S
*  CALL REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,GET.PROP.CLASS,PROPERTY,OUT.REC.CONDITION,ERR.MSG)
* PACS00080543  - E

    PAY.MIN.AMT=LOC.REF.POS<1,1>
    PAY.MAX.AMT=LOC.REF.POS<1,2>
    TERM.MIN.AMT=LOC.REF.POS<2,1>
    TERM.MAX.AMT=LOC.REF.POS<2,2>
    TERM.MIN.TIME=LOC.REF.POS<2,3>
    TERM.MAX.TIME=LOC.REF.POS<2,4>

    T.MIN.AMT=R.Condition<AA.AMT.LOCAL.REF><1,TERM.MIN.AMT>
    T.MAX.AMT=R.Condition<AA.AMT.LOCAL.REF><1,TERM.MAX.AMT>

* PACS00080543  - S
    P.MIN.AMT=R.NEW(AA.PS.LOCAL.REF)<1,PAY.MIN.AMT>
    P.MAX.AMT=R.NEW(AA.PS.LOCAL.REF)<1,PAY.MAX.AMT>

* P.MAX.AMT =OUT.REC.CONDITION<AA.PS.LOCAL.REF><1,PAY.MAX.AMT>
* P.MIN.AMT=OUT.REC.CONDITION<AA.PS.LOCAL.REF><1,PAY.MIN.AMT>
* PACS00080543  - E


*-----------------------------------------------
*Checking for the value and raising the Error
*-----------------------------------------------

    IF P.MAX.AMT NE '' AND T.MAX.AMT NE '' THEN
        AF=AA.PS.LOCAL.REF
        AV=PAY.MAX.AMT
        ETEXT="EB-MAX.AMT.CHECK"
        CALL STORE.END.ERROR
    END
    IF P.MAX.AMT EQ '' AND T.MAX.AMT EQ '' THEN
        AF=AA.PS.LOCAL.REF
        AV=PAY.MAX.AMT
        ETEXT="EB-MAX.AMT.MAND"
        CALL STORE.END.ERROR
    END

    IF P.MIN.AMT NE '' AND T.MIN.AMT NE '' THEN
        AF=AA.PS.LOCAL.REF
        AV=PAY.MIN.AMT
        ETEXT="EB-MAX.AMT.CHECK"
        CALL STORE.END.ERROR
    END
    IF P.MIN.AMT EQ '' AND T.MIN.AMT EQ '' THEN
        AF=AA.PS.LOCAL.REF
        AV=PAY.MIN.AMT
        ETEXT="EB-MAX.AMT.MAND"
        CALL STORE.END.ERROR
    END

RETURN
END
