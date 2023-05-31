* @ValidationCode : MjoxODI1ODIwNTI0OkNwMTI1MjoxNjg1NTI5NDcwNjU5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:07:50
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
$PACKAGE APAP.AA
SUBROUTINE REDO.B.INT.UPDATE(ARR.ID)
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.B.INT.UPDATE
*--------------------------------------------------------------------------------
* Description: This is the Main routine in batch to update the interest rate in arrangement
* as per the changes in rate of AZ.ACCOUNT OR ACI OR GCI
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE        WHO              REFERENCE            DESCRIPTION
*  ----------  -------------    ----------------     ------------
*  15.11.2009  H GANESH &       ODR-2009-10-0795     INITIAL CREATION
*              S SUDHARSANAN
*  13.05.2011  H GANESH         PACS00032743 &       Modified as per issue
*                               PACS00055013
* 21-Nov-2011  Luis Pazmino     ODR-2011-06-0242     Minor fixes to obtain the ACCOUNT.ID
*                                                    when a COLLATERAL is created through FC
* 29-MAR-2023      Conversion Tool       R22 Auto Conversion  - VM to @VM , FM to @FM and ++ to +=1 , -- to -=1
* 29-MAR-2023      Harsha                R22 Manual Conversion - CALL method format changed
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.GROUP.DATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_REDO.B.INT.UPDATE.COMMON
    $USING APAP.TAM

    GOSUB INIT
    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------------
    Y.INT.DETAILS = ''
    Y.COLLATERAL.IDS = ''
RETURN
*----------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------
    CALL OCOMO("Processing the arrangement - ":ARR.ID)
    GOSUB GET.RATE.REVIEW.TYPE          ;* This part gets the Loan review type.
    IF Y.PRIN.RATE.REV.TYPE EQ 'BACK.TO.BACK' ELSE
        CALL OCOMO("Loan is not BACK TO BACK TYPE - ":ARR.ID)
        RETURN
    END

    CALL F.READ(FN.ARRANGEMENT,ARR.ID,R.ARRANGEMENT,F.ARRANGEMENT,ARR.ERR)
    Y.CUSTOMER.ID = R.ARRANGEMENT<AA.ARR.CUSTOMER>
    GOSUB GET.LIMIT.REF       ;* This part to get Limit Ref

    IF Y.LIMIT.REFERENCE EQ '' THEN
        CALL OCOMO("Limit Ref Missing - ":ARR.ID)
        RETURN
    END ELSE
*AA Changes 20161013
*        REF.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',1,1),"7'0'R")
*        SEQ.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',2,1),"2'0'R")
        REF.NO = FMT(Y.LIMIT.REFERENCE,"7'0'R")
        SEQ.NO = FMT(Y.LIMIT.SERIAL,"2'0'R")
*AA Changes 20161013
        Y.LIMIT.ID = Y.CUSTOMER.ID:".":REF.NO:".":SEQ.NO
    END
    CALL F.READ(FN.LI.COLLATERAL.RIGHT,Y.LIMIT.ID,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,ERR.LI.COLLATERAL.RIGHT)

    Y.LI.COL.CNT=DCOUNT(R.LI.COLLATERAL.RIGHT,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.LI.COL.CNT
        Y.COLLATERAL.RIGHT.ID=R.LI.COLLATERAL.RIGHT<Y.VAR1>
        CALL F.READ(FN.RIGHT.COLLATERAL,Y.COLLATERAL.RIGHT.ID,R.RIGHT.COLLATERAL.ARR,F.RIGHT.COLLATERAL,ERR.RIGHT.COLLATERAL)
        Y.COLLATERAL.IDS<-1>=R.RIGHT.COLLATERAL.ARR
        Y.VAR1 += 1
    REPEAT

    GOSUB COMPARE.INTEREST    ;* Here we compare the interest rates.

RETURN
*----------------------------------------------------------------------------
COMPARE.INTEREST:
*----------------------------------------------------------------------------

    Y.COLLATERAL.CNT=DCOUNT(Y.COLLATERAL.IDS,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.COLLATERAL.CNT
        Y.ACCOUNT.ID = ''
        Y.COLL.ID    = Y.COLLATERAL.IDS<Y.VAR1>
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,ERR.COLLATERAL)
        Y.ACCOUNT.ID = R.COLLATERAL<COLL.APPLICATION.ID>

* lfpazmino / 11.21.2011
* In case of using collaterals created by Fabrica de Credito interface
* there is a local field which holds the account number, since APPLICATION.ID
* is not used due to specific user's requirements

        IF Y.ACCOUNT.ID EQ '' THEN
            Y.ACCOUNT.ID = R.COLLATERAL<CL.LOCAL.REF,CL.INST.POS>
        END
        IF Y.ACCOUNT.ID THEN
            GOSUB GET.INTEREST.DETAILS
        END ELSE
            CALL OCOMO("Collateral Acc Missing for collateral - ":Y.COLL.ID:" - ":ARR.ID)
        END
        Y.VAR1 += 1
    REPEAT

    GOSUB FINAL.UPDATE

RETURN
*----------------------------------------------------------------------------
GET.INTEREST.DETAILS:
*----------------------------------------------------------------------------

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    IF R.ACCOUNT<AC.ALL.IN.ONE.PRODUCT> THEN
        GOSUB AZ.PROCESS
    END ELSE
        GOSUB ACC.PROCESS
    END

RETURN
*----------------------------------------------------------------------------
AZ.PROCESS:
*----------------------------------------------------------------------------

    CALL F.READ(FN.AZ.ACCOUNT,Y.ACCOUNT.ID,R.AZ.ACCOUNT,F.AZ.ACCOUNT,ERR.AZ.ACCOUNT)
    Y.AZ.INTEREST.RATE = R.AZ.ACCOUNT<AZ.INTEREST.RATE>
    Y.ROLLOVER.DATE    = R.AZ.ACCOUNT<AZ.VALUE.DATE>
    IF Y.AZ.INTEREST.RATE AND Y.ROLLOVER.DATE THEN
        Y.INT.DETAILS<1,-1> = Y.AZ.INTEREST.RATE
        Y.INT.DETAILS<2,-1> = Y.ROLLOVER.DATE
    END
RETURN
*----------------------------------------------------------------------------
ACC.PROCESS:
*----------------------------------------------------------------------------
    GOSUB GET.ACI.DATE
    IF Y.ACI.ID THEN          ;* In case of ACI record exist.
        GOSUB GET.ACI.RATE
    END ELSE        ;* In case of GCI record
        GOSUB GET.GCI.DATE
        GOSUB GET.GCI.RATE
    END

RETURN

*----------------------------------------------------------------------------
GET.ACI.DATE:
*----------------------------------------------------------------------------
    Y.ACI.ID = ''
    Y.ACI.DATE = R.ACCOUNT<AC.ACCT.CREDIT.INT>
    IF Y.ACI.DATE ELSE
        RETURN
    END
    Y.CNT1 = 0
    Y.ACI.DATE.CNT = DCOUNT(Y.ACI.DATE,@VM)
    LOOP
    WHILE Y.ACI.DATE.CNT GT Y.CNT1
        IF Y.ACI.DATE<1,Y.ACI.DATE.CNT> LE TODAY THEN
            Y.ACI.ID = Y.ACCOUNT.ID:'-':Y.ACI.DATE<1,Y.ACI.DATE.CNT>
            Y.ACI.DATE.CNT = 0          ;* Break
        END

        Y.ACI.DATE.CNT -= 1    ;*R22 Auto Conversion
    REPEAT

RETURN
*----------------------------------------------------------------------------
GET.ACI.RATE:
*----------------------------------------------------------------------------

    Y.ACI.CUR=R.ACCOUNT<AC.CURRENCY>
    APAP.TAM.redoGetHighAci(Y.ACI.ID,Y.ACI.CUR,Y.RATE.ACI);* R22 Manual conversion
    Y.INT.DETAILS<1,-1> =  Y.RATE.ACI
    Y.INT.DETAILS<2,-1> =  FIELD(Y.ACI.ID,'-',2)

RETURN
*----------------------------------------------------------------------------
GET.GCI.DATE:
*----------------------------------------------------------------------------
    Y.GCI.REC.DATE = ''
    Y.CONDITION.GROUP = R.ACCOUNT<AC.CONDITION.GROUP>
    Y.GCI.CUR         = R.ACCOUNT<AC.CURRENCY>
    Y.COND.AND.CURR   = Y.CONDITION.GROUP:Y.GCI.CUR
    CALL F.READ(FN.GROUP.DATE,Y.COND.AND.CURR,R.GROUP.DATE,F.GROUP.DATE,GROUP.ERR)
    Y.GCI.DATE        = R.GROUP.DATE<AC.GRD.CREDIT.DATES>
    Y.GCI.DATE.CNT    = DCOUNT(Y.GCI.DATE,@VM)
    LOOP
    WHILE Y.GCI.DATE.CNT GT 0
        IF Y.GCI.DATE<1,Y.GCI.DATE.CNT> LE TODAY THEN
            Y.GCI.ID = Y.COND.AND.CURR:Y.GCI.DATE<1,Y.GCI.DATE.CNT>
            Y.GCI.REC.DATE = Y.GCI.DATE<1,Y.GCI.DATE.CNT>
            Y.GCI.DATE.CNT = 0
        END
        Y.GCI.DATE.CNT -= 1
    REPEAT

*Y.GCI.ID          = Y.COND.AND.CURR:R.GROUP.DATE<AC.GRD.CREDIT.GROUP.DATE>
    IF Y.GCI.ID ELSE
        CALL OCOMO("GCI record ID not found - ":ARR.ID)
        GOSUB END1
    END
RETURN
*----------------------------------------------------------------------------
GET.GCI.RATE:
*----------------------------------------------------------------------------

    APAP.TAM.redoGetHighGci(Y.GCI.ID,Y.GCI.CUR,Y.RATE.GCI);* R22 Manual conversion
    Y.INT.DETAILS<1,-1> =  Y.RATE.GCI
    Y.INT.DETAILS<2,-1> =  Y.GCI.REC.DATE

RETURN
*----------------------------------------------------------------------------
FINAL.UPDATE:
*----------------------------------------------------------------------------
    Y.COMO.RATE = Y.INT.DETAILS<1>
    Y.COMO.DATE = Y.INT.DETAILS<2>
    CHANGE @VM TO ' ' IN Y.COMO.RATE
    CHANGE @VM TO ' ' IN Y.COMO.DATE
    CALL OCOMO("Rate Details for - ":ARR.ID:" Rate - [ ":Y.COMO.RATE:" ]")
    CALL OCOMO("Date Details for - ":ARR.ID:" Date - [ ":Y.COMO.DATE:" ]")
    IF Y.INT.DETAILS<1> THEN
        GOSUB GET.MAX.RATE.AND.DATE
        IF Y.MAX.RATE THEN
            Y.FINAL.RATE = Y.MAX.RATE
            GOSUB PRINCIPAL.UPDATE
            GOSUB PENALTY.UPDATE
            CALL OCOMO("Processed the loan - ":ARR.ID)
        END ELSE
            CALL OCOMO("No Max interest rate obtained - ":ARR.ID)
        END
    END ELSE
        CALL OCOMO("No interest rate obtained - ":ARR.ID)
    END

RETURN
*----------------------------------------------------------------------------
GET.MAX.RATE.AND.DATE:
*----------------------------------------------------------------------------
    Y.MAX.RATE = ''
    Y.MAX.DATE = ''
    Y.RATE.CNT = DCOUNT(Y.INT.DETAILS<1>,@VM)
    Y.RATE.LOOP = 1
    LOOP
    WHILE Y.RATE.LOOP LE Y.RATE.CNT
        IF Y.MAX.RATE ELSE
            Y.MAX.RATE = Y.INT.DETAILS<1,Y.RATE.LOOP>
            Y.MAX.DATE = Y.INT.DETAILS<2,Y.RATE.LOOP>
            Y.RATE.LOOP += 1   ;*R22 Auto Conversion
            CONTINUE
        END
        IF Y.INT.DETAILS<1,Y.RATE.LOOP> GE Y.MAX.RATE THEN
            GOSUB GET.MAX.RATE.AND.DATE.PART
        END
        Y.RATE.LOOP += 1    ;*R22 Auto Conversion
    REPEAT
    IF Y.MAX.DATE GE R.DATES(EB.DAT.LAST.WORKING.DAY) AND Y.MAX.DATE LE TODAY ELSE        ;* In case Max rate of collateral date is not in range.
        Y.MAX.DATE = TODAY
    END

RETURN
*----------------------------------------------------------------------------
GET.MAX.RATE.AND.DATE.PART:
*----------------------------------------------------------------------------

    IF Y.INT.DETAILS<1,Y.RATE.LOOP> EQ Y.MAX.RATE THEN
        Y.DIFF.DATE1 = ''
        Y.DIFF.DATE2 = ''
        IF Y.MAX.DATE GE R.DATES(EB.DAT.LAST.WORKING.DAY) AND Y.MAX.DATE LE TODAY THEN
            Y.DIFF.DATE1 = Y.MAX.DATE
        END
        IF Y.INT.DETAILS<2,Y.RATE.LOOP> GE R.DATES(EB.DAT.LAST.WORKING.DAY) AND Y.INT.DETAILS<2,Y.RATE.LOOP> LE TODAY THEN
            Y.DIFF.DATE2 = Y.INT.DETAILS<2,Y.RATE.LOOP>
        END
        IF Y.DIFF.DATE1 AND Y.DIFF.DATE2 THEN
            IF Y.DIFF.DATE1 GT Y.DIFF.DATE2 THEN  ;* We need the date which is far from today
                Y.MAX.DATE = Y.DIFF.DATE2
            END ELSE
                Y.MAX.DATE = Y.DIFF.DATE1
            END
        END ELSE
            IF Y.DIFF.DATE1 THEN
                Y.MAX.DATE = Y.DIFF.DATE1
            END
            IF Y.DIFF.DATE2 THEN
                Y.MAX.DATE = Y.DIFF.DATE2
            END

        END
    END ELSE
        Y.MAX.RATE = Y.INT.DETAILS<1,Y.RATE.LOOP>
        Y.MAX.DATE = Y.INT.DETAILS<2,Y.RATE.LOOP>
    END

RETURN
*----------------------------------------------------------------------------
PRINCIPAL.UPDATE:
*----------------------------------------------------------------------------
    Y.CURRENT.RATE = R.PRIN.INT.COND<AA.INT.FIXED.RATE,1,1>
    IF Y.FINAL.RATE NE Y.CURRENT.RATE THEN

        R.PRIN.INT.COND.OFS = ''
        Y.FIXED.RATE.CNT=DCOUNT(R.PRIN.INT.COND<AA.INT.FIXED.RATE>,@VM)
        Y.VAR2=1
        LOOP
        WHILE Y.VAR2 LE Y.FIXED.RATE.CNT
            R.PRIN.INT.COND.OFS<AA.INT.FIXED.RATE,Y.VAR2>=Y.FINAL.RATE
            R.PRIN.INT.COND.OFS<AA.INT.FLOATING.INDEX,Y.VAR2>=''
            Y.VAR2 += 1   ;*R22 Auto Conversion
        REPEAT
        Y.ACT.PROP=''
        Y.ACT.PROP<1> = PRINCIPAL.PROP
        Y.ACT.PROP<2> = "LENDING-CHANGE-":PRINCIPAL.PROP
        APAP.AA.redoAaBuildOfs(ARR.ID,R.PRIN.INT.COND.OFS,Y.ACT.PROP,PRIN.OFS.MSG);* R22 Manual conversion
        PRIN.OFS.MSG:='EFFECTIVE.DATE=':Y.MAX.DATE
        OFS.SRC = 'AA.INT.UPDATE'
        OPTIONS = ''
        CALL OFS.POST.MESSAGE(PRIN.OFS.MSG,OFS.MSG.ID,OFS.SRC,OPTIONS)
        CALL OCOMO("OFS Posted principal interest rate - ":ARR.ID:"-":Y.FINAL.RATE:",":Y.MAX.DATE)
    END ELSE
        CALL OCOMO("No Change in principal interest rate - ":ARR.ID)
    END

RETURN
*----------------------------------------------------------------------------
PENALTY.UPDATE:
*----------------------------------------------------------------------------
    Y.PENAL.CURRENT.RATE = R.PENAL.INT.COND<AA.INT.FIXED.RATE,1,1>
    IF Y.FINAL.RATE NE Y.PENAL.CURRENT.RATE THEN
        R.PENAL.INT.COND.OFS = ''
        Y.FIXED.RATE.CNT=DCOUNT(R.PENAL.INT.COND<AA.INT.FIXED.RATE>,@VM)
        Y.VAR2=1
        LOOP
        WHILE Y.VAR2 LE Y.FIXED.RATE.CNT

            R.PENAL.INT.COND.OFS<AA.INT.FIXED.RATE,Y.VAR2>=Y.FINAL.RATE
            R.PENAL.INT.COND.OFS<AA.INT.FLOATING.INDEX,Y.VAR2>=''
            Y.VAR2 += 1  ;*R22 Auto Conversion
        REPEAT
        Y.ACT.PROP=''
        Y.ACT.PROP<1> = PENALTY.PROP
        Y.ACT.PROP<2> = "LENDING-CHANGE-":PENALTY.PROP
        APAP.AA.redoAaBuildOfs(ARR.ID,R.PENAL.INT.COND.OFS,Y.ACT.PROP,PENAL.OFS.MSG);* R22 Manual conversion
        PENAL.OFS.MSG:='EFFECTIVE.DATE=':Y.MAX.DATE
        OFS.SRC = 'AA.INT.UPDATE'
        OPTIONS = ''
        CALL OFS.POST.MESSAGE(PENAL.OFS.MSG,OFS.MSG.ID,OFS.SRC,OPTIONS)
        CALL OCOMO("OFS Posted penalty interest rate - ":ARR.ID:"-":Y.FINAL.RATE:",":Y.MAX.DATE)
    END ELSE
        CALL OCOMO("No Change in penalty interest rate - ":ARR.ID)
    END

RETURN
*----------------------------------------------------------------------------
GET.LIMIT.REF:
*----------------------------------------------------------------------------
* This part gets the Limit reference of that arrangement

    EFF.DATE   = ''
    PROP.CLASS = 'LIMIT'
    PROPERTY   = ''
    R.CONDITION = ''
    ERR.MSG    = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
    Y.LIMIT.REFERENCE = R.CONDITION<AA.LIM.LIMIT.REFERENCE>
*AA Changes 20161013
    Y.LIMIT.SERIAL = R.CONDITION<AA.LIM.LIMIT.SERIAL>
*AA Changes 20161013
RETURN
*----------------------------------------------------------------------------
GET.RATE.REVIEW.TYPE:
*----------------------------------------------------------------------------

    PROP.NAME   = 'PRINCIPAL'
    APAP.TAM.redoGetInterestProperty(ARR.ID,PROP.NAME,PRINCIPAL.PROP,ERR);* R22 Manual conversion
    EFF.DATE    = ''
    PROP.CLASS  = 'INTEREST'
    R.PRIN.INT.COND=''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PRINCIPAL.PROP,R.PRIN.INT.COND,ERR.MSG);* R22 Manual conversion
    Y.PRIN.RATE.REV.TYPE=R.PRIN.INT.COND<AA.INT.LOCAL.REF,POS.L.AA.REV.RT.TY>

    PROP.NAME='PENALTY'
    APAP.TAM.redoGetInterestProperty(ARR.ID,PROP.NAME,PENALTY.PROP,ERR);* R22 Manual conversion
    EFF.DATE = ''
    PROP.CLASS='INTEREST'
    R.PENAL.INT.COND=''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PENALTY.PROP,R.PENAL.INT.COND,ERR.MSG);* R22 Manual conversion

RETURN
END1:
END
