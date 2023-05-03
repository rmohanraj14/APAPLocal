* @ValidationCode : MjotMTA4NTQzOTI3MDpDcDEyNTI6MTY4MTg5MDQ5NTAwNDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:18:15
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
SUBROUTINE REDO.V.VAL.FEC.VEN.TP
*
* Subroutine Type : ROUTINE
* Attached to     : V.VAL.FEC.VEN.TP
* Attached as     : ROUTINE
* Primary Purpose : VERIFY THE DATE FOR EXPIRATION DATE
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            : 23/04/2012
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT

    GOSUB INITIALISE
    GOSUB OPEN.FILES
*
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    Y.FECHA =  R.NEW(COLL.LOCAL.REF)<1,WPOS.FECHA>
    Y.F.COL =  R.NEW(COLL.VALUE.DATE)

    IF (Y.FECHA LT Y.F.COL) THEN
        TEXT = "COLL.FEC.FP"
        M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
        CALL STORE.OVERRIDE(M.CONT)
    END

    VAR.CRED  =  R.NEW(COLL.LOCAL.REF)<1,WPOS.CRED>

*if the user change a creditos an delete the credit number
    IF VAR.CRED EQ '' THEN
        RETURN
    END

    VAR.CRED    =  R.NEW(COLL.LOCAL.REF)<1,WPOS.CRED>
*
    IF LEN(TRIM(VAR.CRED)) THEN
*
        GOSUB GET.AAID.SM         ;* PACS00307565 - S/E
*
*GET ALL VALUES FROM THE LIST AND ADD THE LOCK VALUE
        IF VAR.CRED EQ '' THEN
            AF = COLL.LOCAL.REF
* PACS00312670 - S
            AV = WPOS.CRED
* PACS00312670 - E
            ETEXT = 'ST-ERROR.SEL.CRED'
            CALL STORE.END.ERROR
            RETURN
        END



        P.AA.ID = Y.AA.ID
        idPropertyClass = "TERM.AMOUNT"     ;*SI Falla usar COMMITMENT
        ArrangementID = P.AA.ID ; idProperty = ''; effectiveDate = Y.PROCESS.DATE; returnIds = ''; R.CONDITION =''; returnConditions = ''; returnError = ''
        CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
        IF returnError THEN
            E = returnError
            RETURN
        END
        R.AA.TERM.AMOUNT = RAISE(returnConditions)
        Y.DAT.MAT = ""
        Y.DAT.MAT = R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>


*** VERIFY THAT DATE OF CREDIT WAS LOWER THAN END DATE CREDIT****
        IF (Y.FECHA LT Y.DAT.MAT) THEN
            TEXT = "COLL.FECH.DEP"
            M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
            CALL STORE.OVERRIDE(M.CONT)
        END
    END



RETURN
*----------------------------------------------------------------------------
*
GET.AAID.SM:
*===========
*
    Y.AA.NUM = DCOUNT(VAR.CRED,@SM)
    Y.VAR = 1
    LOOP
    WHILE Y.VAR LE Y.AA.NUM
        Y.AA.ID = FIELD(VAR.CRED,@SM,Y.VAR)
        GOSUB READ.AA.ACCT
        IF Y.ERR NE "" THEN
            BREAK
        END
        Y.VAR += 1
    REPEAT
*
RETURN
*
READ.AA.ACCT:
*===========
*

    IF Y.AA.ID MATCHES "AA..." THEN       ;*GET THE INFORMATION FOR THE SALD FOR ARRANGEMENT
        GOSUB READ.AA.ARRANGEMENT
    END
    ELSE
        GOSUB READ.ACCOUNT
    END
*
RETURN
*
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    FN.COLLATERAL   = 'F.COLLATERAL'
    F.COLLATERAL    = ''
    R.COLLATERAL    = ''

    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

*Set the local fild for read
    WCAMPO    = "L.COL.INVST.DT"
    WCAMPO<2> = "L.AC.LK.COL.ID"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOS.FECHA  = YPOS<1,1>
    WPOS.CRED   = YPOS<1,2>
    Y.PROCESS.DATE = ''
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*------------
*=============================
READ.AA.ARRANGEMENT:
*=============================
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)

    IF Y.ERR THEN
        VAR.CRED = ''
    END
RETURN
*=============================
READ.ACCOUNT:
*=============================
    CALL F.READ(FN.ACCOUNT,Y.AA.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)

    VAR.CRED = R.ACCOUNT<AC.ARRANGEMENT.ID>
    IF Y.ERR THEN
        VAR.CRED = ''
    END
RETURN
END
