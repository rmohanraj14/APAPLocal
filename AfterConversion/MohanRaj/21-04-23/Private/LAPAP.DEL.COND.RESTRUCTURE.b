* @ValidationCode : MjoxMzQxMDc5OTIzOkNwMTI1MjoxNjgyMDc4NDM1ODYyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 17:30:35
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
SUBROUTINE LAPAP.DEL.COND.RESTRUCTURE(ARR.ID)
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This routine is the record routine of the batch job REDO.B.LOAN.STATUS.ELIMINATION
* This routine updates the local reference fields Loan Status and Loan Condition
*
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  :
*  ARR.ID - Arrangement id
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who                Reference                  Description
* 07-JUN-2010   N.Satheesh Kumar     TAM-ODR-2009-10-0331          Initial Creation
* 09-Dec-2010   Krishna Murthy T.S   TAM-ODR-2009-10-1678(B.10)    Modified to update the LOCAL field
* 28-APR-2011      H GANESH           CR009                        Change the Vetting value of local field.                                                                 LOAN.CONDITION in AA.ARR.OVERDUE
* 23-01-2012      JEEVA T             COB PERFOMANCE
* 02-02-2012      JEEVA T             Write-off is removed         PACS00179027
* 14-03-2012      JEEVA T             Restructed Logic has been
*                                     Changed
* Marimuthu S     Marimuthu S         PACS00184897                 Logic changed to change the staus
* 16-07-2012      Marimuthu S         ODR-2012-01-0106             Logic changed for Linear & Actual payments
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1,-- TO -=1,= TO EQ
*21-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.OFS.PARAM
    $INSERT I_F.REDO.LOAN.CHQ.RETURN
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

    $INSERT I_F.REDO.APAP.LOAN.CHEQUE.DETAILS
    $INSERT I_LOAN.STATUS.ELIMINATION.COMMON
    $INSERT I_F.REDO.APAP.CLEAR.PARAM
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_F.DATES
    $INSERT I_F.AA.PAYMENT.SCHEDULE

    GOSUB INIT
    IF R.Condition THEN
        GOSUB GET.AA.ACCT.DET
        GOSUB PROCESS
    END
RETURN

*----
INIT:
*----
*-----------------------------------------------------------------------------------------------
* This section initialises the necessary variables and get the latest record for the arrangement
*-----------------------------------------------------------------------------------------------

    Y.ARRANGEMENT.ID=ARR.ID
    PROP.CLASS='OVERDUE'
    PROPERTY=''
    R.Condition=''
    ERR.MSG=''
    EFF.DATE = ''
    Y.RES.FALG.UPD = ''
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;*R22 Manual Code Conversion-Call Method Format Modified
    OVERDUE.R.CONDITION=R.Condition
    LOAN.STATUS.LST = R.Condition<AA.OD.LOCAL.REF,AA.LOAN.STATUS.POS>
    LOAN.COND.LST = R.Condition<AA.OD.LOCAL.REF,AA.LOAN.COND.POS>
    LS.CHG.DATE = R.Condition<AA.OD.LOCAL.REF,AA.LS.CHG.DTE.POS>
    LS.COMMENT = R.Condition<AA.OD.LOCAL.REF,AA.LS.COMMENT.POS>
    LC.COMMENT = R.Condition<AA.OD.LOCAL.REF,AA.LC.COMMENT.POS>
    NEW.LOAN.STATUS = LOAN.STATUS.LST
    NEW.LOAN.COND = LOAN.COND.LST
    UPD.FLAG = ''

    Y.ARRANGEMENT.ID = ARR.ID
    PROP.CLASS = 'PAYMENT.SCHEDULE'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    EFF.DATE = ''
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;*R22 Manual Code Conversion-Call Method Format Modified

    Y.MIG.LOAN = R.Condition<AA.PS.LOCAL.REF,AA.MIG.POS>

RETURN
*-------
PROCESS:
*-------

* Y.LS.FLAG = ''



    IF LOAN.STATUS.LST NE '' THEN
        GOSUB PROCESS.LOAN.STATUS
    END
    GOSUB PROCESS.LOAN.COND
    GOSUB UPDATE.ARR
RETURN
*-------------------
BILL.PAID.CHECK:
*-------------------
    Y.CNT.LF = ''
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE DCOUNT(AD.BILL.ID,@FM)

        Y.BILL.ID = AD.BILL.ID<Y.CNT>
        GOSUB GET.AA.BILL.DETAILS
        IF PAYMENT.DATE GT Y.CHECK.DATE THEN
            GOSUB GET.ZERO.PRIN
        END
        Y.CNT += 1 ;*R22 Auto code conversion
    REPEAT

RETURN

GET.ZERO.PRIN:

    IF SETTLE.STATUS<1,1> EQ 'REPAID' AND 'PAYMENT' MATCHES BILL.TYPE THEN
        LOCATE 'ACCOUNT' IN Y.AL.PROPS<1,1> SETTING POS.AA THEN
            Y.CNT.LF += 1
        END
    END

RETURN

BILL.PAID.CHECK.1:

    Y.BILL.GEN.FLAG = ''
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE DCOUNT(AD.BILL.ID,@FM)
        Y.BILL.ID = AD.BILL.ID<Y.CNT>
        GOSUB GET.AA.BILL.DETAILS
        IF SETTLE.STATUS<1,1> EQ 'UNPAID' AND 'PAYMENT' MATCHES BILL.TYPE THEN
* LOCATE 'ACCOUNT' IN Y.AL.PROPS<1,1> SETTING POS.AB THEN
            Y.BILL.GEN.FLAG = '1'
            Y.CNT = Y.CNT + DCOUNT(AD.BILL.ID,@FM)
* END
        END
        Y.CNT += 1 ;*R22 Auto code conversion
    REPEAT

RETURN
*-------------------
PROCESS.LOAN.STATUS:
*-------------------

    LS.CNT = DCOUNT(LOAN.STATUS.LST,@SM)
    Y.CHECK.DATE = ''
    LS.POS = ''
    LOOP
    WHILE LS.POS LT LS.CNT DO
        LS.POS += 1
        LOAN.STATUS = LOAN.STATUS.LST<1,1,LS.POS>

*BEGIN CASE

        IF LOAN.STATUS EQ 'JudicialCollection' THEN
            Y.OMIT = 'YES';
            RETURN
*    CASE LOAN.STATUS EQ 'JudicialCollection'
*      GOSUB BILL.PAID.CHECK.1
*      IF NOT(Y.BILL.GEN.FLAG) THEN
*        GOSUB UPDATE.LOAN.STATUS
*      END

*    CASE LOAN.STATUS EQ 'Restructured'
*     IF LOAN.STATUS EQ 'Restructured' THEN

*-------To check 3 consecutive bills ------------*
*GOSUB PROCESS.LS.RESTRUCT
*      CALL F.READ(FN.REDO.AA.LOAN.UPD.STATUS,ARR.ID,R.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS,Y.ER.AR)
*      Y.CHECK.DATE = R.REDO.AA.LOAN.UPD.STATUS
*      IF Y.CHECK.DATE ELSE
*        Y.CHECK.DATE =  LS.CHG.DATE
*      END
*-------To check 3 consecutive bills ------------*
            IF NOT(Y.RES.FALG.UPD) THEN
*-----------TO check unpaid bills -------------*
                GOSUB PROCESS.LS.RESTRUCT.UNPAID.BILL
*-----------TO check unpaid bills -------------*
*      END
            END
        END
*    END CASE
    REPEAT

RETURN
*-------------------
PROCESS.LS.RESTRUCT.UNPAID.BILL:
*-------------------

*IF Y.MIG.LOAN EQ 'YES' THEN
*Y.CHECK.DATE = LS.CHG.DATE
*END ELSE
*Y.CHECK.DATE = R.REDO.AA.LOAN.UPD.STATUS
*END

    GOSUB GET.UNPAID.DET.RES

RETURN
*--------------------------------------
GET.UNPAID.DET.RES:
*--------------------------------------
    Y.NEXT.DAY = R.DATES(EB.DAT.NEXT.WORKING.DAY)
    Y.DT.CNT =1
    LOOP
    WHILE Y.DT.CNT LE DCOUNT(AD.BILL.ID,@FM)
        Y.BILL.ID = AD.BILL.ID<Y.DT.CNT>
        GOSUB GET.AA.BILL.DETAILS
        IF PAYMENT.DATE GT Y.CHECK.DATE THEN
            GOSUB CK.PAY.DATE.1
        END
        Y.DT.CNT += 1 ;*R22 Auto code conversion
    REPEAT
RETURN

CK.PAY.DATE.1:

    IF 'PAYMENT' MATCHES BILL.TYPE AND SETTLE.STATUS<1,1> EQ 'UNPAID' THEN
        LOCATE 'ACCOUNT' IN Y.AL.PROPS<1,1> SETTING POS.A THEN
            Y.DAYS.PARA = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RES.TO.NORM.DAYS>
            REGION = ""
            GET.DAYS = "C"
            Y.ACT.DATE = PAYMENT.DATE
            CALL CDD(REGION,Y.ACT.DATE,Y.NEXT.DAY,GET.DAYS)
            IF GET.DAYS GT Y.DAYS.PARA THEN
                GOSUB UPDATE.LOAN.STATUS
                Y.DT.CNT = DCOUNT(AD.BILL.ID,@FM) + 1
            END
        END
    END

RETURN
*-------------------
PROCESS.LS.RESTRUCT:
*-------------------
* Y.FLAG.RES.CHANGE = ''
* Y.CHECK.DATE = ''
* BILL.FLAG = 1

    IF Y.MIG.LOAN EQ 'YES' THEN
        Y.CHECK.DATE = LS.CHG.DATE
    END ELSE
        CALL F.READ(FN.REDO.AA.LOAN.UPD.STATUS,ARR.ID,R.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS,Y.ER.AR)
        Y.CHECK.DATE = R.REDO.AA.LOAN.UPD.STATUS
        IF NOT(Y.CHECK.DATE) THEN
            Y.CHECK.DATE = TODAY
        END
    END
* CHK.DATES = ''

    GOSUB BILL.CHECK.RES

RETURN
*----------------------------------
BILL.CHECK.RES:
*----------------------------------

    GOSUB BILL.PAID.CHECK

    IF Y.CNT.LF GE 3 THEN
        GOSUB UPDATE.LOAN.STATUS
        IF R.REDO.AA.LOAN.UPD.STATUS THEN
            CALL F.DELETE(FN.REDO.AA.LOAN.UPD.STATUS,ARR.ID)
        END
        Y.RES.FALG.UPD = '1'
    END

RETURN
*-----------------
PROCESS.LOAN.COND:
*-----------------
    IF Y.OMIT EQ 'YES' THEN
        RETURN
    END

    LC.CNT = DCOUNT(LOAN.COND.LST,@SM)
    LC.POS = ''
    LOOP
    WHILE LC.POS LT LC.CNT DO
        LC.POS += 1
        LOAN.COND = LOAN.COND.LST<1,1,LC.POS>
        BEGIN CASE
            CASE LOAN.COND EQ 'Legal'
                GOSUB BILL.PAID.CHECK.1
                IF NOT(Y.BILL.GEN.FLAG) THEN
                    GOSUB UPDATE.LOAN.COND
                END
            CASE LOAN.COND EQ 'ThreeReturnedChecks'
                GOSUB CK.3.RETURN.CQ
        END CASE
    REPEAT

* GOSUB REGISTER.THREE.RTN.CHQ

RETURN

CK.3.RETURN.CQ:

    R.REDO.APAP.LOAN.CHEQUE.DETAILS = ''
    DROP.FLAG = 1
    CALL F.READ(FN.REDO.APAP.LOAN.CHEQUE.DETAILS,ARR.ID,R.REDO.APAP.LOAN.CHEQUE.DETAILS,F.REDO.APAP.LOAN.CHEQUE.DETAILS,LCHEQUE.ERR)
    ACT.CHQUE.RTN.CNT = DCOUNT(R.REDO.APAP.LOAN.CHEQUE.DETAILS<CHQ.DET.CHQ.RET.COUNT>,@VM)
    CHQ.CNT = ''
    LOOP
    WHILE CHQ.CNT LT 3 DO
        CHQ.CNT += 1
        CHQ.STATUS = R.REDO.APAP.LOAN.CHEQUE.DETAILS<CHQ.DET.CHQ.STATUS,ACT.CHQUE.RTN.CNT,1>
        IF CHQ.STATUS NE 'DROPPED' THEN
            DROP.FLAG = 0
        END
        ACT.CHQUE.RTN.CNT -= 1 ;*R22 Auto code conversion
    REPEAT
    IF DROP.FLAG THEN
        GOSUB UPDATE.LOAN.COND
    END

RETURN

*----------------------
*REGISTER.THREE.RTN.CHQ:
*----------------------

*  TODAY.DATE = TODAY
*  DIFF.DAYS = 'C'
*  LOCATE 'ThreeReturnedChecks' IN LOAN.COND.LST<1,1,1> SETTING THREE.RTN.POS THEN
*      RETURN
*  END
*  R.REDO.LOAN.CHQ.RETURN = ''
*  Y.LCR.ERR = ''
*  CALL F.READ(FN.REDO.LOAN.CHQ.RETURN,ARR.ID,R.REDO.LOAN.CHQ.RETURN,F.REDO.LOAN.CHQ.RETURN,Y.LCR.ERR)
*  IF R.REDO.LOAN.CHQ.RETURN THEN

*Updating LOAN.CONDITION field with 'ThreeReturnedChecks'
*     ACT.CHQUE.RTN.CNT = R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.CHEQUE.RET.CTR>
*     MAX.RET.CHQ = R.REDO.APAP.CLEAR.PARAM<CLEAR.PARAM.MAX.RET.CHEQUES>

*     IF ACT.CHQUE.RTN.CNT GE MAX.RET.CHQ THEN
*         NEW.LOAN.COND<1,1,-1> = 'ThreeReturnedChecks'
*         LC.COMMENT<1,1,-1> = ''
*     END

*Eliminating 'ThreeReturnedChecks' condition for Loans
*     Y.CHQ.STATUS.LIST = R.REDO.LOAN.CHQ.RETURN<LN.CQ.RET.CHEQUE.STATUS>
*     Y.CHQ.CNT = DCOUNT(Y.CHQ.STATUS.LIST,VM)
*     Y.CNTR = 0
*     LOOP
*         Y.CNTR += 1
*     WHILE Y.CNTR LE 3
*         GOSUB CK.LE.3
*     REPEAT

* END

*ODR2009101678-END.1

*   RETURN

*CK.LE.3:

*  IF Y.CHQ.CNT GE 1 THEN
*       Y.CHQ.STATUS = Y.CHQ.STATUS.LIST<1,Y.CHQ.CNT>
*       Y.CHQ.CNT -= 1
*       IF Y.CHQ.STATUS EQ 'DROPPED' THEN
*           Y.CNTR = 4
*           NEW.LOAN.COND<1,1,-1> = ''
*           LC.COMMENT<1,1,-1> = ''
*       END
*   END

*   RETURN

*---------------
GET.AA.ACCT.DET:
*---------------

    R.AA.ACCOUNT.DETAILS = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ACC.DET.ERR)
    AD.ARR.AGE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.ARR.AGE.STATUS>

    AD.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    CHANGE @SM TO @FM IN AD.BILL.ID
    CHANGE @VM TO @FM IN AD.BILL.ID

RETURN

*-------------------
GET.AA.BILL.DETAILS:
*-------------------

    BILL.TYPE = ''
    SETTLE.STATUS = ''
    AGING.STATUS = ''
    PAYMENT.DATE = '' ; Y.AL.PROPS = ''
    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,AA.DB.ERR)
    BILL.TYPE = R.AA.BILL.DETAILS<AA.BD.BILL.TYPE>
    SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS>
    AGING.STATUS = R.AA.BILL.DETAILS<AA.BD.AGING.STATUS>
    PAYMENT.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>
    Y.AL.PROPS = R.AA.BILL.DETAILS<AA.BD.PROPERTY>

RETURN

*------------------
UPDATE.LOAN.STATUS:
*------------------

    LOCATE LOAN.STATUS IN NEW.LOAN.STATUS<1,1,1> SETTING CUR.LS.POS THEN

        NEW.LOAN.STATUS<1,1,CUR.LS.POS> = 'Normal'
        LS.CHG.DATE<1,1,CUR.LS.POS> = 'NULL'
        LS.COMMENT<1,1,CUR.LS.POS>  = 'NULL'

    END
RETURN

*----------------
UPDATE.LOAN.COND:
*----------------

    LOCATE LOAN.COND IN NEW.LOAN.COND<1,1,1> SETTING CUR.LC.POS THEN

        NEW.LOAN.COND<1,1,CUR.LC.POS> = 'NULL'
        LC.COMMENT<1,1,CUR.LC.POS>    = 'NULL'

    END
RETURN

*----------
UPDATE.ARR:
*----------
*CHECK THE STRING
    OVERDUE.R.CONDITION = ''
    IF NEW.LOAN.STATUS NE LOAN.STATUS.LST THEN
        OVERDUE.R.CONDITION<AA.OD.LOCAL.REF,AA.LOAN.STATUS.POS>= NEW.LOAN.STATUS
        OVERDUE.R.CONDITION<AA.OD.LOCAL.REF,AA.LS.CHG.DTE.POS>= LS.CHG.DATE
        OVERDUE.R.CONDITION<AA.OD.LOCAL.REF,AA.LS.COMMENT.POS>= LS.COMMENT
        UPD.FLAG = 1
    END
    IF NEW.LOAN.COND NE LOAN.COND.LST THEN
        OVERDUE.R.CONDITION<AA.OD.LOCAL.REF,AA.LOAN.COND.POS>= NEW.LOAN.COND
        OVERDUE.R.CONDITION<AA.OD.LOCAL.REF,AA.LC.COMMENT.POS>= LC.COMMENT
        UPD.FLAG = 1
    END
    IF UPD.FLAG EQ 1 THEN
        GOSUB STRING.FORM
    END
RETURN

*----------
STRING.FORM:
*----------

    APP.NAME = 'AA.ARR.OVERDUE'
    OFSFUNCT=''
    PROCESS  = ''
    OFSVERSION = ''
    GTSMDE = ''
    TRANSACTION.ID=''
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    NO.OF.AUTH = ''
    OFS.STRING =''
    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMDE,NO.OF.AUTH,TRANSACTION.ID,OVERDUE.R.CONDITION,OFSRECORD)
    CHANGE ',' TO @FM IN OFSRECORD
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    FIELD.COUNT=DCOUNT(OFSRECORD,@FM)
    VAR1=1
    LOOP
    WHILE VAR1 LE FIELD.COUNT
        IF OFSRECORD<VAR1> THEN
            OFS.STRING:='FIELD.NAME:1:':VAR1:'=':FIELD(OFSRECORD<VAR1>,'=',1):','
            OFS.STRING:='FIELD.VALUE:1:':VAR1:'=':FIELD(OFSRECORD<VAR1>,'=',2):','
        END
        VAR1 += 1
    REPEAT
*CALL CACHE.READ(FN.REDO.OFS.PARAM,ID.COMPANY,R.REDO.OFS.PARAM,PARAM.ERR)
*Y.USERNAME= R.REDO.OFS.PARAM<REDO.OFS.USER.NAME>
*Y.PASSWORD= R.REDO.OFS.PARAM<REDO.OFS.USER.PASSWORD>
*OFS.SRC = R.REDO.OFS.PARAM<REDO.OFS.OFS.SOURCE.ID>
    OFS.SRC = 'AA.COB'
    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    GOSUB GET.PROPERTY
    ACT.ID = "LENDING-UPDATE-":OD.PROPERTY
    OPTIONS = ''
    OFS.MSG.ID = ''
    OFS.STRING.FINAL="AA.ARRANGEMENT.ACTIVITY,APAP/I/PROCESS,,,ARRANGEMENT:1:1=":Y.ARRANGEMENT.ID:",ACTIVITY:1:1=":ACT.ID:",EFFECTIVE.DATE:1:1=":TODAY:',PROPERTY:1:1=':OD.PROPERTY:',':OFS.STRING
    CALL OFS.POST.MESSAGE(OFS.STRING.FINAL,OFS.MSG.ID,OFS.SRC,OPTIONS)

RETURN
*----------------------------------------------------------------------------------------------
***********************
GET.PROPERTY:
***********************
    IN.PROPERTY.CLASS = 'OVERDUE'
    CALL APAP.TAM.REDO.GET.PROPERTY.NAME(Y.ARRANGEMENT.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OD.PROPERTY,OUT.ERR) ;*R22 Manual Code Conversion-Call Method Format Modified

RETURN
END
