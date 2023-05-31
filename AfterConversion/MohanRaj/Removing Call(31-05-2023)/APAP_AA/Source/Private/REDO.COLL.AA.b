* @ValidationCode : MjoxMTc4MzA3MjQwOkNwMTI1MjoxNjg1NTI5NzI4NTg0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:12:08
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
SUBROUTINE REDO.COLL.AA
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.CRED.COLL
* Attached as     : ROUTINE
* Primary Purpose : Link Collateral with Arrangement
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
* Error Variables:
*---------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            : DISPO VALUE FOR ARRANGEMENT
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE
* 29-MAR-2023   Conversion Tool          R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM and CHAR to CHARX
* 29-MAR-2023      Harsha                R22 Manual Conversion - CALL method format changed
*---------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $USING APAP.REDOSRTN

    GOSUB INITIALISE
    GOSUB PROCESS.OFS
RETURN

*----------------------------------------------------------------------------------------------------------

INITIALISE:
*
    AAA.REQUEST = ''
    PROPERTY.CLASS = ''
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''
    CALL OPF (FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
*Get the collateral ID
    COLL.ID = ID.NEW.LAST
    Y.COL.VAL = R.NEW(COLL.NOMINAL.VALUE)
****Get the ID for arrangement****
    GOSUB GET.ARRANGEMENT
    CALL F.READ(FN.AA.ACCOUNT.DETAILS, ARR.ID, R.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS, READ.ERR)
    FN.TERM = 'F.AA.ARR.TERM.AMOUNT'
    F.TERM  = ''
    R.TERM  = ''
    Y.TERM  = ''
    CALL OPF(FN.TERM,F.TERM)

    Y.AA.BAL.VAL = ''

RETURN
*-----------------------------------------------------------------------------------------------------------
GET.ARRANGEMENT:
***GET THE ARRANGEMENT ID BECAUSE THE USER  MUST BE SET OTHE CODE***
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
*Read the local fields

    LOC.REF.FIELDS = "L.AC.LK.COL.ID"
    LOC.REF.POS = ''

*Get the position for all fields
    LOC.REF.APPL = "COLLATERAL"
    GOSUB LOCAL.FIELDS.POS
    WPOS.CRED  = LOC.REF.POS<1,1>
    VAR.CRED = R.NEW(COLL.LOCAL.REF)<1,WPOS.CRED>
* PACS00307565 - S
    Y.AA.NUM = DCOUNT(VAR.CRED,@SM)
    VAR.CRED = VAR.CRED<1,1,Y.AA.NUM>
* PACS00307565 - E
    IF VAR.CRED MATCHES "AA..." THEN      ;*GET THE INFORMATION FOR THE SALD FOR ARRANGEMENT
        GOSUB READ.AA.ARRANGEMENT
    END
    ELSE
        GOSUB READ.ACCOUNT
    END
RETURN

*=============================
READ.AA.ARRANGEMENT:
*=============================
    CALL F.READ(FN.AA.ARRANGEMENT, VAR.CRED, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)
    IF R.AA.ARRANGEMENT THEN
        ARR.ID = VAR.CRED
    END
RETURN
*=============================
READ.ACCOUNT:
*=============================
    CALL F.READ(FN.ACCOUNT,VAR.CRED,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    ARR.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>

RETURN
*
*=================
GET.CO.DESC.FIELD:
*=================
*
    Y.ROW.CNC = ''
    Y.CNT.DES = DCOUNT(Y.CO.DES.VAL,@SM)
    Y.CTR = 1
    LOOP
    WHILE Y.CTR LE Y.CNT.DES
        IF Y.ROW.CNC EQ '' THEN
            Y.ROW.CNC = Y.CO.DES.VAL<1,1,Y.CTR>
        END
        ELSE
            Y.ROW.CNC := ' ' :Y.CO.DES.VAL<1,1,Y.CTR>
        END
        Y.CTR += 1   ;*R22 Auto Conversion
    REPEAT
*
RETURN
*
*---------------------------------------------------------------------------------------------------------
PROCESS.OFS:

    AAA.REQUEST<AA.ARR.ACT.ARRANGEMENT> = ARR.ID
    AAA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-CHANGE.TERM-COMMITMENT'
    AAA.REQUEST<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
    GOSUB FORM.TERM
    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    IN.FUNCTION = 'I'
    VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ZERO.AUTH'

    CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, AAA.REQUEST, PROCESS.MSG)      ;*Form the OFS Message
    GOSUB TRIGGER.OFS ;* Post the OFS in the queue
RETURN
*-----------------------------------------------------------------------------------------------------------
FORM.TERM:
* This forms the OFS message request for CHARGE property



    PROPERTY.CLASS = "TERM.AMOUNT"

    GOSUB GET.PROPERTY
    AAA.REQUEST<AA.ARR.ACT.PROPERTY,-1> = AA.PROPERTY         ;*R.NEW(INS.DET.CHARGE)<1,1>  ;* Charge property to be updated as part of Insurance
    GOSUB GET.LOCAL.FIELDS
    GOSUB GET.VALUES.LOCAL.FIELDS
    GOSUB GET.AA.CUR.BAL        ;* PACS00307565 - S/E
    GOSUB ARMA.OFS

RETURN



*-----------------------------------------------------------------------------------------------------------

ARMA.OFS:
    NUM.ITR = 1

    IF Y.AA.COL THEN
        LOCATE COLL.ID IN Y.AA.COL<1,1> SETTING Y.POS.AA THEN
            Y.AA.COL.VAL<1,Y.POS.AA>  = Y.COL.VAL       ;*Para actualizar el VNG en AA
* PACS00310867 - S
            Y.AA.COL.DESC<1,Y.POS.AA> = Y.ROW.CNC[1,65] ;* According with LOCAL.TABLE field, maximum char value.
* PACS00310867 - E
* PACS00307565 - S
            Y.AA.COL.BAL<1,Y.POS.AA> = Y.AA.BAL
* PACS00307565 - E
        END
        ELSE
            Y.AA.COL := @VM : COLL.ID
            Y.AA.COL.VAL := @VM : Y.COL.VAL    ;*Para actualizar el VNG en AA
* PACS00310867 - S
            Y.AA.COL.DESC := @VM : Y.ROW.CNC[1,65]       ;* According with LOCAL.TABLE field, maximum char value.
* PACS00310867 - E
* PACS00307565 - S
            Y.AA.COL.BAL := @VM : Y.AA.BAL
* PACS00307565 - E
        END
    END
    ELSE
        Y.AA.COL = COLL.ID
        Y.AA.COL.VAL = Y.COL.VAL  ;*Para actualizar el VNG en AA
* PACS00310867 - S
        Y.AA.COL.DESC = Y.ROW.CNC[1,65]     ;* According with LOCAL.TABLE field, maximum char value.
* PACS00310867 - E
* PACS00307565 - S
        Y.AA.COL.BAL = Y.AA.BAL
* PACS00307565 - E
    END

    LOOP
        REMOVE COLL.ID  FROM Y.AA.COL SETTING POS
    WHILE COLL.ID :POS
        AAA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL:':NUM.ITR:':1'
        AAA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = COLL.ID
        AAA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.VAL:':NUM.ITR:':1'      ;*Para actualizar el VNG en AA
        AAA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.COL.VAL<1,NUM.ITR>          ;*Para actualizar el VNG en AA
* PACS00310867 - S
        AAA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.COL.DESC:':NUM.ITR:':1'     ;*Description AA updation
        AAA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.COL.DESC<1,NUM.ITR>         ;*Description AA updation
* PACS00310867 - E
* PACS00307565 - S
        AAA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = 'L.AA.AV.COL.BAL:':NUM.ITR:':1'   ;*AA Balance at attachement moment
        AAA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.COL.DESC<1,NUM.ITR>         ;*AA Balance at attachement moment
* PACS00307565 - E
        NUM.ITR += 1  ;*R22 Auto Conversion

    REPEAT
RETURN

*-----------------------------------------------------------------------------------------------------------

GET.AA.CUR.BAL:
* Get outstanding from AA
    Y.AA.BAL = ''
    APAP.REDOSRTN.redoSGetOutBalance(VAR.CRED,TOTAL.AMT);* R22 Manual conversion
    Y.AA.BAL    = TOTAL.AMT
*
RETURN

*-----------------------------------------------------------------------------------------------------------

GET.LOCAL.FIELDS:


    LOC.REF.POS = ''
* PACS00310867 - S
    LOC.REF.APPL="AA.PRD.DES.TERM.AMOUNT":@FM:"COLLATERAL"
*    LOC.REF.FIELDS = "L.AA.COL":VM:'L.AA.COL.VAL'
    LOC.REF.FIELDS = "L.AA.COL":@VM:'L.AA.COL.VAL':@VM:'L.AA.COL.DESC':@VM:'L.AA.AV.COL.BAL':@FM:'L.COL.PRO.DESC2'  ;* PACS00307565 - S/E
    GOSUB LOCAL.FIELDS.POS
    Y.AA.COL.POS    = LOC.REF.POS<1,1>
    Y.AA.VAL.POS    = LOC.REF.POS<1,2>
    Y.AA.DES.POS    = LOC.REF.POS<1,3>
    Y.CO.DES.POS    = LOC.REF.POS<2,1>
    Y.AA.BAL.POS    = LOC.REF.POS<1,4>    ;* PACS00307565 - S/E
* PACS00310867 - E
*
RETURN
*-----------------------------------------------------------------------------------------------------------
GET.VALUES.LOCAL.FIELDS:


    idArrangementComp = ARR.ID
    idPropertyClass = PROPERTY.CLASS
    idProperty = AA.PROPERTY
    effectiveDate = ''
    returnIds = ''
    returnConditions = ''
    returnError = ''

    CALL AA.GET.ARRANGEMENT.CONDITIONS(idArrangementComp, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)

    Y.AA.COL = returnConditions<1,AA.AMT.LOCAL.REF,Y.AA.COL.POS>
    Y.AA.COL.VAL = returnConditions<1,AA.AMT.LOCAL.REF,Y.AA.VAL.POS>
    Y.AA.BAL.VAL = returnConditions<1,AA.AMT.LOCAL.REF,Y.AA.BAL.POS>    ;* PACS00307565 -S/E
    MMARK = CHARX(251)   ;*R22 Auto Conversion  - CHAR to CHARX
    Y.AA.COL = CHANGE(Y.AA.COL, MMARK , @VM )
    Y.AA.COL.VAL = CHANGE( Y.AA.COL.VAL, MMARK , @VM )
* PACS00310867 - S
    Y.CO.DES.VAL = R.NEW(COLL.LOCAL.REF)<1,Y.CO.DES.POS>
    GOSUB GET.CO.DESC.FIELD
* PACS00310867 - E
* PACS00307565 - S
    Y.AA.BAL.VAL = CHANGE(Y.AA.BAL.VAL, MMARK , @VM )
* PACS00307565 - E
RETURN

*-----------------------------------------------------------------------------------------------------------
GET.PROPERTY:
* Get the property Name for the property class

    ARR.INFO = ''
    R.ARRANGEMENT = ''
    AA.PROPERTY = ''
    ARR.INFO<1> = ARR.ID        ;*"AA10214T9MVZ"
    ARR.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BASE.DATE>
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, ARR.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    CALL AA.GET.PROPERTY.CLASS (PROP.LIST, CLASS.LIST)
    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    CLASS.CTR = ''

    LOOP

        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS

        CLASS.CTR +=1   ;*R22 Auto Conversion

    WHILE Y.CLASS:CLASS.POS

        IF Y.CLASS EQ PROPERTY.CLASS THEN

            AA.PROPERTY = PROP.LIST<CLASS.CTR>

            BREAK

        END

    REPEAT
RETURN
*-----------------------------------------------------------------------------------------------------------
TRIGGER.OFS:
* This posts the OFS message formed to the OFS.MESSAGE.QUEUE for processing
*

    OFS.MSG.ID = ''
    OFS.SOURCE = 'TRIGGER.COLL'
    OFS.ERR = ''

    CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)

RETURN
*-----------------------------------------------------------------------------------------------------------
LOCAL.FIELDS.POS:

    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)

RETURN
END
