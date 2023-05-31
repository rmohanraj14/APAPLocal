* @ValidationCode : MjotMjA5Mjc5ODE1MjpDcDEyNTI6MTY4MzY5ODQyNjExMTpJVFNTOi0xOi0xOjI1OToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 259
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.B.LOC.UPD.BAL.MAIN(ARR.ID)
*-----------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Marimuthu S
*Program   Name    :REDO.B.LOC.UPD.BAL.MAIN
*----------------------------------------------------------------------------------
*DESCRIPTION       : This is multi-threaded cob routine will fetch the arrangement id from
*                    local template and make charge with scheduled payment for the loan
*---------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who             Reference            Description
* 26-JAN-2012       MARIMUTHU S       PACS00170057         Initial Creation
* 29-MAR-2023      Conversion Tool                R22 Auto Conversion  - VM to @VM , SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
*----------------------------------------------------------------------------
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.PRODUCT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_REDO.B.LOC.UPD.BAL.MAIN.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

MAIN:

    GOSUB PROCESS
    GOSUB PGM.END

PROCESS:


    IF R.REDO.H.AA.DIS.CHG THEN
        Y.CHQ.PROPERTY         = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RET.CHQ.CHARGE>
        Y.BALANCE.MAIN.PROPERTY = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.BALANCE.MAIN.PROP>
    END ELSE
        RETURN
    END
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ACC.ERR)

    GOSUB GET.BILL.ID
    IF Y.BILL.ID THEN
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
    END ELSE
        RETURN
    END

    IF R.BILL.DETAILS THEN
*LOCATE Y.CHQ.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS ELSE
*R.BILL.DETAILS<AA.BD.PROPERTY,-1> = Y.CHQ.PROPERTY
*R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,-1> = 0
*R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,-1> = 0
*R.BILL.DETAILS<AA.BD.PAY.PROPERTY,DCOUNT(R.BILL.DETAILS<AA.BD.PAY.PROPERTY>,VM),-1> = Y.CHQ.PROPERTY
*R.BILL.DETAILS<AA.BD.OR.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OR.PR.AMT>,VM),-1> = 0
*R.BILL.DETAILS<AA.BD.OS.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OS.PR.AMT>,VM),-1> = 0
*CALL F.WRITE(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS)
*END
        GOSUB RAISE.CHARGE
    END

RETURN

GET.BILL.ID:
    Y.BILL.ID = ''
    Y.BILL.IDS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.SETTLE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    CHANGE @SM TO @VM IN Y.BILL.IDS
    CHANGE @SM TO @VM IN Y.SETTLE.STATUS
    Y.BILL.IDS.CNT = DCOUNT(Y.BILL.IDS,@VM)
    Y.UNPAID.BILLS.CNT = 0
    Y.UNPAID.BILLS.IDS = ''
    Y.VAR3 =1
    LOOP
    WHILE Y.VAR3 LE Y.BILL.IDS.CNT
        IF Y.SETTLE.STATUS<1,Y.VAR3> EQ 'UNPAID' THEN
            Y.UNPAID.BILLS.IDS<-1> = Y.BILL.IDS<1,Y.VAR3>
            Y.UNPAID.BILLS.CNT += 1  ;*R22 Auto Conversion
        END

        Y.VAR3 += 1   ;*R22 Auto Conversion
    REPEAT
    Y.VAR4 = 1
    LOOP
    WHILE Y.VAR4 LE Y.UNPAID.BILLS.CNT
        BILL = Y.UNPAID.BILLS.IDS<Y.VAR4>
        CALL F.READ(FN.AA.BILL.DETAILS,BILL,R.BILL,F.AA.BILL.DETAILS,BILL.ERR)
        LOCATE 'PAYMENT' IN R.BILL<AA.BD.BILL.TYPE,1> SETTING AGE.POS THEN
*LOCATE Y.CHQ.PROPERTY IN R.BILL<AA.BD.PROPERTY,1> SETTING POS.PR ELSE
            Y.BILL.ID = BILL        ;* Bill ID for which aging activity triggers.
            Y.VAR4 = Y.UNPAID.BILLS.CNT+1
*END
        END
        Y.VAR4 += 1  ;*R22 Auto Conversion
    REPEAT

RETURN

RAISE.CHARGE:


    Y.RET.CHQ.PROP = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RET.CHQ.CHARGE>

    IF Y.RET.CHQ.PROP THEN
        APP.NAME       = 'AA.ARRANGEMENT.ACTIVITY'
        OFS.FUNCTION   = 'I'
        PROCESS        = 'PROCESS'
        OFS.SOURCE.ID  = 'REDO.CHQ.ISSUE'
        OFSVERSION     = 'AA.ARRANGEMENT.ACTIVITY,APAP'
        GTS.MODE        = ''
        NO.OF.AUTH     = '0'
        TRANSACTION.ID = ''
        R.APP.RECORD   = ''
        OFS.STRING     = ''
        R.APP.RECORD<AA.ARR.ACT.ARRANGEMENT> = ARR.ID
*R.APP.RECORD<AA.ARR.ACT.ACTIVITY> = 'LENDING-CHANGE-':Y.RET.CHQ.PROP
        R.APP.RECORD<AA.ARR.ACT.ACTIVITY> = 'CHQ.RETURN.ACTIVITY'
        R.APP.RECORD<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
        CALL OFS.BUILD.RECORD(APP.NAME,OFS.FUNCTION,PROCESS,OFSVERSION,GTS.MODE,NO.OF.AUTH,TRANSACTION.ID,R.APP.RECORD,OFS.MESSAGE)
        OFS.MSG.ID = ''
        OPTIONS = ''
        OFS.ERR = ''

        CALL OFS.POST.MESSAGE(OFS.MESSAGE,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
    END


RETURN

PGM.END:

END
