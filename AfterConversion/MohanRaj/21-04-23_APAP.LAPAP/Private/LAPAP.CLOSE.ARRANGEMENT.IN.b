* @ValidationCode : MjotOTUzMzYwNjg4OkNwMTI1MjoxNjgyMDcxNTU3NTE2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:35:57
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
SUBROUTINE LAPAP.CLOSE.ARRANGEMENT.IN(ACC.ID)
*=====================================================================
* Routine is developed for BOAB client. This routine is used to close an arrangement
* Check ECB balance as 0 and Update AA.ARRANGEMENT as PENDING.CLOSURE
* Trigger CLOSE arrangement activity
*
*  Currently available for LENDING product line, we can modify according to our requirement
*
*  Create VERSION with 0 auth: AA.ARRANGEMENT.ACTIVITY,TEST
*  Create OFS.SOURCE as same as AA.COB : AA.CORR
*======================================================================

* Modification:
* Autor: Oliver Fermin
* Description: Rutina reutilizada para el cierre de los préstamos que se le hayan limpiado los balances remanentes
* Date: 17/06/2019
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion      VM TO @VM,FM TO @FM,SM TO @SM
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.SCHEDULED.ACTIVITY
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.REDO.H.REPORTS.PARAM

*=====================================================================

    GOSUB INITIALISE

INITIALISE:

    UPDATE.STRING = ''
    Y.DIRECTORIO.ARCHIVO = ''

    FN.AA = "F.AA.ARRANGEMENT"
    F.AA = ""
    CALL OPF(FN.AA, F.AA)
*
    FN.AC = "F.ACCOUNT"
    F.AC = ""
    CALL OPF(FN.AC, F.AC)
*
    FN.AAH = "F.AA.ACTIVITY.HISTORY"
    F.AAH = ""
    CALL OPF(FN.AAH, F.AAH)
*
    FN.ECB = "F.EB.CONTRACT.BALANCES"
    F.ECB = ""
    CALL OPF(FN.ECB, F.ECB)
*
    FN.AAD = "F.AA.ACCOUNT.DETAILS"
    F.AAD = ""
    CALL OPF(FN.AAD, F.AAD)
*
    FN.ABD = "F.AA.BILL.DETAILS"
    F.ABD = ""
    CALL OPF(FN.ABD, F.ABD)
*
    FN.ASA = "F.AA.SCHEDULED.ACTIVITY"
    F.ASA = ""
    CALL OPF(FN.ASA, F.ASA)
*
    FN.AIA = "F.AA.INTEREST.ACCRUALS"
    F.AIA = ""
    CALL OPF(FN.AIA, F.AIA)
*
    FN.AAB = "F.AA.ACTIVITY.BALANCES"
    F.AAB = ""
    CALL OPF(FN.AAB, F.AAB)
*
    FN.AAM = "F.AA.ACCOUNT.MOVEMENT"
    F.AAM = ""
    CALL OPF(FN.AAM, F.AAM)

    FN.AAS = "F.AA.ARRANGEMENT.STATUS"
    F.AAS = ""
    CALL OPF(FN.AAS, F.AAS)

    FN.ANA = 'F.AA.NEXT.ACTIVITY'
    F.ANA = ''
    CALL OPF(FN.ANA, F.ANA)

    FN.REDO.H.REPORTS.PARAM = "F.REDO.H.REPORTS.PARAM"
    F.REDO.H.REPORTS.PARAM = ''
    CALL OPF(FN.REDO.H.REPORTS.PARAM,F.REDO.H.REPORTS.PARAM)

    GOSUB READ.FILES

RETURN

READ.FILES:
**********

    Y.PARAM.ID = "LAPAP.ECB.BALANCES"
    Y.FIELD.NME.PARAM= "";
    Y.FIELD.VAL.PARAM= "";
    Y.FILE.CLEAR.BALANCE = "";
    T24.FILES = ''
    AA.ID = ''

    R.REDO.H.REPORTS.PARAM = '';  PARAM.ERR = '';
    CALL CACHE.READ(FN.REDO.H.REPORTS.PARAM,Y.PARAM.ID,R.REDO.H.REPORTS.PARAM,PARAM.ERR)

    IF R.REDO.H.REPORTS.PARAM NE '' THEN

        Y.DIRECTORIO.ARCHIVO = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.OUT.DIR>

        Y.FIELD.NME.PARAM      = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.FIELD.NAME>
        Y.FIELD.VAL.PARAM      = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.FIELD.VALUE>

        LOCATE "NOMBRE.ARCHIVO" IN Y.FIELD.NME.PARAM<1,1> SETTING VALD.POS THEN
            Y.FILE.CLEAR.BALANCE = Y.FIELD.VAL.PARAM<1,VALD.POS>
            CHANGE @VM TO @FM IN Y.FILE.CLEAR.BALANCE
            CHANGE @SM TO @FM IN Y.FILE.CLEAR.BALANCE
            Y.FILE.CLEAR.BALANCE = Y.FILE.CLEAR.BALANCE<1>
        END

    END


*OPEN '',Y.DIRECTORIO.ARCHIVO TO T24.FILES ELSE
*ERR.OPEN ='EB.RTN.CANT.OPEN.T24.FILES'
*END

*READ RREC FROM T24.FILES,Y.FILE.CLEAR.BALANCE ELSE NULL

    BL.STATUS = 'SETTLED'
    SET.STATUS = 'REPAID'
    AGE.STATUS = 'SETTLED'
    CHG.DATE = TODAY

*GOSUB CREATE.FILE.SUCCESS
*GOSUB CREATE.FILE.ERROR
    GOSUB PROCESS

RETURN

CREATE.FILE.SUCCESS:
********************

    Y.FILE.NAME = "REG.PROCESS.CLOSE.ARRANGEMENT.txt"

    DELETESEQ Y.DIRECTORIO.ARCHIVO,Y.FILE.NAME ELSE NULL

    OPENSEQ Y.DIRECTORIO.ARCHIVO,Y.FILE.NAME TO FV.PTR ELSE
        CREATE FV.PTR ELSE
            CRT "CANNOT OPEN DIR ": Y.DIRECTORIO.ARCHIVO
            STOP
        END
    END

RETURN

CREATE.FILE.ERROR:
********************

    Y.FILE.NAME.ERROR = 'ERROR.REG.CLOSE.ARRANGEMENT.txt'

    DELETESEQ Y.DIRECTORIO.ARCHIVO, Y.FILE.NAME.ERROR ELSE NULL

    OPENSEQ Y.DIRECTORIO.ARCHIVO,Y.FILE.NAME.ERROR TO FV.PTR.ERROR ELSE
        CREATE FV.PTR.ERROR ELSE
            CRT "CANNOT OPEN DIR ": Y.DIRECTORIO.ARCHIVO
            STOP
        END
    END

RETURN

*=====================================================================
PROCESS:
*******

    PRINTTIME = TIMEDATE()
    AA.ID =     ACC.ID

    GOSUB GET.ARRANGEMENT
    GOSUB CHECK.PROCESS.REQD

    IF DONT.PROCESS THEN
        RETURN
    END

    GOSUB VERIFY.ECB
    IF DONT.PROCESS THEN
        RETURN
    END

    GOSUB CLOSE.ARR

RETURN

*=====================================================================
GET.ARRANGEMENT:

    CALL F.READ(FN.AA, AA.ID, R.ARRANGEMENT, F.AA, AA.ERR)

    ARR.STATUS = R.ARRANGEMENT<AA.ARR.ARR.STATUS>
    AC.ID =  R.ARRANGEMENT<AA.ARR.LINKED.APPL.ID,1>
    PRODUCT.LINE = R.ARRANGEMENT<AA.ARR.PRODUCT.LINE>
    CO.CODE = R.ARRANGEMENT<AA.ARR.CO.CODE,1>

RETURN


*=====================================================================
CHECK.PROCESS.REQD:

    DONT.PROCESS = ""

    IF ARR.STATUS EQ "UNAUTH" THEN
        DONT.PROCESS = 1
    END ELSE

        R.AAM = ""; AAM.ERR = ""
        CALL F.READ(FN.AAM, AC.ID, R.AAM, F.AA, AAM.ERR)
        IF AAM.ERR THEN
            R.AAS = ""; AAS.ERR = ""
            CALL F.READ(FN.AAS, AA.ID, R.AAS, F.AAS, AAS.ERR)
            IF AAS.ERR THEN
            END ELSE
                DONT.PROCESS  = 1
            END
        END ELSE
            DON.PROCESS = 1
        END
    END
RETURN

*=====================================================================
VERIFY.ECB:

    ECB.RECORD = ""; ECB.ERR = ""; DIFF.ARR = ""; OPP.BAL.AMOUNT = 0

    CALL F.READ(FN.ECB, AC.ID, ECB.RECORD, F.ECB, ECB.ERR)

    IF NOT(ECB.ERR) THEN

        CALL AA.CONSOLIDATE.ECB.AMOUNTS(ECB.RECORD)         ;* Add the movements and the opening balance to arrive at the current balance

        TOTAL.BALANCES = DCOUNT(ECB.RECORD<ECB.CURR.ASSET.TYPE>,@VM)

        FOR BALANCE.TYPE.POS = 1 TO TOTAL.BALANCES

            BALANCE.TYPE = ECB.RECORD<ECB.TYPE.SYSDATE,BALANCE.TYPE.POS>
            REQD.BALANCE.TYPE = BALANCE.TYPE
            GOSUB GET.BALANCE.AMOUNT
            BALANCE.AMOUNT = RETURN.AMOUNT + 0

            IF BALANCE.AMOUNT THEN
                DONT.PROCESS = 1
            END

        NEXT BALANCE.TYPE.POS
    END
RETURN

*=====================================================================
GET.BALANCE.AMOUNT:

    RETURN.AMOUNT = 0
    REQUEST.TYPE = ""
    REQUEST.TYPE<2> = ""      ;*NAU values should not be consider
    REQUEST.TYPE<4> = "ECB"
    BALANCE.DETAILS = ""
    CALL AA.GET.PERIOD.BALANCES(AC.ID, REQD.BALANCE.TYPE, REQUEST.TYPE, "TODAY", "", "", BALANCE.DETAILS, RET.ERR)

    RETURN.AMOUNT = BALANCE.DETAILS<IC.ACT.BALANCE>

RETURN

*=====================================================================

CLOSE.ARR:

    R.ARRANGEMENT<AA.ARR.ARR.STATUS> = "PENDING.CLOSURE"

    CALL F.WRITE(FN.AA, AA.ID, R.ARRANGEMENT)
*CALL JOURNAL.UPDATE(AA.ID)
    GOSUB PROCESS.OFS

RETURN
*=====================================================================

GET.ARRANGEMENT.CHECK.CLOSED:
****************************

    CALL F.READ(FN.AA, AA.ID, R.ARRANGEMENT, F.AA, AA.ERR)
    ARR.STATUS = R.ARRANGEMENT<AA.ARR.ARR.STATUS>

    IF ARR.STATUS EQ 'PENDING.CLOSURE' THEN

*Guardar los registros procesados
        WRITESEQ AA.ID TO FV.PTR ELSE
            CRT "UNABLE TO WRITE TO FILE SUCCESS"
        END

    END ELSE

*Guardar los registros con error
        WRITESEQ AA.ID TO FV.PTR.ERROR ELSE
            CRT "UNABLE TO WRITE TO FILE ERROR"
        END

    END

RETURN

*=====================================================================

PROCESS.OFS:
************

    Y.DATE = TODAY
    Y.ACTIVITY = "LENDING-CLOSE-ARRANGEMENT"
    FUNC = "I"
    Y.TYPE = "USER"
    Y.LIST = '';

    SAVE.ID.COMPANY = ID.COMPANY
    CALL LOAD.COMPANY(R.ARRANGEMENT<AA.ARR.CO.CODE>)

    options<1> = "AA.CORR"
    options<4> = "HLD"
    OFS.RECORD = "AA.ARRANGEMENT.ACTIVITY,TEST/I/PROCESS///,//":ID.COMPANY:",,ARRANGEMENT=":AA.ID:",EFFECTIVE.DATE=":Y.DATE:",ACTIVITY=":Y.ACTIVITY:",INITIATION.TYPE=":Y.TYPE

    theResponse = ""
    txnCommitted = ""

    CALL OFS.POST.MESSAGE(OFS.RECORD,theResponse,options,txnCommitted)
*CALL JOURNAL.UPDATE(AA.ID)
    CALL LOAD.COMPANY(SAVE.ID.COMPANY)

*GOSUB GET.ARRANGEMENT.CHECK.CLOSED

RETURN

END
