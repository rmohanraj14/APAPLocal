* @ValidationCode : MjotMTI1MDEzNDcxMTpDcDEyNTI6MTY4MDE5MDE2MDQyNTpJVFNTOi0xOi0xOjc2OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 76
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA

SUBROUTINE REDO.S.FC.AA.RAZON.SOCIAL.GR(AA.ID, AA.ARR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.FC.ENQPARMS
* Attached as     : ROUTINE
* Primary Purpose :
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
* Date            : 9/27/2001
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


        Y.CUS.TIPO = R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSUGRPRISK>
        Y.CUS.NAME1 = R.CUSTOMER<EB.CUS.NAME.1>
        Y.CUS.NAME2 = R.CUSTOMER<EB.CUS.NAME.2>
        Y.CUS.FAMILY.NAME = R.CUSTOMER<EB.CUS.FAMILY.NAME>

        IF Y.CUS.TIPO EQ "PERSONA FISICA" THEN
            AA.ARR=Y.CUS.NAME1:" ":Y.CUS.NAME2:" ":Y.CUS.FAMILY.NAME
        END
        IF Y.CUS.TIPO EQ "PERSONA JURIDICA" THEN
            AA.ARR=Y.CUS.NAME1:Y.CUS.NAME2
        END


        RETURN
*------------------------
INITIALISE:
*=========
        PROCESS.GOAHEAD = 1

        FN.CUSTOMER="F.CUSTOMER"
        F.CUSTOMER=""
        Y.CUS.ID = AA.ID
        WCAMPOU = "L.CU.TIPO.CL"
        WCAMPOU = CHANGE(WCAMPOU,@FM,@VM)   ;** R22 Auto conversion - VM TO @VM, FM TO @FM
        YPOSU=''
        CALL MULTI.GET.LOC.REF("CUSTOMER",WCAMPOU,YPOSU)
        WPOSUGRPRISK  = YPOSU<1,1>



        RETURN

*------------------------
OPEN.FILES:
*=========

        RETURN
*------------
    END
