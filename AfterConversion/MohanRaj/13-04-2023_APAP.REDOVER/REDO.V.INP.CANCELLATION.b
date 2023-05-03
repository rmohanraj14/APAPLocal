* @ValidationCode : MjoyMDM0NTc5MjE1OkNwMTI1MjoxNjgxMzg5MjYzNTcyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:04:23
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.INP.CANCELLATION
*-----------------------------------------------------------------------------------------------------
* DESCRIPTION : This routine is an input routine attached to below version,
*                COLLATERAL,APAP.CANCELLATION
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* PROGRAM NAME : REDO.V.INP.CANCELLATION
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date             Author             Reference                   Description
* 21-Jul-2010      SUJITHA.S       ODR-2009100344               Inital creation
*14 jun 2011        RIYAS           PACS00054324                MODIFICATION(LINE 135 -161)
*08 AUG 2011       JEEVA T          PACS00054324                MODIFICATION( LINE 41)
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO @FM,VM TO @VM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS

    IF R.NEW(COLL.EXPIRY.DATE) NE "" THEN
        GOSUB INIT
*GOSUB PROCESS
        GOSUB MULTI.COLLATERAL
*        GOSUB PAYMENT.MADE
        GOSUB ERR.FOR.CLOSE.COLL
        RETURN
    END
RETURN
*-------------------------------------------------------------------------------------------------------
INIT:
*-------------------------------------------------------------------------------------------------------

    FN.AC.LOCKED.EVENTS = "F.AC.LOCKED.EVENTS"
    F.AC.LOCKED.EVENTS = ""
    R.AC.LOCKED.EVENTS = ""
    CALL OPF(FN.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS)

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    R.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.AA.ARRANGEMENT = ""
    R.AA.ARRANGEMENT = ""
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.COLLATERAL="F.COLLATERAL"
    F.COLLATERAL=""
    R.COLLATERAL=""
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.COLLATERAL.RIGHT="F.COLLATERAL.RIGHT"
    F.COLLATERAL.RIGHT=""
    R.COLLATERAL.RIGHT=""
    CALL OPF(FN.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT)

    FN.AA.ACTIVITY.HISTORY = "F.AA.ACTIVITY.HISTORY"
    F.AA.ACTIVITY.HISTORY = ""
    R.AA.ACTIVITY.HISTORY = ""
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.LIMIT.ARRANGEMENT='F.LIMIT.ARRANGEMENT'
    F.LIMIT.ARRANGEMENT=''
    R.LIMIT.ARRANGEMENT=''
    CALL OPF(FN.LIMIT.ARRANGEMENT,F.LIMIT.ARRANGEMENT)

    FN.CUSTOMER.ACCOUNT='F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT=''
    R.CUSTOMER.ACCOUNT=''

    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS =''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.ARR.TERM.AMOUNT='F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT=''
    R.AA.ARR.TERM.AMOUNT=''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)

    APPL.ARRAY = 'AA.ARR.TERM.AMOUNT':@FM:'COLLATERAL':@FM:'AC.LOCKED.EVENTS'
    FLD.ARRAY  = 'L.AA.COL':@VM:'L.AA.COL.VAL':@FM:'L.COL.NUM.INSTR':@VM:'L.COL.VAL.AVA':@FM:'L.AC.LOCKE.TYPE'      ;* PACS00308600 - S/E
    FLD.POS    = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
    LOC.L.AA.COL        = FLD.POS<1,1>
    LOC.L.AA.COL.VAL    = FLD.POS<1,2>
    LOC.L.NUM.INST      = FLD.POS<2,1>
    LOC.L.CO.AVA.AMT    = FLD.POS<2,2>    ;* PACS00308600 - S/E
    LOC.L.LOCL.TYPE     = FLD.POS<3,1>
RETURN

*---------------------------------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------------------------------
* PACS00260025 - S
*      IF R.NEW(COLL.COLLATERAL.CODE) NE '150' THEN
*         RETURN ;*This Function isvalid only for Collateral type 150
*      END
* PACS00260025 - E
    Y.APPLICATION.ID = R.NEW(COLL.LOCAL.REF)<1,LOC.L.NUM.INST>          ;*R.NEW(COLL.APPLICATION.ID)
    SEL.AC.LOCKED.EVENTS.CMD="SELECT ":FN.AC.LOCKED.EVENTS:" WITH ACCOUNT.NUMBER EQ ":Y.APPLICATION.ID
    CALL EB.READLIST(SEL.AC.LOCKED.EVENTS.CMD,SEL.LIST,'',NO.OF.REC,ERR)
    LOOP
        REMOVE Y.AC.LOCK.ID FROM SEL.LIST SETTING AC.LOCK.POS
    WHILE Y.AC.LOCK.ID:AC.LOCK.POS
        CALL F.READ(FN.AC.LOCKED.EVENTS,Y.AC.LOCK.ID,R.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS,AC.LOCK.ERR)
        Y.STATUS = R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.L.LOCL.TYPE>
        IF R.AC.LOCKED.EVENTS<AC.LCK.LOCAL.REF,LOC.L.LOCL.TYPE> EQ 'GUARANTEE.STATUS' THEN
            OFS.SOURCE.ID = 'APAP.B.180.OFS'
            APPLICATION.NAME = 'AC.LOCKED.EVENTS'
            TRANS.FUNC.VAL = 'R'    ;*Instead Input function must be used reverser Function
            TRANS.OPER.VAL = 'PROCESS'
            APPLICATION.NAME.VERSION = 'AC.LOCKED.EVENTS,APAP'
            NO.AUT = '0'
            OFS.MSG.ID = ''
            APPLICATION.ID= Y.AC.LOCK.ID
            OFS.POST.MSG = ''
            OFS.AZ.MSG1=APPLICATION.NAME.VERSION:'/':TRANS.FUNC.VAL:'/':TRANS.OPER.VAL:'///,//,':Y.AC.LOCK.ID
            OFS.BODY=''   ;*',TO.DATE:1:1=':TODAY             in reverser function is not be avaliable to input new values
            OFS.REQ.MSG=OFS.AZ.MSG1:OFS.BODY
            CALL OFS.POST.MESSAGE (OFS.REQ.MSG,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
        END
    REPEAT

RETURN


*------------------------------------------------------------------------------------------------------------
MULTI.COLLATERAL:
*------------------------------------------------------------------------------------------------------------
    Y.COLLATERAL.ID=ID.NEW
    Y.CUSTOMER.NO=FIELD(Y.COLLATERAL.ID,'.',1)

*PACS00054324- S
    CALL F.READ(FN.CUSTOMER.ACCOUNT,Y.CUSTOMER.NO,R.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT,Y.CUS.ACC.ERR)
    Y.COUNT = DCOUNT(R.CUSTOMER.ACCOUNT,@FM)
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE Y.COUNT
        Y.ACCT.ID = R.CUSTOMER.ACCOUNT<Y.CNT>
        CALL F.READ(FN.ACCOUNT,Y.ACCT.ID,R.ACCOUNT,F.ACCOUNT,Y.ACC.ERR)
        Y.AA.ARR.ID=R.ACCOUNT<AC.ARRANGEMENT.ID>
        IF Y.AA.ARR.ID NE '' THEN
            idPropertyClass = "TERM.AMOUNT"
            ArrangementID = Y.AA.ARR.ID ; returnError      = ''
            idProperty    = ''          ; effectiveDate    = ''
            returnIds     = ''          ; returnConditions = ''
            R.CONDITION   = ''
            CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
            R.CONDITION = RAISE(returnConditions)
            IF R.CONDITION THEN
                GOSUB GET.ARR.CONDITION.DETAILS
            END
            GOSUB PAYMENT.MADE
        END
        Y.CNT += 1
    REPEAT

*PACS00054324 - E
RETURN

*-----------------------------------------------------------------------------------------------------------
GET.ARR.CONDITION.DETAILS:
*-------------------------------------------------------------------------------------------------------------

    Y.COLL.ID=R.CONDITION<AA.AMT.LOCAL.REF,LOC.L.AA.COL>
    Y.MATURITY =R.CONDITION<AA.AMT.MATURITY.DATE>
    CHANGE @SM TO @FM IN Y.COLL.ID
    CHANGE @VM TO @FM IN Y.COLL.ID
    LOCATE ID.NEW IN Y.COLL.ID SETTING POS.COL THEN
        CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
*        IF R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> EQ "CURRENT" AND R.NEW(COLL.EXPIRY.DATE) LE Y.MATURITY THEN
        IF R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> EQ "CURRENT" THEN
            AF = COLL.EXPIRY.DATE
            ETEXT="EB-UNSECURED"
            CALL STORE.END.ERROR
            RETURN
        END
        IF R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> EQ "EXPIRED" THEN
            GOSUB GET.ACCOUTN.DETAILS
            IF Y.FLAG EQ '1' THEN
                AF = COLL.EXPIRY.DATE
                ETEXT="EB-UNSECURED"
                CALL STORE.END.ERROR
                RETURN
            END
        END

    END
RETURN
*-------------------------------------------------------------------------------------------------------------
GET.ACCOUTN.DETAILS:
*-------------------------------------------------------------------------------------------------------------
    Y.FLAG = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ERR.ACCT)
    Y.SET.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    LOCATE 'UNPAID' IN Y.SET.STATUS<1,1> SETTING POS.SET THEN
        Y.FLAG = '1'
    END
RETURN
*-------------------------------------------------------------------------------------------------------------
PAYMENT.MADE:
*-------------------------------------------------------------------------------------------------------------

    CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.AA.ARR.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,HIST.ERR)
    Y.AA.ACTIVITY.ID = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>

    FIND 'LENDING-APPLYPAYMENT-PR.REGBILLOVERPAYMENT' IN Y.AA.ACTIVITY.ID SETTING ACT.POS1,ACT.POS2,ACT.POS3 THEN
        Y.EFFECTIVE.DATE = R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE,ACT.POS2>
        Y.DATE =  TODAY
        NOF.DAYS = "W"
        CALL CDD ("",Y.EFFECTIVE.DATE,Y.DATE,NOF.DAYS)
        DATE.DIFF = NOF.DAYS

        IF DATE.DIFF LE 7 THEN
            TEXT = "PAYMENT.MADE":@FM:Y.AA.ARR.ID
            CURR.NO = DCOUNT(R.NEW(COLL.OVERRIDE),@VM)
            CALL STORE.OVERRIDE(CURR.NO+1)
        END
    END

RETURN
*-------------------------------------------------------------------------------------------------------------
ERR.FOR.CLOSE.COLL:
*-------------------------------------------------------------------------------------------------------------
* PACS00281659 - S

    R.NEW(COLL.LOCAL.REF)<1,LOC.L.CO.AVA.AMT> = '0' ;* PACS00308600 - S/E

    IF R.NEW(COLL.EXPIRY.DATE) LT TODAY THEN
        AF = COLL.EXPIRY.DATE
        TEXT="CO.MUST.GE.TODAY"
        CURR.NO = DCOUNT(R.NEW(COLL.OVERRIDE),@VM)
        CALL STORE.OVERRIDE(CURR.NO+1)
        RETURN
    END
* PACS00281659 - E
* ->MG CAMBIAR POR OVERRIDE
    IF R.NEW(COLL.EXPIRY.DATE) GT TODAY THEN
        AF = COLL.EXPIRY.DATE
        ETEXT="EB-FC.FUTURE.DATE.NA"
        CALL STORE.END.ERROR
        RETURN
    END

    IF R.OLD(COLL.STATUS) EQ 'LIQ' THEN
        AF = COLL.EXPIRY.DATE
        ETEXT="AC-INP.NOT.ALLOWED"
        CALL STORE.END.ERROR
        RETURN
    END

RETURN
END
