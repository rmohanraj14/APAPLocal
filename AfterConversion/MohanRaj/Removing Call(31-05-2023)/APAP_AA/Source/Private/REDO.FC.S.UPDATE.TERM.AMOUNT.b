* @ValidationCode : MjoxODAyMjc4MDUwOkNwMTI1MjoxNjg1NTMwOTUwMDc0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:32:30
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
$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.FC.S.UPDATE.TERM.AMOUNT
    
* Subroutine Type : ROUTINE
* Attached to     : COLLATERAL.RIGHT,REDO.INGRESO and COLLATERAL.RIGHT,REDO.MANTENIMIENTO
* Attached as     : Auth Routine so that the AA activity message is posted in OFS.MESSAGE.QUEUE
* Primary Purpose : Update the field ID.GARANTIA in TERM.AMOUNT property of AA when the user performs
*  an association or disassociation of the limit
*  This routine reads the values from the application COLLATERAL.RIGHT and triggers an
*  AA Activity 'LENDING-RENEGOTIATE-ARRANGEMENT' which will update the TERM.AMOUNT
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*
*-----------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : VC-ctor Panchi - TAM Latin America
* Date            : 10 Nov 2011
*
* Modify for      : Pablo Castillo - TAM Latin America
* Date            : 29 Jun 2012
* Changes         : Revision Pablo

*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL        AUTO R22 CODE CONVERSION        VM TO @VM,SM TO @SM,FM TO @FM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.REDO.CUSTOMER.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $USING APAP.TAM

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS.MAIN

RETURN  ;* Program RETURN

*------------------------
INITIALISE:
*=========
    R.COLLATERAL   = ''
*R.AA.ARR.CUSTOMER   = ''
*R.AA.ARR.LIMIT = ''
    R.AA.ARR.TERM.AMOUNT = ''
    R.AA.ACCOUNT.DETAILS = ''

    Y.LIM.REF.COUNT = ''
    Y.LIM.REF = ''
    Y.ID.CUSTOMER = ''
    Y.ID.LIMIT = ''
    Y.COLLATERAL.COUNT = ''
*Id Collateral.Rihgt + 1
    Y.ID.COLLATERAL = ID.NEW : ".1"
    Y.ID.COLL.RIGHT = ID.NEW

    Y.AA.REQUEST = ''
    PROPERTY.CLASS = 'TERM.AMOUNT'
    Y.ARR.ID = ''

    REDO.COLL.LIST = ''
    Y.LIST.ID = ''

* L.AA.COL (Collateral) from AA.PRD.DES.TERM.AMOUNT

    Y.FIELD = "L.AA.COL"
    Y.FIELD.COL.AMOUNT = "L.AA.COL.VAL"
    Y.FIELD.COL.DESCRP = "L.AA.COL.DESC"  ;* PACS00290578 - S/E
    Y.FIELD.NAME = Y.FIELD:@VM:Y.FIELD.COL.AMOUNT ;*AUTO R22 CODE COVERSION

    Y.POS = ''
    CALL MULTI.GET.LOC.REF("AA.PRD.DES.TERM.AMOUNT",Y.FIELD.NAME,Y.POS)
    Y.COLL.FIELD.POS = Y.POS<1,1>
    Y.COL.AMT.POS = Y.POS<1,2>
    Y.COL.DES.POS = Y.POS<1,3>  ;* PACS00290578 - S/E
*PROCESS.GOAHEAD = 1
    Y.PROCESAR = 0
RETURN

*------------------------
OPEN.FILES:
*=========
    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL  = ''
    CALL OPF(FN.COLLATERAL, F.COLLATERAL)

    FN.AA.ARR.CUSTOMER = 'F.AA.ARR.CUSTOMER'
    F.AA.ARR.CUSTOMER  = ''
    CALL OPF(FN.AA.ARR.CUSTOMER, F.AA.ARR.CUSTOMER)

    FN.AA.ARR.LIMIT = 'F.AA.ARR.LIMIT'
    F.AA.ARR.LIMIT  = ''
    CALL OPF(FN.AA.ARR.LIMIT, F.AA.ARR.LIMIT)

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT  = ''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT, F.AA.ARR.TERM.AMOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF (FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)

    FN.REDO.CUSTOMER.ARRANGEMENT = 'F.REDO.CUSTOMER.ARRANGEMENT'; F.REDO.CUSTOMER.ARRANGEMENT = ''
    CALL OPF(FN.REDO.CUSTOMER.ARRANGEMENT,F.REDO.CUSTOMER.ARRANGEMENT)

    FN.ACCOUNT.HIS = 'F.ACCOUNT$HIS'; F.ACCOUNT.HIS = ''
    CALL OPF(FN.ACCOUNT.HIS,F.ACCOUNT.HIS)

* VERSION DE AUTORIZACION S SANTIAGO APAP.H.INSURANCE.DETAILS,REDO.AUTORIZACION
RETURN

*-----------------------------------------------------------------------------------
PROCESS.MAIN:
*============

    BEGIN CASE
        CASE PGM.VERSION EQ ',REDO.INGRESO'
            Y.LIM.REF.COUNT = DCOUNT(R.NEW(COLL.RIGHT.LIMIT.REFERENCE), @VM) ;*AUTO R22 CODE COVERSION
            Y.LIMIT.REFERENCE =  R.NEW(COLL.RIGHT.LIMIT.REFERENCE)
        CASE PGM.VERSION EQ ',REDO.MANTENIMIENTO'
            Y.LIM.REF.COUNT = DCOUNT(R.OLD(COLL.RIGHT.LIMIT.REFERENCE), @VM) ;*AUTO R22 CODE COVERSION
            Y.LIMIT.REFERENCE = R.OLD(COLL.RIGHT.LIMIT.REFERENCE)
    END CASE
    IF Y.LIM.REF.COUNT GT 0 THEN
        GOSUB GET.COLL.FROM.RIGHT
* FOR I=1 TO Y.LIM.REF.COUNT
        FOR I.VAR=1 TO Y.LIM.REF.COUNT ;*AUTO R22 CODE COVERSION
* LIMIT.REFERENCE equal to IdCustomer.IdLimit.Sec
*Y.LIM.REF = R.COLLATERAL(COLL.RIGHT.LIMIT.REFERENCE)<1,I>
*Y.LIM.REF = Y.LIMIT.REFERENCE<1,I>
            Y.LIM.REF = Y.LIMIT.REFERENCE<1,I.VAR> ;*AUTO R22 CODE COVERSION
            Y.ID.CUSTOMER = FIELD(Y.LIM.REF,'.',1)

            Y.ID.LIMIT.AUX = FIELD(Y.LIM.REF,'.',2)
            Y.ID.LIMIT.AUX1 = Y.ID.LIMIT.AUX + 0

            Y.ID.LIMIT = Y.ID.LIMIT.AUX1 : "." : FIELD(Y.LIM.REF,'.',3)
* Get loan form primary owner
            GOSUB GET.LOAN.FROM.OWNER
	     
* NEXT I
        NEXT I.VAR ;*AUTO R22 CODE COVERSION
    END

RETURN

*-----------------------------------------------------------------------------------
GET.LOAN.FROM.OWNER:
*============
* Execute select in AA.ARR.CUSTOMER TABLE
* SELECT.STATEMENT =  "SELECT ": FN.AA.ARR.CUSTOMER : " WITH PRIMARY.OWNER EQ ": Y.ID.CUSTOMER
* REDO.AA.CUSTOMER.LIST = ''
*LIST.NAME = ''
* NO.OF.REC.CUSTOMER = ''
* Y.AA.CUSTOMER.ERR = ''
*  REDO.AA.CUSTOMER.ID = ''
    Y.AA.CUSTOMER.POS = ''; Y.AA.ID = ''
* CALL EB.READLIST(SELECT.STATEMENT,REDO.AA.CUSTOMER.LIST,LIST.NAME,NO.OF.REC.CUSTOMER,Y.AA.CUSTOMER.ERR)

    ERR.REDO.CUSTOMER.ARRANGEMENT = ''; R.REDO.CUSTOMER.ARRANGEMENT = ''
    CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.ID.CUSTOMER,R.REDO.CUSTOMER.ARRANGEMENT,F.REDO.CUSTOMER.ARRANGEMENT,ERR.REDO.CUSTOMER.ARRANGEMENT)
    YFLD.VAL1 = R.REDO.CUSTOMER.ARRANGEMENT<CUS.ARR.CLOSED>
    YFLD.VAL2 = R.REDO.CUSTOMER.ARRANGEMENT<CUS.ARR.OWNER>
    CHANGE @SM TO @FM IN YFLD.VAL1 ;*AUTO R22 CODE COVERSION
    CHANGE @VM TO @FM IN YFLD.VAL1 ;*AUTO R22 CODE COVERSION
    CHANGE @SM TO @FM IN YFLD.VAL2 ;*AUTO R22 CODE COVERSION
    CHANGE @VM TO @FM IN YFLD.VAL2 ;*AUTO R22 CODE COVERSION
    REDO.AA.CUSTOMER.LIST = YFLD.VAL1
    IF YFLD.VAL2 THEN
        REDO.AA.CUSTOMER.LIST<-1> = YFLD.VAL2
    END
    LOOP
        REMOVE Y.AA.ID FROM REDO.AA.CUSTOMER.LIST SETTING Y.AA.CUSTOMER.POS
    WHILE Y.AA.ID : Y.AA.CUSTOMER.POS
        IF Y.AA.ID[1,1] EQ '1' THEN
            ERR.ACCOUNT = ''; R.ACCOUNT = ''
            Y.AA.ID = Y.AA.ID:";1"
            CALL F.READ(FN.ACCOUNT.HIS,Y.AA.ID,R.ACCOUNT,F.ACCOUNT.HIS,ERR.ACCOUNT)
            Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        END
*     Y.AA.ID = FIELD(REDO.AA.CUSTOMER.ID,'-',1)
*            Y.AA.ID = 'AA13121JRMLF'
        GOSUB GET.LOAN.FROM.LIMIT
    REPEAT

RETURN

*-----------------------------------------------------------------------------------
GET.LOAN.FROM.LIMIT:
*============
* Execute select in AA.ARR.LIMIT TABLE
    SELECT.STATEMENT.LIMIT =  "SELECT ": FN.AA.ARR.LIMIT : " WITH @ID LIKE ": Y.AA.ID : "..."
    SELECT.STATEMENT.LIMIT :=  " AND LIMIT.REFERENCE EQ " : Y.ID.LIMIT
    REDO.AA.LIMIT.LIST = ''
    LIST.NAME.LIMIT = ''
    NO.OF.REC.LIMIT = ''
    Y.AA.LIMIT.ERR = ''
    REDO.AA.LIMIT.ID = ''
    Y.AA.LIMIT.POS = ''
    Y.ARR.ID = ''
    CALL EB.READLIST(SELECT.STATEMENT.LIMIT,REDO.AA.LIMIT.LIST,LIST.NAME.LIMIT,NO.OF.REC.LIMIT,Y.AA.LIMIT.ERR)
    IF NO.OF.REC.LIMIT GT 0 THEN
        LOOP
            REMOVE REDO.AA.LIMIT.ID FROM REDO.AA.LIMIT.LIST SETTING Y.AA.LIMIT.POS
        WHILE REDO.AA.LIMIT.ID : Y.AA.LIMIT.POS
            Y.ARR.ID = FIELD(REDO.AA.LIMIT.ID,'-',1)
*            Y.ARR.ID = 'AA13121JRMLF' ;*AUTO R22 CODE COVERSION
            GOSUB GET.TERM.AMOUNT
        REPEAT
    END

RETURN

*-----------------------------------------------------------------------------------
GET.COLL.FROM.RIGHT:
*============
* Execute select in COLLATERAL TABLE
    SELECT.STATEMENT.COLL =  "SELECT ": FN.COLLATERAL : " WITH @ID LIKE ": Y.ID.COLL.RIGHT : "..."
    LIST.NAME.COLL = ''
    NO.OF.REC.COLL = ''
    Y.COLL.ERR = ''

    CALL EB.READLIST(SELECT.STATEMENT.COLL,REDO.COLL.LIST,LIST.NAME.COLL,NO.OF.REC.COLL,Y.COLL.ERR)

RETURN

*-----------------------------------------------------------------------------------
GET.TERM.AMOUNT:
*============
* Execute select in AA.ARR.TERM.AMOUNT TABLE
    SELECT.STATEMENT.TERM =  "SELECT ": FN.AA.ARR.TERM.AMOUNT : " WITH @ID LIKE ": Y.ARR.ID : "... "  ;* AND ACTIVITY "
    SELECT.STATEMENT.TERM :=  " BY-DSND DATE.TIME"
    REDO.TERM.LIST = ''
    LIST.NAME.TERM = ''
    NO.OF.REC.TERM = ''
    Y.TERM.ERR = ''
*TERM.ID = ''
    Y.TERM.POS = ''
    Y.TERM.ID = ''


    CALL EB.READLIST(SELECT.STATEMENT.TERM,REDO.TERM.LIST,LIST.NAME.TERM,NO.OF.REC.TERM,Y.TERM.ERR)
    IF NO.OF.REC.TERM GT 0 THEN
        Y.TERM.ID = REDO.TERM.LIST<1>
*        Y.TERM.ID = "AA13121JRMLF-COMMITMENT-20130501.10" ;*AUTO R22 CODE COVERSION
* LOOP
*    REMOVE Y.TERM.ID FROM REDO.TERM.LIST SETTING Y.TERM.POS
* WHILE Y.TERM.ID : Y.TERM.POS
* Y.TERM.ID = FIELD(REDO.AA.LIMIT.ID,'-',1)
        PRINT " ============================================================================================ Y.TERM.ID " :Y.TERM.ID
        CALL F.READ(FN.AA.ARR.TERM.AMOUNT,Y.TERM.ID,R.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT,Y.TERM.ERR)
        IF R.AA.ARR.TERM.AMOUNT THEN
            GOSUB GET.COLL.FROM.TERM.AMOUNT
        END
* REPEAT
    END

RETURN

*-----------------------------------------------------------------------------------
GET.COLL.FROM.TERM.AMOUNT:
*============
* Get Collateral from TERN.AMOUNT
    PRINT "REDO.FC.S.UPDATE.TERM.AMOUNT =================================================================================== Y.ARR.ID " :Y.ARR.ID
    IF Y.ARR.ID MATCHES Y.LIST.ID THEN
        RETURN
    END
    Y.LIST.ID := @VM : Y.ARR.ID ;*AUTO R22 CODE COVERSION

    Y.AA.REQUEST = ''
    Y.AA.REQUEST<AA.ARR.ACT.ARRANGEMENT> = Y.ARR.ID
    Y.AA.REQUEST<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
*    Y.AA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-RENEGOTIATE-ARRANGEMENT'

    Y.AA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-CHANGE.TERM-COMMITMENT'

    GOSUB GET.PROPERTY
    Y.AA.REQUEST<AA.ARR.ACT.PROPERTY,-1> = AA.PROPERTY

    Y.COLLATERAL.COUNT = DCOUNT(R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COLL.FIELD.POS>, @SM)
    Y.AA.COL.IDS = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COLL.FIELD.POS>
    PRINT "REDO.FC.S.UPDATE.TERM.AMOUNT =================================================================================== Y.AA.COL.IDS " :Y.AA.COL.IDS
    CHANGE @SM TO @VM IN Y.AA.COL.IDS ;*AUTO R22 CODE COVERSION
    Y.AA.COL.AMT = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COL.AMT.POS>
    CHANGE @SM TO @VM IN Y.AA.COL.AMT ;*AUTO R22 CODE COVERSION
*  PACS00290578 - S
    Y.AA.COL.DES = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COL.DES.POS>
    CHANGE @SM TO @VM IN Y.AA.COL.DES ;*AUTO R22 CODE COVERSION
*  PACS00290578 - E
    Y.ACTIVIDAD = ''

    BEGIN CASE
        CASE PGM.VERSION EQ ',REDO.INGRESO'
*        Y.AA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-RENEGOTIATE-ARRANGEMENT'
            Y.BAND.DELETE = 0
            GOSUB BUILD.OFS.UPDATE
        CASE PGM.VERSION EQ ',REDO.MANTENIMIENTO'
            Y.BAND.DELETE = 1
            GOSUB BUILD.OFS.DELETE
*        Y.AA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'CHANGE.TERM.AMOUNT'
    END CASE

RETURN
*-----------------------------------------------------------------------------------
UPDATE.TERM.AMOUNT:
*============
* RUTINA QUE ELIMINA COLLATERAL

    IF Y.BAND.DELETE THEN
        APAP.TAM.redoDelClBalance(Y.ARR.ID, Y.ID.COLLATERAL);* R22 Manual conversion
    END

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    IN.FUNCTION = 'I'
    VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ZERO.AUTH'
    AAA.ID = ''


    CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, Y.AA.REQUEST, PROCESS.MSG)    ;

    GOSUB TRIGGER.OFS ;* Post the OFS in the queue

RETURN

*-----------------------------------------------------------------------------------------------------------
BUILD.OFS.UPDATE:
*============
* Build ofs to update TERM.AMOUNT, Update Id.Collateral (L.AA.COL.VAL)

    I.COLL.CNT = Y.COLLATERAL.COUNT + 1

    IF REDO.COLL.LIST THEN
        LOOP
            REMOVE REDO.COLL.ID FROM REDO.COLL.LIST SETTING Y.COLL.POS
        WHILE REDO.COLL.ID : Y.COLL.POS
            Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD:":":I.COLL.CNT:':1'
            Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = REDO.COLL.ID

            I.COLL.CNT += 1
            Y.ALLOW = 1
        REPEAT

        IF Y.ALLOW THEN
            GOSUB UPDATE.TERM.AMOUNT
        END
    END

RETURN

*-----------------------------------------------------------------------------------------------------------
BUILD.OFS.DELETE:
*============

* Build ofs to update TERM.AMOUNT, Update Id.Collateral (L.AA.COL.VAL)
    Y.ALLOW = ''

    FOR I.COLL.CNT=1 TO Y.COLLATERAL.COUNT
*  Y.ID.COLLATERAL.AUX = R.AA.ARR.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.COLL.FIELD.POS,I.COLL.CNT>
* Validate if Y.ID.COLLATERAL equals to Y.ID.COLLATERAL.AUX
*    IF REDO.COLL.LIST THEN
*       LOOP
*            REMOVE REDO.COLL.ID FROM REDO.COLL.LIST SETTING Y.COLL.POS
*        WHILE REDO.COLL.ID : Y.COLL.POS
        GOSUB CALL.OFS.DELETE
*        REPEAT
*    END
    NEXT I.COLL.CNT

    IF Y.ALLOW THEN
        GOSUB UPDATE.TERM.AMOUNT
    END

RETURN


*-----------------------------------------------------------------------------------------------------------
CALL.OFS.DELETE:
*============
    IF Y.ID.COLLATERAL EQ Y.AA.COL.IDS<1,I.COLL.CNT> THEN
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD:":":I.COLL.CNT:':1'
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = "NULL"
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD.COL.AMOUNT:":":I.COLL.CNT:':1'
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = "NULL"
*        Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD.COL.DESCRP:":":Y.FIELD.COL.AMOUNT:":":I.COLL.CNT:':1' ;* PACS00290578 - S
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD.COL.DESCRP:":":I.COLL.CNT:':1'
        Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = "NULL"
*  PACS00290578 - E
        Y.ALLOW = 1
    END
* ELSE
*    Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD:":":I.COLL.CNT:':1'
*    Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.COL.IDS<1,I.COLL.CNT>
*  Y.AA.REQUEST<AA.ARR.ACT.FIELD.NAME,1,-1> = Y.FIELD.COL.AMOUNT:":":I.COLL.CNT:':1'
*      Y.AA.REQUEST<AA.ARR.ACT.FIELD.VALUE,1,-1> = Y.AA.COL.AMT<1,I.COLL.CNT>
*      Y.ALLOW = 1

*  END

RETURN

*-----------------------------------------------------------------------------------------------------------
GET.PROPERTY:
*============
* Get the property Name for the property class

    ARR.INFO = ''
    R.ARRANGEMENT = ''
    AA.PROPERTY = ''

    CALL F.READ(FN.AA.ACCOUNT.DETAILS, Y.ARR.ID, R.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS, READ.ERR)

    IF R.AA.ACCOUNT.DETAILS THEN
        ARR.INFO<1> = Y.ARR.ID
        ARR.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BASE.DATE>

        CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, ARR.DATE, R.ARRANGEMENT, PROP.LIST)

        CLASS.LIST = ''
        CALL AA.GET.PROPERTY.CLASS (PROP.LIST, CLASS.LIST)

        CLASS.LIST = RAISE(CLASS.LIST)
        PROP.LIST = RAISE(PROP.LIST)

        CLASS.CTR = ''
        LOOP
            REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
            CLASS.CTR +=1
        WHILE Y.CLASS:CLASS.POS
            IF Y.CLASS EQ PROPERTY.CLASS THEN
                AA.PROPERTY = PROP.LIST<CLASS.CTR>
                RETURN
            END
        REPEAT
    END

RETURN

*-----------------------------------------------------------------------------------------------------------
TRIGGER.OFS:
*============
* This posts the OFS message formed to the OFS.MESSAGE.QUEUE for processing
*
    OFS.MSG.ID = ''
    OFS.SOURCE = 'FC.OFS'       ;* INCREMENT REVISION PABLO
*OFS.SOURCE = 'OFS.TERM.AMOUNT' ;*COMENTADO REVISION PABLO
    OFS.ERR = ''
    PRINT "REDO.FC.S.UPDATE.TERM.AMOUNT =================================================================================== PROCESS.MSG " :PROCESS.MSG
    CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)    ;* TODO: DESCOMENTAR
RETURN
END
