* @ValidationCode : MjotMTIyMTc1Nzk4OkNwMTI1MjoxNjg1NTMxODE4OTg0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:46:58
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
$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.PRE.CHEQ.CHARGE
*-------------------------------------------------------------
* Description: This is a Post-Routine for LENDING-CHANGE-CHARGE Activity
* to write the charge property name in Bill and Post an OFS message for LENDING-ADJUST.BILL-BALANCE.MAINTENANCE
* activity.

*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : ACTIVITY.API
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
*  16-01-2012    S.MARIMUTHU             PACS00170057                        Initial draft
*---------------------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                         Descripition
* 29-03-2023   Conversion Tool        Auto R22 Code Conversion                  FM TO @FM ,VM TO @VM, SM TO @SM
* 29-03-2023     Samaran T            Manual R22 Code Conversion                Package Name Added APAP.AA,CALL method format changed
*---------------------------------------------------------------------------------------------

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
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_F.REDO.LOAN.CHQ.RETURN

    IF c_aalocActivityStatus EQ 'UNAUTH' THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN
*------------------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------------------

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT  = ''
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.REDO.H.AA.DIS.CHG = 'F.REDO.H.AA.DIS.CHG'
    F.REDO.H.AA.DIS.CHG = ''

    FN.AC.BALANCE.TYPE = 'F.AC.BALANCE.TYPE'
    F.AC.BALANCE.TYPE = ''
    CALL OPF(FN.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE)

    FN.REDO.CONC.NEXT.ARR.BILL = 'F.REDO.CONC.NEXT.ARR.BILL'
    F.REDO.CONC.NEXT.ARR.BILL = ''
    CALL OPF(FN.REDO.CONC.NEXT.ARR.BILL,F.REDO.CONC.NEXT.ARR.BILL)

    FN.REDO.LOAN.CHQ.RETURN = 'F.REDO.LOAN.CHQ.RETURN'
    F.REDO.LOAN.CHQ.RETURN  = ''
    CALL OPF(FN.REDO.LOAN.CHQ.RETURN,F.REDO.LOAN.CHQ.RETURN)

    LOC.REF.APPLICATION="AA.PRD.DES.CHARGE":@FM:"AA.PRD.DES.BALANCE.MAINTENANCE"
    LOC.REF.FIELDS='L.PENALTY.FREQ':@FM:'L.BILL.REF':@VM:'L.BILL.AMOUNT'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.PENALTY.FREQ = LOC.REF.POS<1,1>
    POS.L.BILL.REF     = LOC.REF.POS<2,1>
    POS.L.BILL.AMOUNT  = LOC.REF.POS<2,2>

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------
* Here the Main process Begin.

    ARR.ID       = c_aalocArrId ;* Arrangement ID
    Y.PRODUCT.ID = c_aalocArrProductId    ;* Product ID

    CALL CACHE.READ(FN.REDO.H.AA.DIS.CHG,'SYSTEM',R.REDO.H.AA.DIS.CHG,PROP.PARAM.ERR)
    IF R.REDO.H.AA.DIS.CHG THEN
        Y.CHQ.PROPERTY         = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RET.CHQ.CHARGE>   ;* Cheque Charge Property
        Y.BALANCE.MAIN.PROPERTY = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.BALANCE.MAIN.PROP>         ;* Balance Main Property
    END ELSE
        RETURN
    END

    LOCATE Y.CHQ.PROPERTY IN c_aalocProductRecord<AA.PRD.PROPERTY,1> SETTING PP.POS ELSE
        GOSUB END1
    END
    LOCATE Y.BALANCE.MAIN.PROPERTY IN c_aalocProductRecord<AA.PRD.PROPERTY,1> SETTING PP.POS ELSE
        GOSUB END1
    END

    R.AA.ACCOUNT.DETAILS = c_aalocAccountDetails    ;* AA.ACCOUNT.DETAILS record.

    GOSUB GET.BILL.ID ;* To get the Bill ID for which the aging activity triggers.

    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)

    IF R.BILL.DETAILS THEN
        IF c_aalocActivityStatus EQ 'UNAUTH' THEN

            LOCATE Y.CHQ.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS ELSE
                R.BILL.DETAILS<AA.BD.PROPERTY,-1> = Y.CHQ.PROPERTY
                R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,-1> = 0
                R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,-1> = 0
*R.BILL.DETAILS<AA.BD.PAY.PROPERTY,DCOUNT(R.BILL.DETAILS<AA.BD.PAY.PROPERTY>,VM),-1> = Y.CHQ.PROPERTY
*R.BILL.DETAILS<AA.BD.OR.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OR.PR.AMT>,VM),-1> = 0
*R.BILL.DETAILS<AA.BD.OS.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OS.PR.AMT>,VM),-1> = 0
                R.BILL.DETAILS<AA.BD.PAYMENT.TYPE,DCOUNT(R.BILL.DETAILS<AA.BD.PAYMENT.TYPE>,@VM)+1> = 'COMCKDEV'
                R.BILL.DETAILS<AA.BD.PAY.PROPERTY,DCOUNT(R.BILL.DETAILS<AA.BD.PAY.PROPERTY>,@VM)+1,-1> = Y.CHQ.PROPERTY
                R.BILL.DETAILS<AA.BD.OR.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OR.PR.AMT>,@VM)+1,-1> = 0
                R.BILL.DETAILS<AA.BD.OS.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OS.PR.AMT>,@VM)+1,-1> = 0
                CALL F.WRITE(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS)
            END
            GOSUB RAISE.CHARGE
        END

*IF c_aalocActivityStatus EQ 'AUTH' THEN
*GOSUB RAISE.CHARGE
*END
    END
RETURN
*----------------------------------------------------------
GET.BILL.ID:
*----------------------------------------------------------
* To get the Bill ID for which the aging activity triggers.
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
            Y.UNPAID.BILLS.CNT += 1 ;*AUTO R22 CODE CONVERSION
        END

        Y.VAR3 += 1 ;*AUTO R22 CODE CONVERSION
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
        Y.VAR4 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    IF Y.BILL.ID EQ '' THEN
        CALL F.READ(FN.REDO.CONC.NEXT.ARR.BILL,ARR.ID,R.REDO.CONC.NEXT.ARR.BILL,F.REDO.CONC.NEXT.ARR.BILL,CON.ERR)
        IF R.REDO.CONC.NEXT.ARR.BILL THEN
            R.REDO.CONC.NEXT.ARR.BILL<-1> = 'NO*'
        END ELSE
            R.REDO.CONC.NEXT.ARR.BILL = 'NO*'
        END
        CALL F.WRITE(FN.REDO.CONC.NEXT.ARR.BILL,ARR.ID,R.REDO.CONC.NEXT.ARR.BILL)
    END

RETURN
*----------------------------------------------------------
RAISE.CHARGE:
*----------------------------------------------------------
* In this part we trigger the LENDING-ADJUST.BILL-BALANCE.MAINTENANCE as a Secondary activity to adjust the bill.

    GOSUB GET.CHARGE.DETAILS
    Y.CHARGE.PER  = R.CONDITION<AA.CHG.FIXED.AMOUNT,1>        ;* Charge Percentage
    GOSUB GET.TOTAL.AMT
    Y.CHARGE.PER = Y.CHARGE.PER * Y.NO.OF.RET.CHQ + R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.REV.RET.AMT>
    IF Y.CHARGE.PER ELSE
        GOSUB END1
    END

    GOSUB POST.OFS
    IF Y.WRITE.FLAG EQ 'YES' THEN
        CALL F.WRITE(FN.REDO.LOAN.CHQ.RETURN,Y.LOAN.NO,R.REDO.LOAN.CHQ.RETURN)
    END
    CALL F.READ(FN.REDO.CONC.NEXT.ARR.BILL,ARR.ID,R.REDO.CONC.NEXT.ARR.BILL,F.REDO.CONC.NEXT.ARR.BILL,CON.ERR)
    IF R.REDO.CONC.NEXT.ARR.BILL THEN
        CALL F.DELETE(FN.REDO.CONC.NEXT.ARR.BILL,ARR.ID)
    END
RETURN
*------------------------------------------------------------------------
GET.TOTAL.AMT:
*------------------------------------------------------------------------
    Y.NO.OF.RET.CHQ = 0
    Y.WRITE.FLAG = ''
    Y.LOAN.NO = c_aalocLinkedAccount
    CALL F.READ(FN.REDO.LOAN.CHQ.RETURN,Y.LOAN.NO,R.REDO.LOAN.CHQ.RETURN,F.REDO.LOAN.CHQ.RETURN,RET.ERR)
    Y.RET.CHQ.REF = R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.CHEQUE.REF>
    Y.RET.FLAG = R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.CHG.FLAG>
    Y.RET.FLAG.CNT = DCOUNT(Y.RET.CHQ.REF,@VM)
    Y.VAR.1 = 1
    LOOP
    WHILE Y.VAR.1 LE Y.RET.FLAG.CNT
        Y.VAR.2 = 1
        Y.SUB.SET = Y.RET.CHQ.REF<1,Y.VAR.1>
        Y.SUB.SET.CNT = DCOUNT(Y.SUB.SET,@SM)
        LOOP
        WHILE Y.VAR.2 LE Y.SUB.SET.CNT
            IF Y.RET.FLAG<1,Y.VAR.1,Y.VAR.2> EQ '' THEN
                R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.CHG.FLAG,Y.VAR.1,Y.VAR.2> = 'YES'
                Y.WRITE.FLAG = 'YES'
                Y.NO.OF.RET.CHQ += 1 ;*AUTO R22 CODE CONVERSION
            END
            Y.VAR.2 += 1 ;*AUTO R22 CODE CONVERSION
        REPEAT
        Y.VAR.1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN
*------------------------------------------------------------------------
POST.OFS:
*------------------------------------------------------------------------
* Here Secondary activity will be triggered.

    ARR.PROPERTY.LIST    = Y.BALANCE.MAIN.PROPERTY
    ARR.FIELD.NAME.LIST  = "LOCAL.REF:":POS.L.BILL.REF:':1':@SM:"LOCAL.REF:":POS.L.BILL.AMOUNT:':1'
    ARR.FIELD.VALUE.LIST = Y.BILL.ID:@SM:Y.CHARGE.PER
    AAA.FIELDS.REC       = ""

    CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)
    NEW.ACTIVITY.ID = 'CHQ.RETURN.CHG'
    RETURN.ERROR = ''
    Y.ACT.DTE = c_aalocActivityEffDate
    Y.ACCT.AA.ID = c_aalocArrActivityId
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, Y.ACT.DTE, "", Y.ACCT.AA.ID, AAA.FIELDS.REC, RETURN.ERROR)
    Y.WRITE.FLAG = 'YES'
    R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.REV.RET.AMT> = 0
RETURN
*------------------------------------------------------------------------
GET.CHARGE.DETAILS:
*------------------------------------------------------------------------

    EFF.DATE = ''
    PROP.CLASS='CHARGE'
    PROPERTY = Y.CHQ.PROPERTY
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
    IF ERR.MSG THEN
        GOSUB END1
    END

RETURN
*------------------------------------------------------------------------
END1:
*------------------------------------------------------------------------
END
