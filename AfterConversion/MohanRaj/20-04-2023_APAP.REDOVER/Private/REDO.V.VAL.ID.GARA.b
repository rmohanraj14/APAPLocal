* @ValidationCode : MjotMTk5NDk0NjQ1MTpDcDEyNTI6MTY4MTk3MDUzODQxOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:32:18
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
SUBROUTINE REDO.V.VAL.ID.GARA

* ====================================================================================
*
*    - GET INFORMATION FOR CUSTOMER AND SET VALUES IN THE VERSION
*
*    - SET INFORMATION FOR CUSTOMER
*
* ====================================================================================

*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.ID.GARA
* Attached as     : ROUTINE
* Primary Purpose :
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
* Date            :
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

*GET THE ID FOR GUARANT
    GUAR.CUS.ID = COMI

*GET THE ID FROM CUSTOMER
    LOAN.DEBTORS.ID = R.NEW(COLL.LOCAL.REF)<1,WPOSLDID>

*GET INFORMATION OF CUSTOMER
    CALL F.READ(FN.CUSTOMER,GUAR.CUS.ID,R.CUSTOMER,F.CUSTOMER,ERR.MSJ)

    IF R.CUSTOMER THEN
        VAL.CUS.NAME = R.CUSTOMER<EB.CUS.NAME.1>
        VAL.LEGAL.ID = R.CUSTOMER<EB.CUS.LEGAL.ID>
        VAL.NACIONALIDAD  = R.CUSTOMER<EB.CUS.NATIONALITY>

        R.NEW(COLL.LOCAL.REF)<1,WPOSNAME>= VAL.CUS.NAME
        R.NEW(COLL.LOCAL.REF)<1,WPOSLEGID>=VAL.LEGAL.ID

*--SET THE ID AS TYPE ID CUSTOMER
        VAR.TIPO = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSTCUS>

**VERIFY THAT TYPEXIST IN THE CUSTOMER SELECTED
* IF VAR.TIPO EQ '' THEN
*AF = COLL.LOCAL.REF
*AV = ZPOS<1,7>
*ETEXT = 'ST-CUS.S.TIPO'
*CALL STORE.END.ERROR

* TEXT = "COLL.CUS.S.TIPO"
* M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),VM) + 1
* CALL STORE.OVERRIDE(M.CONT)

*END

        BEGIN CASE
            CASE VAR.TIPO EQ "PERSONA FISICA"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSCEDULA>

                IF VAL.NACIONALIDAD EQ 'DO' THEN
                    R.NEW(COLL.LOCAL.REF)<1,WPOSTYPE> = 'P1'
                END
                ELSE
                    R.NEW(COLL.LOCAL.REF)<1,WPOSTYPE> = 'P2'
                END

            CASE VAR.TIPO EQ "PERSONA JURIDICA"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSRUC>
                R.NEW(COLL.LOCAL.REF)<1,WPOSTYPE> = 'E1'
            CASE VAR.TIPO EQ "CLIENTE MENOR"
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSPARTIDA>
                R.NEW(COLL.LOCAL.REF)<1,WPOSTYPE> = 'P1'
            CASE VAR.TIPO EQ  ""
                VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSUNICO>
        END CASE

*Review information of id customer
        GOSUB VERIFICAR
*SET THE ID OF CUSTOMER
        R.NEW(COLL.LOCAL.REF)<1,WPOSLEGID> = VAL.LEGAL.ID.LOAN


        IF LEN(VAL.LEGAL.ID.LOAN) LE 0  THEN
            AF = COLL.LOCAL.REF
            AV = ZPOS<1,2>
            ETEXT = 'ST-ID.CLIENTE'
            CALL STORE.END.ERROR
        END

*--END ID

        IF GUAR.CUS.ID EQ LOAN.DEBTORS.ID THEN
            AF = COLL.LOCAL.REF
            AV = ZPOS<1,1>
            ETEXT = 'ST-REDO.COLLA.GARA.EQ.DEU'
            CALL STORE.END.ERROR
        END


    END


RETURN
*----------------------------------------------------------------------------

INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    WCAMPO ="L.COL.GUAR.ID"
    WCAMPO<2> = "L.COL.GUR.LEGID"
    WCAMPO<3> ="L.COL.GUAR.NAME"
    WCAMPO<4> ="L.COL.DEBTOR.ID"
    WCAMPO<5> ="L.COL.DEBTOR.NA"
    WCAMPO<6> ="L.COL.DBR.LEGID"
    WCAMPO<7> ="L.COL.GUAR.TYPE"
    WCAMPO<8> = "L.COL.SEC.HOLD"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,ZPOS)
    WPOSLI=ZPOS<1,1>
    WPOSLEGID=ZPOS<1,2>
    WPOSNAME=ZPOS<1,3>
    WPOSLDID=ZPOS<1,4>
    WPOSDEBNAME=ZPOS<1,5>
    WPOSDEBLEGNAME=ZPOS<1,6>
    WPOSTYPE=ZPOS<1,7>
    WPOSIDTITU=ZPOS<1,8>

*DEFINE INFORMATION FOR LOCAL FIELDS FOR CUSTOMER

    FN.CUSTOMER= "F.CUSTOMER"
    F.CUSTOMER=""

    WCAMPOC    = "L.CU.CIDENT"
    WCAMPOC<2> = "L.CU.NOUNICO"
    WCAMPOC<3> = "L.CU.ACTANAC"
    WCAMPOC<4> = "L.CU.TIPO.CL"
    WCAMPOC<5> = "L.CU.RNC"

    WCAMPOC = CHANGE(WCAMPOC,@FM,@VM)
    CALL MULTI.GET.LOC.REF("CUSTOMER",WCAMPOC,XPOS)
    WPOSCEDULA=XPOS<1,1>
    WPOSUNICO=XPOS<1,2>
    WPOSPARTIDA=XPOS<1,3>
    WPOSTCUS=XPOS<1,4>
    WPOSRUC=XPOS<1,5>

RETURN

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


*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
RETURN
*------------
END
