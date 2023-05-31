* @ValidationCode : MjotMTYxOTI1NTU0NjpDcDEyNTI6MTY4NTUzMDE3NDE3Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:19:34
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
SUBROUTINE REDO.FC.S.MODCHR

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.CREATE.ARRANGEMENT.AUTHORISE
* Attached as     : ROUTINE
* Primary Purpose : Amend the charges from CALCULATE to FIXED
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
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            : 16 Jun 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           >= to GT
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION           CALL method format changed
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.CHARGE
    $INSERT I_System
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.AA.PAYMENT.RULES
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $USING APAP.REDOFCFI

    GOSUB INITIALISE

    IF PROCESS.GOAHEAD THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    Y.ID.NEW = FIELD(ID.NEW,"-",2)
    R.RCA.R.NEW = ''
    YERR = ''
    CALL F.READ(FN.RCA.R.NEW,Y.ARR.ID,R.RCA.R.NEW,F.RCA.R.NEW,YERR)

    IF NOT(YERR) THEN
        Y.PRODUCT = R.RCA.R.NEW<REDO.FC.PRODUCT>
        Y.AAID = R.RCA.R.NEW<REDO.FC.ID.ARRANGEMENT>

*
*         Y.PRODUCT = FIELD(Y.PRODUCT,'2',1)
*         Y.SESSION.VAR = "CURRENT.":Y.PRODUCT
*         E = ''
*         R.CHARGES = System.getVariable(Y.SESSION.VAR)
*         IF E THEN
*            SELECT.STATEMENT = 'SELECT ':FN.AA.PRD.DES.PAYMENT.RULES:' WITH @ID LIKE ':Y.PRODUCT:'...  BY-DSND @ID'
*            AA.PRD.DES.PAYMENT.RULES.LIST = ''
*            LIST.NAME = ''
*            SELECTED = ''
*            SYSTEM.RETURN.CODE = ''
*            CALL EB.READLIST(SELECT.STATEMENT,AA.PRD.DES.PAYMENT.RULES.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
*            REMOVE AA.PRD.DES.PAYMENT.RULES.ID FROM AA.PRD.DES.PAYMENT.RULES.LIST SETTING AA.PRD.DES.PAYMENT.RULES.MARK
*
*            CALL F.READ(FN.AA.PRD.DES.PAYMENT.RULES,AA.PRD.DES.PAYMENT.RULES.ID,R.AA.PRD.DES.PAYMENT.RULES,F.AA.PRD.DES.PAYMENT.RULES,YERR)
*
*            CALL System.setVariable(Y.SESSION.VAR, AA.PRD.DES.PAYMENT.RULES.ID)
*         END ELSE
*            AA.PRD.DES.PAYMENT.RULES.ID = R.CHARGES
*            CALL F.READ(FN.AA.PRD.DES.PAYMENT.RULES,AA.PRD.DES.PAYMENT.RULES.ID,R.AA.PRD.DES.PAYMENT.RULES,F.AA.PRD.DES.PAYMENT.RULES,YERR)
*
*         END

        R.DATA = Y.PRODUCT
        APAP.REDOFCFI.redoFcNofileChargesDis(R.DATA);* R22 Manual conversion

        Y.OCUR = INDEX(R.DATA, Y.ID.NEW, 1)

        IF Y.OCUR GT 0 THEN ;* AUTO R22 CODE CONVERSTION
* Assign to CERO value in all charges. it except charges sent through FC
            DIM AUX.NEW(C$SYSDIM)
            MAT AUX.NEW = ''
            MAT R.NEW =  MAT AUX.NEW
            Y.AMOUNT = Y.CHARG.AMOUNT<1,Y.POS>
            R.NEW(AA.CHG.ACTIVITY) = Y.ACT.ID
            R.NEW(AA.CHG.ACTION) = "UPDATE"
            R.NEW(AA.CHG.CURRENCY) = Y.CURRENCY
            R.NEW(AA.CHG.CHARGE.TYPE)= 'FIXED'
            R.NEW(AA.CHG.FIXED.AMOUNT) = "0.00"
        END
    END


    CALL CACHE.READ(FN.REDO.FC.CHARGES,YID.ARR,R.REDO.FC.CHARGES,YERR)
    IF R.REDO.FC.CHARGES THEN
        Y.CHARG.DISC   = R.REDO.FC.CHARGES<1>
        Y.CHARG.AMOUNT   =  R.REDO.FC.CHARGES<2>
        Y.CURRENCY    = R.REDO.FC.CHARGES<3>
        Y.ID.NEW = FIELD(ID.NEW,"-",2)
        LOCATE Y.ID.NEW IN Y.CHARG.DISC<1,1> SETTING Y.POS THEN
            Y.AMOUNT = Y.CHARG.AMOUNT<1,Y.POS>
            R.NEW(AA.CHG.CURRENCY) = Y.CURRENCY
            R.NEW(AA.CHG.FIXED.AMOUNT) = Y.AMOUNT
        END
    END

    CALL F.READ(FN.REDO.FC.PAYSCH,Y.AAID,R.REDO.FC.PAYSCH,F.REDO.FC.PAYSCH,PAY.ERR)
    IF R.REDO.FC.PAYSCH  THEN
        Y.ID.NEW = FIELD(ID.NEW,"-",2)
        LOCATE Y.ID.NEW IN R.REDO.FC.PAYSCH<AA.PS.PROPERTY,1> SETTING PLO THEN
            Y.AMT = R.REDO.FC.PAYSCH<AA.PS.ACTUAL.AMT,PLO>
            R.NEW(AA.CHG.FIXED.AMOUNT) = Y.AMT
        END
    END
RETURN



*------------------------
INITIALISE:
*=========

    IF (V$FUNCTION NE "I") THEN
        PROCESS.GOAHEAD = 0
        RETURN
    END

* Getting flag in order to know if transaction is coming through FC
    E = ""
    Y.ARR.ID = System.getVariable("CURRENT.RCA")
    IF E<1,1> EQ "EB-UNKNOWN.VARIABLE" THEN       ;*Tus Start
        Y.ARR.ID=''
    END   ;*Tus End
    IF E THEN
        PROCESS.GOAHEAD = 0
        E = ""
        RETURN
    END
    Y.ACT.ID = 'LENDING-NEW-ARRANGEMENT'
    FN.REDO.FC.CHARGES = 'F.REDO.FC.CHARGES'
    R.REDO.FC.CHARGES = ''

    FN.RCA.R.NEW = 'F.RCA.R.NEW'
    F.RCA.R.NEW = ''

    FN.AA.PRD.DES.PAYMENT.RULES = 'F.AA.PRD.DES.PAYMENT.RULES'
    F.AA.PRD.DES.PAYMENT.RULES = ''

    FN.REDO.FC.PAYSCH = 'F.REDO.FC.PAYSCH'
    F.REDO.FC.PAYSCH = ''
    CALL OPF(FN.REDO.FC.PAYSCH,F.REDO.FC.PAYSCH)

    YID.ARR = AA$ARR.ID
    Y.CHARG.DISC = ""
    YERR = ""
    Y.AMOUNT = 0
    Y.CURRENCY = c_aalocArrCurrency
    IF NOT(Y.CURRENCY) THEN
        Y.CURRENCY = "DOP"
    END
    R.AA.PRD.DES.PAYMENT.RULES = ''
    YERR = ''
    PROCESS.GOAHEAD = 1
    R.CHARGES = ''
    R.DATA = ''
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.RCA.R.NEW, F.RCA.R.NEW)

    CALL OPF(FN.AA.PRD.DES.PAYMENT.RULES, F.AA.PRD.DES.PAYMENT.RULES)

    CALL OPF(FN.REDO.FC.CHARGES, F.REDO.FC.CHARGES)

RETURN
*------------
END
