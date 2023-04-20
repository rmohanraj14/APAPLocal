* @ValidationCode : MjotOTI0MzM0NDA1OkNwMTI1MjoxNjgxOTc1NTA1NTE5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:55:05
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
SUBROUTINE REDO.V.VAL.TYP.GUAR.SOLI
*
* ====================================================================================
*
*    - Gets the information related to the AA specified in input parameter
*
*    - Generates BULK OFS MESSAGES to apply payments to corresponding AA
*
* ====================================================================================
*
* Subroutine Type :
* Attached to     :
* Attached as     :
* Primary Purpose :
*
*
* Incoming:
* ---------
*
*
*
* Outgoing:

* ---------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for :
* Development by  :
* Date            :
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,= TO EQ
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COLLATERAL
*
*************************************************************************
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

*
RETURN
*
* ======
PROCESS:
* ======

    CALL F.READ(FN.CUSTOMER,GUAR.CUS.ID,R.CUSTOMER,F.CUSTOMER,ERR.MSJ)
    IF R.CUSTOMER THEN

        VAL.CUS.NA= R.CUSTOMER<EB.CUS.NATIONALITY>
        VAL.CUS.TYPE= R.CUSTOMER<EB.CUS.LOCAL.REF,WPOSLCU>
        VAL.CUS.LEGA.ID= R.CUSTOMER<EB.CUS.LEGAL.ID>


        BEGIN CASE

            CASE VAL.CUS.TYPE  EQ "PF" AND VAL.CUS.NA EQ "DO" AND VAL.CUS.LEGA.ID EQ ""
                R.NEW(COLL.LOCAL.REF)<1,WPOSGUARTYPE>= "L.COL.GUAR.TYPE*P3"
            CASE VAL.CUS.TYPE  EQ "PF" AND VAL.CUS.NA EQ "DO"
                R.NEW(COLL.LOCAL.REF)<1,WPOSGUARTYPE>= "L.COL.GUAR.TYPE*P1"
            CASE VAL.CUS.TYPE  EQ "PF" AND VAL.CUS.NA NE "DO"
                R.NEW(COLL.LOCAL.REF)<1,WPOSGUARTYPE>= "L.COL.GUAR.TYPE*P2"
            CASE VAL.CUS.TYPE  EQ "PJ"
                R.NEW(COLL.LOCAL.REF)<1,WPOSGUARTYPE>= "L.COL.GUAR.TYPE*E3"




        END CASE


    END
RETURN
*
* =========
OPEN.FILES:
* =========
*
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

RETURN

*
* =========
INITIALISE:
* =========
*
    LOOP.CNT        = 1
    MAX.LOOPS       = 1
    PROCESS.GOAHEAD = 1
    ZPOS = 0

*Lee Varias Aplicaciones
    LOC.REF.APPL ='CUSTOMER':@FM:'COLLATERAL'
    LOC.REF.FIELDS='L.CU.TIPO.CL':@FM:'L.COL.GUAR.ID':@VM:'L.COL.GUAR.TYPE'
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,ZPOS)
    WPOSLCU=ZPOS<1,1>
    WPOSLI=ZPOS<2,1>
    WPOSGUARTYPE=ZPOS<2,2>
    GUAR.CUS.ID = R.NEW(COLL.LOCAL.REF)<1,WPOSLI>

    FN.CUSTOMER= "F.CUSTOMER"
    F.CUSTOMER=""
RETURN

* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1

        END CASE

        LOOP.CNT +=1
    REPEAT
*
RETURN
*

END
