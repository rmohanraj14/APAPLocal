* @ValidationCode : MjotMTkxOTI0NDA3MDpDcDEyNTI6MTY4MDE5MDE1OTgxODpJVFNTOi0xOi0xOjE2MToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 161
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE APAP.AA
SUBROUTINE REDO.S.FC.AA.NOMBRE.PRINCIPAL.GR(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.FC.ENQPARMS
* Attached as     : ROUTINE
* Primary Purpose : Get RAZON.SOCIAL that match with the group of risk
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
* AA.ARR - data returned to the routine
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Bryan Torres- TAM Latin America
* Date            : 9/26/2001
*
* Date             Who                   Reference      Description
* 30.03.2023       Conversion Tool       R22            Auto Conversion     - VM TO @VM, FM TO @FM
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*-----------------------------------------------------------------------------------



    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
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




    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,Y.ERR.CUSTOMER)
    IF Y.ERR.CUSTOMER THEN
        AA.ARR = Y.ERR.CUSTOMER
        RETURN
    END ELSE
        Y.RISK = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSRISK>
    END

    SELECT.STATEMENT = 'SELECT ':FN.CUSTOMER :' WITH L.CU.GRP.RIESGO ':'EQ ':Y.RISK
    LOCK.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    Y.ID.AA.PRD = ''
    CALL EB.READLIST(SELECT.STATEMENT,LOCK.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
    LOOP
        REMOVE Y.ID.CUS FROM LOCK.LIST SETTING POS
    WHILE Y.ID.CUS:POS
        CALL CACHE.READ(FN.CUSTOMER, Y.ID.CUS, R.CUS, Y.ERR.CUS)
        IF Y.ERR.CUS THEN
            AA.ARR = Y.ERR.CUS
            RETURN
        END ELSE
            Y.RELATION.CODE = R.CUS<EB.CUS.RELATION.CODE>
            Y.CUS.TIPO = R.CUS<EB.CUS.LOCAL.REF,WPOLCUTIPO>
            Y.CUS.NAME1 = R.CUS<EB.CUS.NAME.1>
            Y.CUS.NAME2 = R.CUS<EB.CUS.NAME.2>
            Y.CUS.FAMILY.NAME = R.CUS<EB.CUS.FAMILY.NAME>

            GOSUB ADD.ARR
        END



    REPEAT
RETURN
*-----------------------------------------------------------------------------------
ADD.ARR:
*======

    LOCATE "100" IN Y.RELATION.CODE<1,1> SETTING YPOS.RELATION THEN
        GOSUB RAZON.SOCIAL
    END ELSE
        LOCATE "102" IN Y.RELATION.CODE<1,1> SETTING YPOS.RELATION THEN
            GOSUB RAZON.SOCIAL
        END
    END



RETURN
*-----------------------------------------------------------------------------------
RAZON.SOCIAL:
*======

    IF Y.CUS.TIPO EQ "PERSONA FISICA" THEN


        AA.ARR<-1>=Y.CUS.NAME1:" ":Y.CUS.NAME2:" ":Y.CUS.FAMILY.NAME
    END
    IF Y.CUS.TIPO EQ "PERSONA JURIDICA " THEN
        AA.ARR<-1>=Y.CUS.NAME1:Y.CUS.NAME2
    END
    AA.ARR = CHANGE(AA.ARR,@FM," ")       ;** R22 Auto conversion - FM TO @FM


RETURN

*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.CUSTOMER="F.CUSTOMER"
    F.CUSTOMER=""
    Y.CUS.ID = AA.ID
    WCAMPOU = "L.CU.GRP.RIESGO"
    WCAMPOU<2> = "L.CU.TIPO.CL"
    WCAMPOU = CHANGE(WCAMPOU,@FM,@VM)    ;** R22 Auto conversion - FM TO @FM, VM TO @VM
    YPOSU=''
    CALL MULTI.GET.LOC.REF("CUSTOMER",WCAMPOU,YPOSU)
    WPOSRISK  = YPOSU<1,1>
    WPOLCUTIPO  = YPOSU<1,2>
    AA.ARR=""
    Y.RISK=""


RETURN
*------------------------
OPEN.FILES:
*=========
    CALL OPF (FN.CUSTOMER,F.CUSTOMER)

RETURN
*------------
END
