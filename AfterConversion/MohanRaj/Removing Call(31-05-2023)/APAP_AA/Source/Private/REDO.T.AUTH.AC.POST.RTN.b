* @ValidationCode : MjotMzk5NjMxNjU6Q3AxMjUyOjE2ODAxOTAxNjEzMDQ6SVRTUzotMTotMTo2NjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 66
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.T.AUTH.AC.POST.RTN
*------------------------------------------------------------------------------------------------------------------
* Developer    : NAVEENKUMAR.N
* Date         : 27.05.2010
* Description  : REDO.T.AUTH.POST.RTN
*------------------------------------------------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : --N/A--
* Out : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : --N/A--
* Called By : --N/A--
*------------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Version          Date          Name              Description
* -------          ----          ----              ------------
*   1.0        27.05.2010      NAVEENKUMAR.N     Initial Creation
*   2.0        04.09.2010      Ramkumar G      Added some more validation as a port of B2-CR (ODR-2010-09-0011)
*------------------------------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------------------
* Modification History:
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, FM TO @FM
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.T.AUTH.ARRANGEMENT
    $INSERT I_REDO.T.AUTH.POST.COMMON

    IF V$FUNCTION EQ 'A' THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN

*****
INIT:
*****

    FN.REDO.T.AUTH.ARRANGEMENT = "F.REDO.T.AUTH.ARRANGEMENT"
    F.REDO.T.AUTH.ARRANGEMENT = ""
    R.REDO.T.AUTH.ARRANGEMENT = ""
    CALL OPF(FN.REDO.T.AUTH.ARRANGEMENT,F.REDO.T.AUTH.ARRANGEMENT)

RETURN

******
PROCESS:
******
    GOSUB MULTI.GET.LOC.REF
    GOSUB UPDATE.RECORD

RETURN
*************
UPDATE.RECORD:
*************
    POLICY.STATUS = ''
    INS.REC.DATE = ''
    INS.APPLN.DATE = ''
    POL.STATUS = ''

    POLICY.STATUS  = R.NEW(AA.AC.LOCAL.REF)<1,POLICY.STATUS.POS>
    INS.REC.DATE = R.NEW(AA.AC.LOCAL.REF)<1,INS.REC.DATE.POS>
    INS.APPLN.DATE  = R.NEW(AA.AC.LOCAL.REF)<1,INS.APPLN.DATE.POS>
    POL.STATUS  = R.NEW(AA.AC.LOCAL.REF)<1,POLICY.STATUS.POS>

RETURN
*
***************
MULTI.GET.LOC.REF:
***************
    APPLICATION = "AA.PRD.DES.CHARGE":@FM:"AA.PRD.DES.CUSTOMER":@FM:"AA.PRD.DES.TERM.AMOUNT":@FM:"AA.PRD.DES.ACCOUNT"  ;** R22 Auto conversion - FM TO @FM
    FIELD.NAME = "CLASS.POLICY":@VM:"INS.POLICY.TYPE":@VM:"POLICY.NUMBER":@VM:"SEN.POL.NUMBER":@VM:"MANAGEMENT.TYPE":@VM:"MON.POL.AMT":@VM:"MON.POL.AMT.DAT":@VM:"EXTRA.AMT":@VM:"MON.TOT.PRE.AMT":@VM:"TOT.PREMIUM.AMT":@VM:"L.AA.CALC.TYPE":@VM:"L.AA.CHG.RATE.POS":@VM:"L.AA.CHG.AMOUNT":@VM:"L.FHA.CASE.NO":@FM:"INS.COMPANY":@VM:"POLICY.ORG.DATE":@VM:"POL.START.DATE":@VM:"POL.EXP.DATE":@VM:"POL.ISSUE.DATE":@VM:"REMARKS":@VM:"L.AA.AFF.COM":@VM:"L.AA.CAMP.TY":@FM:"INS.AMOUNT":@VM:"INS.AMOUNT.DATE":@VM:"L.AA.COL":@VM:"L.AA.MIN.AMOUNT":@VM:"L.AA.MAX.AMOUNT":@VM:"L.AA.MIN.TIME":@VM:"L.AA.MAX.TIME":@VM:"L.AA.COL.VAL":@VM:"L.AA.AV.COL.BAL":@VM:"L.AA.COL.DESC":@FM:"POLICY.STATUS":@VM:"INS.APPLN.DATE":@VM:"INS.REC.DATE"       ;** R22 Auto conversion - FM TO @FM, VM TO @VM
    FIELD.POS = ""
    CALL MULTI.GET.LOC.REF(APPLICATION,FIELD.NAME,FIELD.POS)

    CLASS.POLICY.POS = FIELD.POS<1,1>
    INS.POLICY.TYPE.POS = FIELD.POS<1,2>
    POLICY.NUMBER.POS = FIELD.POS<1,3>
    SEN.POL.NUMBER.POS = FIELD.POS<1,4>
    MANAGEMENT.TYPE.POS = FIELD.POS<1,5>
    MON.POL.AMT.POS = FIELD.POS<1,6>
    MON.POL.AMT.DAT.POS = FIELD.POS<1,7>
    EXTRA.AMT.POS = FIELD.POS<1,8>
    MON.TOT.PRE.AMT.POS = FIELD.POS<1,9>
    TOT.PREMIUM.AMT.POS = FIELD.POS<1,10>
    L.AA.CALC.TYPE.POS = FIELD.POS<1,11>
    L.AA.CHG.RATE.POS = FIELD.POS<1,12>
    L.AA.CHG.AMOUNT.POS = FIELD.POS<1,13>
    L.FHA.CASE.NO.POS = FIELD.POS<1,14>
*
    INS.COMPANY.POS = FIELD.POS<2,1>
    POLICY.ORG.DATE.POS = FIELD.POS<2,2>
    POL.START.DATE.POS = FIELD.POS<2,3>
    POL.EXP.DATE.POS = FIELD.POS<2,4>
    POL.ISSUE.DATE.POS = FIELD.POS<2,5>
    REMARKS.POS = FIELD.POS<2,6>
    L.AA.AFF.COM.POS = FIELD.POS<2,7>
    L.AA.CAMP.TY.POS = FIELD.POS<2,8>
*
    INS.AMOUNT.POS = FIELD.POS<3,1>
    INS.AMOUNT.DATE.POS = FIELD.POS<3,2>
    L.AA.COL.POS = FIELD.POS<3,3>
    L.AA.MIN.AMOUNT.POS = FIELD.POS<3,4>
    L.AA.MAX.AMOUNT.POS = FIELD.POS<3,5>
    L.AA.MIN.TIME.POS = FIELD.POS<3,6>
    L.AA.MAX.TIME.POS = FIELD.POS<3,7>
    L.AA.COL.VAL.POS = FIELD.POS<3,8>
    L.AA.AV.COL.BAL.POS = FIELD.POS<3,9>
    L.AA.COL.DESC.POS = FIELD.POS<3,10>
*
    POLICY.STATUS.POS = FIELD.POS<4,1>
    INS.APPLN.DATE.POS = FIELD.POS<4,2>
    INS.REC.DATE.POS = FIELD.POS<4,3>

RETURN
END
