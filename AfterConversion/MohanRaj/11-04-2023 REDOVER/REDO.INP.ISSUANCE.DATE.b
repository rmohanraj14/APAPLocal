* @ValidationCode : MjozMTc1MzI4NTM6Q3AxMjUyOjE2ODEyMTM5Njk0OTA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:22:49
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
SUBROUTINE REDO.INP.ISSUANCE.DATE
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This subroutine would serve as a cross validation level validation routine
* The purpose of this routine is to check the field STOPPAYMENT.STATUS,
* depending upon the value of STOP.PAYMENT.STATUS system should populate
*  the EXPIRY.DATE and  STOP.CHEQ.VALIDITY
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who               Reference                          Description
* 25-Nov-2009     SHANKAR RAJU      ODR-2009-10-0426(HD1053407)          Initial Creation
* 06-Apr-2011     Manju.G           PACS00023947                         Calculation for the Expiry date
* 11-07-2011       JEEVA T          PACS00052346                         Fix for PACS00052346
* 16-12-2011       JEEVA T          PACS00170347                          BUG FIXING
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.ACCOUNT
    $INSERT I_F.DATES
    $INSERT I_F.PAYMENT.STOP.HIST
    $INSERT I_F.REDO.CHQ.VALID.PERIOD
    $INSERT I_F.REDO.PAYMENT.STOP.ACCOUNT
    $INSERT I_EB.EXTERNAL.COMMON

*------------------------------MAIN--------------------------------------
    GOSUB INIT
    GOSUB OPENFILE

    GOSUB PROCESS

RETURN

*------------------------------INIT--------------------------------------
INIT:

    POS=''
    OLD.DATE = ''
    POS.STOPPAYMENT.STATUS=''
    R.CHQ.VAL=''
    FN.REDO.CHQ.VALID='F.REDO.CHQ.VALID.PERIOD'
    F.REDO.CHQ.VALID=''
    VALIDITY=''

    FN.REDO.PAYMENT.STOP.ACCOUNT = 'F.REDO.PAYMENT.STOP.ACCOUNT'
    F.REDO.PAYMENT.STOP.ACCOUNT = ''
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

RETURN
*------------------------------------------------------------------------
OPENFILE:

    CALL OPF(FN.REDO.PAYMENT.STOP.ACCOUNT,F.REDO.PAYMENT.STOP.ACCOUNT)
    CALL OPF(FN.REDO.CHQ.VALID,F.REDO.CHQ.VALID)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------

    Y.LAST.LIST.VAL = ''
    Y.FIRST.LIST.VAL = ''
    Y.LIST.CHQ.LIST = ''
    Y.CHQ.VAL = 1
    Y.ACC.ID = FIELD(ID.NEW,".",1)
    CALL F.READ(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.CURR = R.ACCOUNT<AC.CURRENCY>
    Y.CUS = R.ACCOUNT<AC.CUSTOMER>
    CHQ.STATUS    =  R.NEW(REDO.PS.ACCT.PAY.STOP.STATUS)
    Y.FIRST       =  R.NEW(REDO.PS.ACCT.CHEQUE.FIRST)
    Y.LAST        =  R.NEW(REDO.PS.ACCT.CHEQUE.LAST)
    Y.ACCOUNT.NUMBER.INPUT = R.NEW(REDO.PS.ACCT.ACCOUNT.NUMBER)
    R.NEW(REDO.PS.ACCT.CURRENCY) = Y.CURR
    R.NEW(REDO.PS.ACCT.CUSTOMER) = Y.CUS

    AF = REDO.PS.ACCT.CHEQUE.FIRST
    CALL DUP

    AF = REDO.PS.ACCT.CHEQUE.LAST
    CALL DUP

    IF Y.ACCOUNT.NUMBER.INPUT NE Y.ACC.ID THEN
        AF = REDO.PS.ACCT.ACCOUNT.NUMBER
        ETEXT = 'EB-ACCOUNT.NUMBER'
        CALL STORE.END.ERROR
    END

    IF EB.EXTERNAL$CHANNEL EQ 'INTERNET' THEN
        IF Y.LAST LT Y.FIRST THEN

            ETEXT = 'EB-REDO.FIRST.LAST.CHEQUE.NUM'
            CALL STORE.END.ERROR
        END
    END



    START.COUNT   =  1
    STATUS.NOS    =  DCOUNT(CHQ.STATUS,@VM)

    LOOP
    WHILE START.COUNT LE STATUS.NOS
        Y.FIRST.CHQ = Y.FIRST<1,START.COUNT>
        Y.LAST.CHQ  = Y.LAST<1,START.COUNT>
        IF Y.LAST.CHQ LT Y.FIRST.CHQ THEN
            AF = REDO.PS.ACCT.CHEQUE.LAST
            AV = START.COUNT
            ETEXT = 'TT-CHK.CHQ'
            CALL STORE.END.ERROR
            RETURN
        END
        Y.OLD.CHQ.STATUS = R.OLD(REDO.PS.ACCT.PAY.STOP.STATUS)<1,START.COUNT>
        Y.NEW.CHQ.STATUS = R.NEW(REDO.PS.ACCT.PAY.STOP.STATUS)<1,START.COUNT>
        Y.ISSUE.DATE = R.NEW(REDO.PS.ACCT.ISSUE.DATE)<1,START.COUNT>
        IF Y.OLD.CHQ.STATUS EQ 'NONCONFIRMED' AND Y.NEW.CHQ.STATUS EQ 'CONFIRMED' THEN
            IF NOT(Y.ISSUE.DATE) THEN
                R.NEW(REDO.PS.ACCT.EXPIRY.DATE)<1,START.COUNT> = '20991231'
            END
        END
        IF Y.LAST.CHQ THEN
            Y.NO.LEAVES = Y.LAST.CHQ - Y.FIRST.CHQ
            R.NEW(REDO.PS.ACCT.NO.OF.LEAVES)<1,START.COUNT> = Y.NO.LEAVES + 1
        END ELSE
            R.NEW(REDO.PS.ACCT.NO.OF.LEAVES)<1,START.COUNT> = 1
        END
        STAT.CHQ = CHQ.STATUS<1,START.COUNT>
        IF CHQ.STATUS<1,START.COUNT> EQ 'CONFIRMED' THEN

            R.NEW(REDO.PS.ACCT.STOP.DATE)<1,START.COUNT> = TODAY

            GOSUB CONFIRMED.CHECK
        END
        ELSE
            STAT.CHQ = CHQ.STATUS<1,START.COUNT>
            IF CHQ.STATUS<1,START.COUNT> EQ 'NONCONFIRMED' THEN

                R.NEW(REDO.PS.ACCT.STOP.DATE)<1,START.COUNT> = TODAY

                GOSUB NONCONFIRMED.CHECK

            END
        END
        GOSUB DUP.CHECK
        START.COUNT += 1 ;*R22 Code conversion
    REPEAT

RETURN
*------------------------------------------------------------------------
DUP.CHECK:
*------------------------------------------------------------------------
    Y.CHQ.VAL = 1
    LOOP
    WHILE Y.CHQ.VAL LT START.COUNT
        IF Y.FIRST.CHQ GE Y.FIRST<1,Y.CHQ.VAL> AND Y.FIRST.CHQ LE Y.LAST<1,Y.CHQ.VAL> THEN
            AF = REDO.PS.ACCT.CHEQUE.FIRST
            AV = START.COUNT
            ETEXT = 'AC-DUP'
            CALL STORE.END.ERROR
            RETURN
        END
        IF Y.LAST.CHQ LE Y.FIRST<1,Y.CHQ.VAL> AND Y.LAST.CHQ GE Y.LAST<1,Y.CHQ.VAL> THEN
            AF = REDO.PS.ACCT.CHEQUE.LAST
            AV = START.COUNT
            ETEXT = 'AC-DUP'
            CALL STORE.END.ERROR
            RETURN
        END
        Y.CHQ.VAL += 1 ;*R22 Code conversion
    REPEAT
RETURN
*------------------------------------------------------------------------
CONFIRMED.CHECK:
*------------------------------------------------------------------------
    CALL F.READ(FN.REDO.CHQ.VALID,'CONFIRMED',R.CHQ.VAL,F.REDO.CHQ.VALID,ERR.REDO)

    VALIDITY = R.CHQ.VAL<REDO.CHQ.VAL.VALIDITY>
    ADV.MONTH=VALIDITY:'M'
*PACS00023947-S
    ISSUE.DATE = R.NEW(REDO.PS.ACCT.ISSUE.DATE)<1,START.COUNT>
*PACS00023947-E
    IF ISSUE.DATE THEN
        CALL CALENDAR.DAY(ISSUE.DATE,'+',ADV.MONTH)

        R.NEW(REDO.PS.ACCT.EXPIRY.DATE)<1,START.COUNT> = ADV.MONTH

        TIME.NOW=OCONV(TIME(),"MT")
        R.NEW(REDO.PS.ACCT.EXP.TIME)<1,START.COUNT> = TIME.NOW
    END
    IF R.NEW(REDO.PS.ACCT.EXPIRY.DATE)<1,START.COUNT> LT TODAY THEN
        AV = START.COUNT
        AF = REDO.PS.ACCT.EXPIRY.DATE
        ETEXT = 'AC-DATE.LT.TODAY'
        CALL STORE.END.ERROR

    END
RETURN
*------------------------------------------------------------------------
NONCONFIRMED.CHECK:
*------------------------------------------------------------------------
    CALL F.READ(FN.REDO.CHQ.VALID,'NONCONFIRMED',R.CHQ.VAL,F.REDO.CHQ.VALID,ERR.REDO)

    VALIDITY=R.CHQ.VAL<REDO.CHQ.VAL.VALIDITY>
*    ISSUE.DAT = R.NEW(REDO.PS.ACCT.STOP.DATE)<1,START.COUNT>
*    ISSUE.DAT = R.NEW(REDO.PS.ACCT.ISSUE.DATE)<1,START.COUNT>
*------------------------------------------------------------------------
*FIX FOR PACS00052346
*------------------------------------------------------------------------
    ISSUE.DAT = TODAY
*------------------------------------------------------------------------
*VALIDITY IN HOURS(ONLY IN MULTIPLES OF 24-HOURS) WILL BE CONVERTED INTO DAYS

    VAL.DAY=VALIDITY/24
    ADV.DAY=VAL.DAY:'D'
    IF ISSUE.DAT THEN
        CALL CALENDAR.DAY(ISSUE.DAT,'+',ADV.DAY)
        CALL AWD('',ADV.DAY,YDAY.TYPE)
        IF YDAY.TYPE NE 'W' THEN
            ADV.DAY = R.DATES(EB.DAT.NEXT.WORKING.DAY)
        END
        R.NEW(REDO.PS.ACCT.EXPIRY.DATE)<1,START.COUNT> = ADV.DAY

        TIME.NOW=OCONV(TIME(),"MT")
        R.NEW(REDO.PS.ACCT.EXP.TIME)<1,START.COUNT> = TIME.NOW
    END

    IF R.NEW(REDO.PS.ACCT.EXPIRY.DATE)<1,START.COUNT> LT TODAY THEN
        AV = START.COUNT
        AF = REDO.PS.ACCT.EXPIRY.DATE
        ETEXT = 'AC-DATE.LT.TODAY'
        CALL STORE.END.ERROR
    END

RETURN

END
*------------------------------------------------------------------------
