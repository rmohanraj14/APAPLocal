* @ValidationCode : MjotMjcwNzk4MjY2OkNwMTI1MjoxNjgxOTcwNDUxODA1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:30:51
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
SUBROUTINE REDO.V.VAL.ID.CLIE

* ====================================================================================
*
*    - GET INFORMATION FOR CUSTOMER AND SET VALUES IN THE VERSION
*
*    - SET INFORMATION FOR CUSTOMER
*
* ====================================================================================

*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.ID.CLIE
* Attached as     : ROUTINE
* Primary Purpose : Validate customer an guarant validations.
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
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            : 07/09/2012
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.CUSTOMER

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

*GET THE ID FOR CUSTORMER
    GUAR.CUS.ID = R.NEW(COLL.LOCAL.REF)<1,WPOSLI>

*GET THE ID FROM CUSTOMER
    LOAN.DEBTORS.ID = COMI


**** FOR VALIDATE INFORMATION OTHER COLLATERALS 06/09/2012***
    IF PGM.VERSION EQ ',REDO.INGRESO.OG' THEN
        IF LOAN.DEBTORS.ID EQ '' THEN
            LOAN.DEBTORS.ID = LOAN.DEBTORS.ID
            RETURN
        END
    END
**** END VALIDATE INFORMATION

* GET INFORMATION FOR CUSTOMER
    CALL F.READ(FN.CUSTOMER,LOAN.DEBTORS.ID,R.CUSTOMER,F.CUSTOMER,ERR.MSJ)

    IF LOAN.DEBTORS.ID NE Y.COLL.CUST THEN
        AF = COLL.LOCAL.REF
        AV = WPOSLDID
        ETEXT = 'EB-COL-NOT.LOAN.CUS'
        CALL STORE.END.ERROR
        RETURN
    END

    IF R.CUSTOMER THEN
        VAL.CUS.NAME.LOAN = R.CUSTOMER<EB.CUS.NAME.1>
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LEGAL.ID>
        R.NEW(COLL.LOCAL.REF)<1,WPOSDEBNAME>=VAL.CUS.NAME.LOAN
        R.NEW(COLL.LOCAL.REF)<1,WPOSDEBLEGNAME>=VAL.LEGAL.ID.LOAN


*--SET THE ID AS TYPE ID CUSTOMER
        VAR.TIPO = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSTCUS>


        BEGIN CASE
            CASE VAR.TIPO EQ "PERSONA FISICA"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSCEDULA>
            CASE VAR.TIPO EQ "PERSONA JURIDICA"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSRUC>
            CASE VAR.TIPO EQ "CLIENTE MENOR"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSPARTIDA>
            CASE VAR.TIPO EQ  ""
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSUNICO>

        END CASE
*--END ID

*VERIFY THE INBFORMATION OF ID

        GOSUB VERIFICAR

*SET THE ID OF CUSTOMER
        R.NEW(COLL.LOCAL.REF)<1,WPOSDEBLEGNAME> = VAL.LEGAL.ID.LOAN

        IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
            AF = COLL.LOCAL.REF
            AV = ZPOS<1,6>
            ETEXT = 'ST-ID.CLIENTE'
            CALL STORE.END.ERROR
        END
    END


*VERIFY INFORMATION CUSTOMER EN GURATOR

    IF GUAR.CUS.ID EQ LOAN.DEBTORS.ID THEN
        AF = COLL.LOCAL.REF
        AV = ZPOS<1,4>
        ETEXT = 'ST-REDO.COLLA.GARA.EQ.DEU'
        CALL STORE.END.ERROR
    END

RETURN
*----------------------------------------------------------------------------

VERIFICAR:
*=========
*IF THE USER HAVE NULL ID SERCH FIELD PER FIELD IF EXIST ANY FIELD
    IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSCEDULA>
    END

    IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSRUC>
    END

    IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSPARTIDA>
    END

    IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSUNICO>
    END

    IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LEGAL.ID>
    END
RETURN

INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
    ZPOS = 0
    XPOS = 0
    Y.APPLICATION = "COLLATERAL":@FM:"CUSTOMER"

    WCAMPO ="L.COL.GUAR.ID"
    WCAMPO<2> = "L.COL.GUR.LEGID"
    WCAMPO<3> ="L.COL.GUAR.NAME"
    WCAMPO<4> ="L.COL.DEBTOR.ID"
    WCAMPO<5> ="L.COL.DEBTOR.NA"
    WCAMPO<6> ="L.COL.DBR.LEGID"
    WCAMPO<7> ="L.COL.GUAR.TYPE"


    WCAMPOC    = "L.CU.CIDENT"
    WCAMPOC<2> = "L.CU.NOUNICO"
    WCAMPOC<3> = "L.CU.ACTANAC"
    WCAMPOC<4> = "L.CU.TIPO.CL"
    WCAMPOC<5> = "L.CU.RNC"

    WCAMPOC = CHANGE(WCAMPOC,@FM,@VM)
    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    WCAMPO = WCAMPO:@FM:WCAMPOC

    CALL MULTI.GET.LOC.REF(Y.APPLICATION,WCAMPO,ZPOS)

    WPOSLI=ZPOS<1,1>
    WPOSLEGID=ZPOS<1,2>
    WPOSNAME=ZPOS<1,3>
    WPOSLDID=ZPOS<1,4>
    WPOSDEBNAME=ZPOS<1,5>
    WPOSDEBLEGNAME=ZPOS<1,6>
    WPOSTYPE=ZPOS<1,7>

    WPOSCEDULA=ZPOS<2,1>
    WPOSUNICO=ZPOS<2,2>
    WPOSPARTIDA=ZPOS<2,3>
    WPOSTCUS=ZPOS<2,4>
    WPOSRUC=ZPOS<2,5>


*DEFINE INFORMATION FOR LOCAL FIELDS FOR CUSTOMER

    FN.CUSTOMER= "F.CUSTOMER"
    F.CUSTOMER=""
    Y.COLL.CUST = FIELD(ID.NEW,".",1,1)

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
RETURN
*------------
END
