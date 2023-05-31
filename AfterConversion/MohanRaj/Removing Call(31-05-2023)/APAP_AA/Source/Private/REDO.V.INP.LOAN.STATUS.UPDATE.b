$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.V.INP.LOAN.STATUS.UPDATE
    
*-----------------------------------------------------------------------------------
* Modification History: Code conversion
* Package Name added APAP.AA
*-----------------------------------------------------------------------------------
* Modification History:
*
* DATE                 WHO                  REFERENCE                         DESCRIPTION
* 29/03/2023         SURESH            MANUAL R22 CODE CONVERSTION         Package Name added APAP.AA
* 29/03/2023         Conversion Tool    AUTO R22 CODE CONVERSTION           VM to @VM,FM to @FM,Y.CNT = Y.CNT + 1 to  Y.CNT += 1,= DUE.DATE.POS + 1 to += 1,DUE.DATE.POS.CNT + 1 to += 1 ,SM to @SM, --NO.OF.DUE.DATE to NO.OF.DUE.DATE-= 1
*-----------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------
*-------------------------------------------------------------------------------------------
* DESCRIPTION:
*             This routine is attached as pre routine for the activity LENDING-UPDATE-OVERDUE
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 07-JUN-2010   N.Satheesh Kumar   ODR-2009-10-0331      Initial Creation
* 28-APR-2011      H GANESH           CR009              Change the Vetting value of local field
* 27-MAY-2011      MARIMUTHU S     PACS00054736
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
*   $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.APAP.LOAN.CHEQUE.DETAILS

    IF RUNNING.UNDER.BATCH THEN
        RETURN
    END

    IF V$FUNCTION NE 'I' THEN
        RETURN
    END

    GOSUB GET.LRF.POS
    GOSUB INIT
    IF OLD.LOAN.STATUS.LST EQ NEW.LOAN.STATUS.LST AND OLD.LOAN.COND.LST EQ NEW.LOAN.COND.LST THEN
        RETURN
    END
    GOSUB OPEN.FILES
    GOSUB GET.AA.ACCT.DET
    GOSUB PROCESS

RETURN

*-----------
GET.LRF.POS:
*-----------
*--------------------------------------------------------------------------------------------
* This section gets the position of the local reference fields LOAN.STATUS and LOAN.CONDITION
*--------------------------------------------------------------------------------------------

    AA.OD.LRF.POS = ''
    AA.LOAN.STATUS.POS = ''
    AA.LOAN.COND.POS = ''
    AA.OD.LRF = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@VM:'L.LOAN.COMMENT1':@VM:'L.RESTRUCT.TYPE';*AUTO R22 CODE CONVERSION

    CALL MULTI.GET.LOC.REF('AA.PRD.DES.OVERDUE',AA.OD.LRF,AA.OD.LRF.POS)
    AA.LOAN.STATUS.POS = AA.OD.LRF.POS<1,1>
    AA.LOAN.COND.POS = AA.OD.LRF.POS<1,2>
    AA.LC.COMMENT.POS = AA.OD.LRF.POS<1,3>
    L.REST.TYPE.POS = AA.OD.LRF.POS<1,4>
RETURN

*----
INIT:
*----
*--------------------------------------------------------------------------------------------
* This section gets the value of the local reference field LOAN.STATUS and LOAN.CONDITION
*  from the common variables R.OLD and R.NEW and stores it in the local variables
*--------------------------------------------------------------------------------------------

    ARR.ID = c_aalocArrId
    OLD.LOAN.STATUS.LST = R.OLD(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    OLD.LOAN.COND.LST = R.OLD(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>
    OLD.L.RESTRUC.TYPE = R.OLD(AA.OD.LOCAL.REF)<1,L.REST.TYPE.POS>
    NEW.LOAN.STATUS.LST = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    NEW.LOAN.COND.LST = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>
    NEW.L.RESTRUC.TYPE = R.NEW(AA.OD.LOCAL.REF)<1,L.REST.TYPE.POS>
RETURN

*----------
OPEN.FILES:
*----------
*---------------------------------------
* This section opens the necessary files
*---------------------------------------

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.REDO.AA.LOAN.UPD.STATUS= 'F.REDO.AA.LOAN.UPD.STATUS'
    F.REDO.AA.LOAN.UPD.STATUS= ''
    CALL OPF(FN.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.REDO.APAP.LOAN.CHEQUE.DETAILS = 'F.REDO.APAP.LOAN.CHEQUE.DETAILS'
    F.REDO.APAP.LOAN.CHEQUE.DETAILS = ''
    CALL OPF(FN.REDO.APAP.LOAN.CHEQUE.DETAILS,F.REDO.APAP.LOAN.CHEQUE.DETAILS)

RETURN

*-------
PROCESS:
*-------
*-------------------------------------------------------------------------------------
* This main process section transfers the control to other para based on the condition
*-------------------------------------------------------------------------------------
* PACS00371128 - 2014NOV28 - S
    IF NEW.LOAN.STATUS.LST EQ "Restructured" AND NEW.L.RESTRUC.TYPE EQ "" THEN
        AF = AA.OD.LOCAL.REF
        AV = L.REST.TYPE.POS
        ETEXT = 'EB-AA.TYPE.REST'
        CALL STORE.END.ERROR
    END
* PACS00371128 - 2014NOV28 - E
*Manual Regestration of Loan Status
    CNT=''
    LOOP
        REMOVE LOAN.STATUS FROM NEW.LOAN.STATUS.LST SETTING NEW.LOAN.STATUS.POS
        CNT+ =1
    WHILE LOAN.STATUS:NEW.LOAN.STATUS.POS
****PACS00054736**** - START
        IF LOAN.STATUS EQ 'JudicialCollection' THEN
            Y.CND = NEW.LOAN.COND.LST<1,1,CNT>
            IF NEW.LOAN.COND.LST<1,1,CNT> NE 'Legal' THEN
                AF = AA.OD.LOCAL.REF
                AV = AA.LOAN.COND.POS
                AS = CNT
                ETEXT = 'EB-JUDI.THEN.LEGAL'
                CALL STORE.END.ERROR
            END
        END

* IF LOAN.STATUS EQ 'Write-off' THEN
*     Y.CND = NEW.LOAN.COND.LST<1,1,CNT>
*     IF NEW.LOAN.COND.LST<1,1,CNT> NE 'Legal' THEN
*         AF = AA.OD.LOCAL.REF
*         AV = AA.LOAN.COND.POS
*         AS = CNT
*         ETEXT = 'EB-JUDI.THEN.LEGAL'
*         CALL STORE.END.ERROR
*     END
* END

****PACS00054736*** - END

        LOCATE LOAN.STATUS IN OLD.LOAN.STATUS.LST<1,1,1> SETTING OLD.LOAN.STATUS.POS ELSE
            GOSUB REGISTER.LS
        END
    REPEAT

*Manual Elimination of Loan Status
    LOOP
        REMOVE OLD.LOAN.STATUS FROM OLD.LOAN.STATUS.LST SETTING OLD.LOAN.STATUS.POS
    WHILE OLD.LOAN.STATUS:OLD.LOAN.STATUS.POS
        LOCATE OLD.LOAN.STATUS IN NEW.LOAN.STATUS.LST<1,1,1> SETTING NEW.LOAN.STATUS.POS ELSE
            GOSUB PROCESS.LS
        END
    REPEAT

*Manual Elimination of Loan Condition
    LOOP
        REMOVE OLD.LOAN.COND FROM OLD.LOAN.COND.LST SETTING OLD.LOAN.COND.POS
    WHILE OLD.LOAN.COND:OLD.LOAN.COND.POS
        LOCATE OLD.LOAN.COND IN NEW.LOAN.COND.LST<1,1,1> SETTING NEW.LOAN.COND.POS ELSE
            GOSUB PROCESS.LC
        END
    REPEAT

RETURN

*-----------
REGISTER.LS:
*-----------
*-------------------------------------------------------------------------------------------------------------
* This section will be process when value in the local reference field Loan Status is changed from null value
*  and displays the blocking override when the updated value does not satisfy the given conditon
*--------------------------------------------------------------------------------------------------------------
    Y.FLAG.ERR = ''
    BEGIN CASE
        CASE LOAN.STATUS EQ 'Restructured'

            GOSUB CK.LOAN.STS

            IF NOT(Y.FLAG.ERR) THEN
                AF = AA.OD.LOCAL.REF
                AV = AA.LOAN.STATUS.POS
                AS = CNT
                ETEXT = 'EB-RESTRUCT.STATUS'
                CALL STORE.END.ERROR
                RETURN
            END

    END CASE

RETURN


CK.LOAN.STS:

    IF Y.LOAN.STATUS.VAL EQ 'CURRENT' THEN
        GOSUB CK.ST.1
    END

RETURN

CK.ST.1:

    IF AD.ARR.AGE.STATUS EQ 'CUR' THEN
        LOCATE 'Restructured' IN NEW.LOAN.COND.LST<1,1,1> SETTING RESTRUCT.POS ELSE
            R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS,-1> = 'Restructured'
            R.NEW(AA.OD.LOCAL.REF)<1,AA.LC.COMMENT.POS,-1> = ''
        END
        Y.FLAG.ERR = '1'
    END
    IF NOT(AD.ARR.AGE.STATUS) THEN
        LOCATE 'Restructured' IN NEW.LOAN.COND.LST<1,1,1> SETTING RESTRUCT.POS ELSE
            R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS,-1> = 'Restructured'
            R.NEW(AA.OD.LOCAL.REF)<1,AA.LC.COMMENT.POS,-1> = ''
        END
        Y.FLAG.ERR = '1'
    END

RETURN

*----------
PROCESS.LS:
*----------
*-----------------------------------------------------------------------------------------------
* This section will be process when value in the local reference field Loan Status is changed
*  and displays the blocking override when the updated value does not satisfy the given conditon
*-----------------------------------------------------------------------------------------------

    BEGIN CASE

        CASE OLD.LOAN.STATUS EQ 'JudicialCollection'
            IF AD.ARR.AGE.STATUS NE 'CUR' THEN
                TEXT = 'AA.LOAN.UNMARK'
                TEXT<2> = OLD.LOAN.STATUS
                GOSUB PROCESS.OVERRIDE
            END
        CASE OLD.LOAN.STATUS EQ 'Restructured'
*        GOSUB LS.RESTRUCT
            GOSUB GET.AA.ACCT.DETAILS
            GOSUB PROCESS.LS.RESTRUCT
        CASE OLD.LOAN.STATUS EQ 'Write-off'
            IF AD.ARR.AGE.STATUS NE 'CUR' THEN
                TEXT = 'AA.LOAN.WRITE.OFF'
                GOSUB PROCESS.OVERRIDE
            END
        CASE OLD.LOAN.STATUS EQ 'Normal'
            GOSUB GET.AA.ACCT.DETAILS
            GOSUB PROCESS.LS.NORMAL
    END CASE
RETURN
**-----------------------------------------------------------------------------------------------
PROCESS.LS.NORMAL:
*-----------------------------------------------------------------------------------------------
    GOSUB BILL.PAID.CHECK
    IF Y.BILL.GEN.FLAG THEN
        LOCATE 'Restructured' IN NEW.LOAN.STATUS.LST<1,1,1> SETTING ERR.POS THEN
            AF = AA.OD.LOCAL.REF
            AV = AA.LOAN.STATUS.POS
            ETEXT = 'EB-RESTRUCT.STATUS'
            CALL STORE.END.ERROR
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------
PROCESS.LS.RESTRUCT:
*-----------------------------------------------------------------------------------------------
    Y.FLAG.RES.CHANGE = ''
    Y.CHECK.DATE = ''
    CALL AA.SCHEDULE.PROJECTOR(ARR.ID, SIM.REF, "1",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS,DUE.OUTS)
    BILL.FLAG = 1
    CALL F.READ(FN.REDO.AA.LOAN.UPD.STATUS,ARR.ID,R.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS,Y.ER.AR)
    Y.CHECK.DATE = R.REDO.AA.LOAN.UPD.STATUS
    IF NOT(Y.CHECK.DATE) THEN
        Y.CHECK.DATE = TODAY
    END
    DUE.DATE.POS.CNT = 1
    NO.OF.DUE.DATE=DCOUNT(DUE.DATES,@FM) ;*AUTO R22 CODE CONVERSION
    CHK.DATES = ''
    DUE.DATE.POS = 1

    LOOP
    WHILE DUE.DATE.POS LE NO.OF.DUE.DATE
        IF DUE.DATES<DUE.DATE.POS> GT Y.CHECK.DATE THEN
            GOSUB CK.DATE1
            DUE.DATE.POS.CNT += 1 ;*AUTO R22 CODE CONVERSION
        END
        DUE.DATE.POS += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    IF Y.BILL.GEN.FLAG THEN
        TEXT = 'AA.LOAN.UNMARK.1'
        TEXT<2> = OLD.LOAN.STATUS
        GOSUB PROCESS.OVERRIDE
    END
RETURN

CK.DATE1:

    IF DUE.DATE.POS.CNT GE 3 THEN
        IF DUE.DATES<DUE.DATE.POS> GT TODAY THEN
            Y.BILL.GEN.FLAG = 1
            DUE.DATE.POS = NO.OF.DUE.DATE + 1
        END ELSE
            GOSUB BILL.CHECK.RES
            DUE.DATE.POS = NO.OF.DUE.DATE + 1
        END
    END

RETURN
*---------------
GET.AA.ACCT.DETAILS:
*---------------
    Y.BILL.LIST    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.BILL.TYPE    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>
    Y.BILL.STATUS  = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>

    CHANGE @SM TO @FM IN  Y.BILL.LIST ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN  Y.BILL.TYPE ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN  Y.BILL.STATUS ;*AUTO R22 CODE CONVERSION

    CHANGE @VM TO @FM IN  Y.BILL.LIST ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN  Y.BILL.TYPE ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN  Y.BILL.STATUS ;*AUTO R22 CODE CONVERSION
RETURN
*----------------------------------
BILL.CHECK.RES:
*----------------------------------
    GOSUB BILL.PAID.CHECK

    IF Y.BILL.GEN.FLAG THEN
        DUE.DATE.POS = NO.OF.DUE.DATE + DUE.DATE.POS
        RETURN
    END
RETURN
*--------------------
BILL.PAID.CHECK:
*-------------------
    Y.BILL.GEN.FLAG = ''
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE DCOUNT(Y.BILL.LIST,@FM) ;*AUTO R22 CODE CONVERSION
        IF Y.BILL.STATUS<Y.CNT> EQ 'UNPAID' AND Y.BILL.TYPE<Y.CNT> EQ 'PAYMENT' THEN
            Y.BILL.GEN.FLAG = '1'
            Y.CNT = Y.CNT + DCOUNT(Y.BILL.LIST,@FM) ;*AUTO R22 CODE CONVERSION
        END
        Y.CNT += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------
PROCESS.LC:
*----------
*-----------------------------------------------------------------------------------------------
* This section will be process when value in the local reference field Loan Condition is changed
*  and displays the blocking override when the updated value does not satisfy the given conditon
*-----------------------------------------------------------------------------------------------

    BEGIN CASE
        CASE OLD.LOAN.COND EQ 'Legal'
            IF AD.ARR.AGE.STATUS NE 'CUR' THEN
                TEXT = 'AA.LOAN.UNMARK'
                TEXT<2> = OLD.LOAN.COND
                GOSUB PROCESS.OVERRIDE
            END
        CASE OLD.LOAN.COND EQ 'Restructured'
            TEXT = 'AA.LOAN.UNMARK'
            TEXT<2> = OLD.LOAN.COND:' condition'
            GOSUB PROCESS.OVERRIDE
    END CASE
RETURN

*-----------
LS.RESTRUCT:
*-----------
*--------------------------------------------------------------------------------
* This section checks the condition for Loan Status field updated as Restructured
*  and displays the blocking override when the given conditon is not satisfied
*--------------------------------------------------------------------------------


    CALL AA.SCHEDULE.PROJECTOR(ARR.ID, SIM.REF, "1",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    NO.OF.DUE.DATE=DCOUNT(DUE.DATES,@FM) ;*AUTO R22 CODE CONVERSION
    CHK.DATES = ''; DUE.DATE.POS = ''
    LOOP
    WHILE DUE.DATE.POS GT NO.OF.DUE.DATE DO
        DUE.DATE.POS += 1
        IF DUE.DATES<DUE.DATE.POS> GE TODAY THEN
            GOSUB CK.GT.3
        END
    REPEAT

    IF CHK.DATES EQ '' THEN
        IF NO.OF.DUE.DATE GT 3 THEN
            GOSUB CK.GT.4
        END ELSE
            CHK.DATES = DUE.DATES
        END
    END
    LOOP
        REMOVE CHK.DATE FROM CHK.DATES SETTING CHK.DATE.POS
    WHILE CHK.DATE:CHK.DATE.POS
        IF CHK.DATE LT TODAY THEN
            GOSUB CK.OVRRIDE.1
        END
    REPEAT
RETURN

CK.GT.3:

    IF DUE.DATE.POS GT 3 THEN
        START.POS = DUE.DATE.POS - 3
        CHK.DATES = FIELD(DUE.DATES,@FM,START.POS,3) ;*AUTO R22 CODE CONVERSION
    END ELSE
        CHK.DATES = DUE.DATES
    END
RETURN

CK.GT.4:

    LOOP
    WHILE DUE.DATE.POS GT 3 DO
        DUE.DATE.POS += 1
        CHK.DATES = DUE.DATES<NO.OF.DUE.DATE>
        NO.OF.DUE.DATE -= 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN

CK.OVRRIDE.1:

    LOCATE CHK.DATE IN AD.BILL.PAY.DATE SETTING PAY.DATE.POS THEN
        BILL.ID = AD.BILL.ID<1,PAY.DATE.POS,1>
        GOSUB GET.AA.BILL.DETAILS
        IF 'PAYMENT' MATCHES BILL.TYPE AND 'PAID' MATCHES SETTLE.STATUS AND 'SETTLED' MATCHES AGING.STATUS ELSE
            TEXT = 'AA.LOAN.UNMARK.1'
            TEXT<2> = OLD.LOAN.STATUS
            GOSUB PROCESS.OVERRIDE
            CHK.DATES = ''
        END
    END
RETURN

*---------------
GET.AA.ACCT.DET:
*---------------
*----------------------------------------------------------------------------------
* This section gets the details from AA.ACCOUNT.DETAILS for the current Arrangement
*----------------------------------------------------------------------------------

    R.AA.ACCOUNT.DETAILS = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ACC.DET.ERR)
    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.ARR.ERR)
    Y.LOAN.STATUS.VAL = R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>
    AD.ARR.AGE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.ARR.AGE.STATUS>
    AD.BILL.PAY.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>
    AD.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
RETURN

*-------------------
GET.AA.BILL.DETAILS:
*-------------------
*------------------------------------------------------------------------------------------------
* This section gets the details of the bill and stores the required values in the local variables
*------------------------------------------------------------------------------------------------

    BILL.TYPE = ''
    SETTLE.STATUS = ''
    AGING.STATUS = ''
    PAYMENT.DATE = ''
    CALL F.READ(FN.AA.BILL.DETAILS,BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,AA.DB.ERR)
    BILL.TYPE = R.AA.BILL.DETAILS<AA.BD.BILL.TYPE>
    SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS>
    AGING.STATUS = R.AA.BILL.DETAILS<AA.BD.AGING.STATUS>
    PAYMENT.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>
RETURN

*----------------
PROCESS.OVERRIDE:
*----------------

    CURR.NO  = DCOUNT(R.NEW(AA.OD.OVERRIDE),@VM) + 1 ;*AUTO R22 CODE CONVERSION
    IF CURR.NO EQ 0 THEN
        CURR.NO = 1
    END
    CALL STORE.OVERRIDE(CURR.NO)

RETURN
END
