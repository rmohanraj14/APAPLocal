* @ValidationCode : MjotMTA0OTk2NzE5NDpDcDEyNTI6MTY4NTUyODAyNjAzMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:43:46
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
$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE RED.AUTH.APLY.COLL.AAA.VH

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCOUNT
    $USING APAP.REDOSRTN
*-----------------------------------------------------------------------------------

* Modification History:
* Date                  Who                           Reference                      Description
* ----                  ----                            ----                               ----
* 29-March -2023       Conversion Tool          R22 Auto Code Conversion             FM to @FM ,VM to @VM ,SM to @SM, W to W.VAR,X to X.VAR
* 29-March-2023          Ajith Kumar            R22 Manual Code Conversion           Package Name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------

MAIN:

    GOSUB OPEN.FILES
    GOSUB PROCESS
    GOSUB PGM.END

OPEN.FILES:

    POS.CA = ''
    L.APPLN = 'COLLATERAL':@FM:'AA.PRD.DES.TERM.AMOUNT' ;*R22 Auto Code Conversion

    L.FLDS = 'L.AC.LK.COL.ID':@VM:'L.COL.PRO.DESC2':@FM:'L.AA.COL':@VM:'L.AA.COL.VAL':@VM:'L.AA.AV.COL.BAL':@VM:'L.AA.COL.DESC' ;*R22 Auto Code Conversion
    CALL MULTI.GET.LOC.REF(L.APPLN,L.FLDS,POS.CA)

    AA.ID.POS = POS.CA<1,1>
    POS.DESC = POS.CA<1,2>

    Y.COL.POS = POS.CA<2,1>
    Y.COL.VAL.POS = POS.CA<2,2>
    Y.COL.AV.POS = POS.CA<2,3>
    Y.COL.DES.POS = POS.CA<2,4>
* PACS00307565 - S
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
* PACS00307565 - E
RETURN
*
PROCESS:
*
    Y.AA.ID = R.NEW(COLL.LOCAL.REF)<1,AA.ID.POS>
    Y.AA.ID = CHANGE(Y.AA.ID,@SM,@VM)                  ; Y.CNT.AA = DCOUNT(Y.AA.ID,@VM) ;*R22 Auto Code Conversion
    Y.OLD.AA.ID = R.OLD(COLL.LOCAL.REF)<1,AA.ID.POS> ; FLG = ''
* PACS00307565 - S
    GOSUB CONV.ACC.TO.AA
    Y.AA.DUP.ID = Y.AA.ID
* PACS00307565 - E
    Y.NOM.VAL = R.NEW(COLL.EXECUTION.VALUE)
    Y.OLD.NOM.VAL = R.OLD(COLL.EXECUTION.VALUE)
    Y.DESC.GAR = R.NEW(COLL.LOCAL.REF)<1,POS.DESC> ; Y.DESC.GAR = CHANGE(Y.DESC.GAR,@SM,@VM) ; Y.DESC.GAR = CHANGE(Y.DESC.GAR,@VM,' ') ;*R22 Auto Code Conversion
    Y.OLD.DESC = R.OLD(COLL.LOCAL.REF)<1,POS.DESC> ; Y.OLD.DESC = CHANGE(Y.OLD.DESC,@SM,@VM) ; Y.OLD.DESC = CHANGE(Y.OLD.DESC,@VM,' ') ;*R22 Auto Code Conversion

    IF Y.AA.DUP.ID NE Y.OLD.AA.ID OR Y.NOM.VAL NE Y.OLD.NOM.VAL OR Y.DESC.GAR NE Y.OLD.DESC THEN

        GOSUB GET.AA.IDSS

        GOSUB PROCESS.DEL
    END


RETURN
*
CONV.ACC.TO.AA:
* Converting contract account id to AA id
* ///////////////// R.NEW change processing
    Y.AA.ID.TMP     = ''
    Y.AA.ID.TMP     = Y.AA.ID
    Y.AA.ID         = ''
    W.VAR = 1 ; Y.NEW.CNT = DCOUNT(Y.AA.ID.TMP,@VM) ;*R22 Auto Code Conversion
    LOOP
    WHILE W.VAR LE Y.NEW.CNT ;*R22 Auto Code Conversion
        Y.AA.SD = '' ; Y.AA.SD = Y.AA.ID.TMP<1,W.VAR> ;*R22 Auto Code Conversion
        IF Y.AA.SD[1,2] NE "AA" THEN
            GOSUB FIND.BY.ACCOUNT
        END
        Y.AA.ID<1,-1> = Y.AA.SD
        W.VAR += 1 ;*R22 Auto Code Conversion
    REPEAT
* ////////////////// R.OLD change processing
    Y.OLD.AA.ID.TMP = ''
    Y.OLD.AA.ID.TMP = Y.OLD.AA.ID
    Y.OLD.AA.ID     = ''
    X.VAR = 1 ; Y.OLD.CNT = DCOUNT(Y.OLD.AA.ID.TMP,@SM) ;*R22 Auto Code Conversion
    LOOP
    WHILE X.VAR LE Y.OLD.CNT ;*R22 Auto Code Conversion
        Y.AA.SD = '' ; Y.AA.SD = Y.OLD.AA.ID.TMP<1,1,X.VAR> ;*R22 Auto Code Conversion
        IF Y.AA.SD[1,2] NE "AA" THEN
            GOSUB FIND.BY.ACCOUNT
        END
        Y.OLD.AA.ID<1,-1> = Y.AA.SD         ;* Converting from SM to VM
        X.VAR += 1 ;*R22 Auto Code Conversion
    REPEAT
*
RETURN
*
GET.AA.IDSS:

    LOOP
    WHILE Y.CNT.AA GT 0 DO
        FLG += 1
        Y.AA.SD = Y.AA.ID<1,FLG>
        GOSUB GET.AA.CUR.BAL
* PACS00307565 - E
        idArrangementComp = Y.AA.SD ; idPropertyClass = 'TERM.AMOUNT' ; idProperty = 'COMMITMENT' ;effectiveDate = TODAY ; returnConditions = ''
        CALL AA.GET.ARRANGEMENT.CONDITIONS(idArrangementComp, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
        returnConditions = RAISE(returnConditions)
        Y.AA.COLL.IDS = returnConditions<AA.AMT.LOCAL.REF,Y.COL.POS>
        Y.AA.COLL.IDS = CHANGE(Y.AA.COLL.IDS,@SM,@VM) ; Y.CL.CNT = DCOUNT(Y.AA.COLL.IDS,@VM) ;*R22 Auto Code Conversion

        Y.AA.COLS.VALS = returnConditions<AA.AMT.LOCAL.REF,Y.COL.VAL.POS> ;
        Y.AA.COLS.VALS = CHANGE(Y.AA.COLS.VALS,@SM,@VM) ;*R22 Auto Code Conversion
* PACS00307565 - S
        Y.AA.BAL.VALS  = returnConditions<AA.AMT.LOCAL.REF,Y.COL.AV.POS>
        Y.AA.BAL.VALS  = CHANGE(Y.AA.BAL.VALS,@SM,@VM) ;*R22 Auto Code Conversion
        GOSUB EVA.COL.BAL         ;* PACS00370883 - S/E
        GOSUB PROCESS.AAA
        Y.CNT.AA -= 1
    REPEAT

RETURN

EVA.COL.BAL:
* PACS00307565 - E
    AAA.REQ = ''
    LOCATE ID.NEW IN Y.AA.COLL.IDS<1,1> SETTING POS.CL THEN
        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL:':POS.CL:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = ID.NEW

        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.VAL:':POS.CL:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = R.NEW(COLL.EXECUTION.VALUE)

        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.DESC:':POS.CL:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.DESC.GAR[1,60]
* PACS00307565 - S
        IF Y.AA.DUP.ID NE Y.OLD.AA.ID THEN  ;* Any of the Loans was changed or replaced
            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.AV.COL.BAL:':POS.CL:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.BAL
        END
* PACS00307565 - E
    END ELSE
        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL:':Y.CL.CNT+1:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = ID.NEW

        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.VAL:':Y.CL.CNT+1:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = R.NEW(COLL.EXECUTION.VALUE)

        AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.DESC:':Y.CL.CNT+1:':1'
        AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.DESC.GAR[1,60]
* PACS00307565 - S
        IF Y.AA.DUP.ID NE Y.OLD.AA.ID THEN  ;* Any of the Loans was changed or replaced
            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.AV.COL.BAL:':Y.CL.CNT+1:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.BAL
        END
* PACS00307565 - E
    END

RETURN

GET.AA.CUR.BAL:
* Get outstanding from AA
    Y.AA.BAL = ''
    APAP.REDOSRTN.redoSGetOutBalance(Y.AA.SD,TOTAL.AMT);* R22 Manual conversion
    Y.AA.BAL    = TOTAL.AMT
*
RETURN

FIND.BY.ACCOUNT:

    R.ACCOUNT = '' ; Y.ERR = ''
    CALL F.READ(FN.ACCOUNT,Y.AA.SD,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.AA.SD = R.ACCOUNT<AC.ARRANGEMENT.ID>

RETURN

PROCESS.DEL:

    Y.OLD.AA.ID = CHANGE(Y.OLD.AA.ID,@SM,@VM) ;*R22 Auto Code Conversion
    Y.OLD.VM = DCOUNT(Y.OLD.AA.ID,@VM)      ;*R22 Auto Code Conversion
    FLG.O = ''

    LOOP
    WHILE Y.OLD.VM GT 0 DO
        FLG.O += 1
        Y.AA.SD = Y.OLD.AA.ID<1,FLG.O>
        POS.OLD = '' ; Y.AA.ID.ARR = Y.AA.ID ; Y.AA.ID.ARR = CHANGE(Y.AA.ID.ARR,@VM,@FM) ;*R22 Auto Code Conversion

        LOCATE Y.AA.SD IN Y.AA.ID.ARR SETTING POS.OLD ELSE

            idArrangementComp = Y.AA.SD ; idPropertyClass = 'TERM.AMOUNT' ; idProperty = 'COMMITMENT' ;effectiveDate = TODAY ; returnConditions = ''
            CALL AA.GET.ARRANGEMENT.CONDITIONS(idArrangementComp, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
            returnConditions = RAISE(returnConditions)

            Y.AA.COLL.ODS = returnConditions<AA.AMT.LOCAL.REF,Y.COL.POS>
            Y.AA.COLL.ODS = CHANGE(Y.AA.COLL.ODS,@SM,@VM) ; Y.CL.CNT.OD = DCOUNT(Y.AA.COLL.ODS,@VM) ;*R22 Auto Code Conversion

            Y.AA.COLS.VALS.OD = returnConditions<AA.AMT.LOCAL.REF,Y.COL.VAL.POS>
            Y.AA.COLS.VALS.OD = CHANGE(Y.AA.COLS.VALS.OD,@SM,@VM) ;*R22 Auto Code Conversion

            AAA.REQ = ''
            GOSUB PROCESS.DEL.SUB
        END
        Y.OLD.VM -= 1
    REPEAT

RETURN

PROCESS.AAA:

    AAA.REQ<AA.ARR.ACT.ACTIVITY> = 'LENDING-UPDATE-COMMITMENT'
    AAA.REQ<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
    AAA.REQ<AA.ARR.ACT.ARRANGEMENT> = Y.AA.SD
    AAA.REQ<AA.ARR.ACT.PROPERTY,1> = 'COMMITMENT'

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    IN.FUNCTION = 'I'
    VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ZERO.AUTH'

    CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, AAA.REQ, PROCESS.MSG)          ;*Form the OFS Message

    OFS.MSG.ID = ''
    OFS.SOURCE = 'TRIGGER.COL'
    OFS.ERR = ''

    CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)


RETURN

PROCESS.DEL.SUB:

    LOCATE ID.NEW IN Y.AA.COLL.ODS<1,1> SETTING POS.OL.COD THEN

        IF Y.CL.CNT.OD GT 1 THEN
            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL:':POS.OL.COD:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = '|-|'

* AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.VAL:':POS.OL.COD:':1'
* AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = '|-|'

* AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.DESC:':POS.OL.COD:':1'
* AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = '|-1|'
        END ELSE
            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL:':POS.OL.COD:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = 'NULL'

            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.VAL:':POS.OL.COD:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = 'NULL'

            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.DESC:':POS.OL.COD:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = 'NULL'
* PACS00307565 - S
            AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.AV.COL.BAL:':POS.OL.COD:':1'
            AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,-1> = 'NULL'
* PACS00307565 - E
        END

        GOSUB PROCESS.AAA
    END

RETURN

PGM.END:

END
