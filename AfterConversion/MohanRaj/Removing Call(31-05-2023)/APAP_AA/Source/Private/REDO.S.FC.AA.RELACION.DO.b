* @ValidationCode : MjotMTE0NDQzMzQzNTpDcDEyNTI6MTY4MDE5MDE2MDUwNjpJVFNTOi0xOi0xOjE2NzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 167
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.RELACION.DO(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.FC.ENQPARMS
* Attached as     : ROUTINE
* Primary Purpose : Show Relation description of relation code of the registers that match Risk group and Relation code is betwen 300 and 499

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


*    $INCLUDE GLOBUS.BP I_COMMON        ;*/ TUS START
*    $INCLUDE GLOBUS.BP I_EQUATE
*    $INCLUDE GLOBUS.BP I_F.AA.ARRANGEMENT
*    $INCLUDE GLOBUS.BP I_F.CUSTOMER
*    $INCLUDE GLOBUS.BP I_F.RELATION

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.RELATION        ;*/ TUS END
    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======




    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,Y.ERR.CUSTOMER)
    IF Y.ERR.CUSTOMER THEN
        AA.ARR = Y.ERR.CUSTOMER
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

            GOSUB ADD.ARR
        END

    REPEAT
RETURN
*-----------------------------------------------------------------------------------
ADD.ARR:
*======

    Y.COUNT.CODE=DCOUNT(Y.RELATION.CODE,@VM)    ;** R22 Auto conversion - VM TO @VM,
    FOR Y.CODE = 1 TO Y.COUNT.CODE

        IF Y.RELATION.CODE<1,Y.CODE> GT 300 AND Y.RELATION.CODE<1,Y.CODE> LT 499 THEN
            CALL CACHE.READ(FN.RELATION, Y.RELATION.CODE<1,Y.CODE>, R.RELATION, Y.ERR.RELATION)
            IF Y.ERR.CUS THEN
                AA.ARR = Y.ERR.RELATION
                RETURN
            END ELSE
                Y.DESC.RELATION=R.RELATION<EB.REL.DESCRIPTION>

                AA.ARR<-1>=Y.RELATION.CODE<1,Y.CODE>:" ":Y.DESC.RELATION

            END

        END
    NEXT Y.CODE
    AA.ARR = CHANGE(AA.ARR,@FM," ")         ;** R22 Auto conversion - FM TO @FM


RETURN

*------------------------
INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.CUSTOMER="F.CUSTOMER"
    F.CUSTOMER=""
    Y.CUS.ID = AA.ID
    WCAMPOU = "L.CU.GRP.RIESGO"
    WCAMPOU = CHANGE(WCAMPOU,@FM,@VM) ;** R22 Auto conversion - VM TO @VM, FM TO @FM
    YPOSU=''
    CALL MULTI.GET.LOC.REF("CUSTOMER",WCAMPOU,YPOSU)
    WPOSRISK  = YPOSU<1,1>
    AA.ARR=""
    Y.RISK=""
    FN.RELATION="F.RELATION"
    F.RELATION=""



RETURN
*------------------------
OPEN.FILES:
*=========
    CALL OPF (FN.CUSTOMER,F.CUSTOMER)

RETURN
*------------
END
