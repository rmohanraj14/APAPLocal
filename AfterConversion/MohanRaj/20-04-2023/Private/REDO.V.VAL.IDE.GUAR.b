* @ValidationCode : MjotOTQ5Njg5OTE5OkNwMTI1MjoxNjgxOTcwNjAyMzg1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:33:22
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
SUBROUTINE REDO.V.VAL.IDE.GUAR
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
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
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
    CALL F.READ(FN.CUSTOMER,LOAN.DEBTORS.ID,R.CUSTOMER,F.CUSTOMER,ERR.MSJ)
    IF R.CUSTOMER THEN
        VAL.CUS.NAME.LOAN = R.CUSTOMER<EB.CUS.NAME.1>
        VAL.LEGAL.ID.LOAN = R.CUSTOMER<EB.CUS.LEGAL.ID>
        R.NEW(COLL.LOCAL.REF)<1,WPOSDEBNAME>=VAL.CUS.NAME.LOAN
        R.NEW(COLL.LOCAL.REF)<1,WPOSDEBLEGNAME>=VAL.LEGAL.ID.LOAN

    END


    CALL F.READ(FN.CUSTOMER,GUAR.CUS.ID,R.CUSTOMER,F.CUSTOMER,ERR.MSJ)

    IF R.CUSTOMER THEN
        VAL.CUS.NAME = R.CUSTOMER<EB.CUS.NAME.1>
        VAL.LEGAL.ID = R.CUSTOMER<EB.CUS.LEGAL.ID>
        R.NEW(COLL.LOCAL.REF)<1,WPOSNAME>= VAL.CUS.NAME
        R.NEW(COLL.LOCAL.REF)<1,WPOSLEGID>=VAL.LEGAL.ID
        IF GUAR.CUS.ID EQ LOAN.DEBTORS.ID THEN
            AF = COLL.LOCAL.REF
            AV = ZPOS<1,WPOSLI>
            ETEXT = 'ST-REDO.COLLA.GARA.EQ.DEU'
            CALL STORE.END.ERROR
        END


    END


RETURN
*
* =========
OPEN.FILES:
* =========
*

RETURN
*
* =========
INITIALISE:
* =========
*

    LOOP.CNT = 1
    MAX.LOOPS = 1
    PROCESS.GOAHEAD = 1

    WCAMPO ="L.COL.GUAR.ID"
    WCAMPO<2> = "L.COL.GUR.LEGID"
    WCAMPO<3> ="L.COL.GUAR.NAME"
    WCAMPO<4> ="L.COL.DEBTOR.ID"
    WCAMPO<5> ="L.COL.DEBTOR.NA"
    WCAMPO<6> ="L.COL.DBR.LEGID"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,ZPOS)
    WPOSLI=ZPOS<1,1>
    WPOSLEGID=ZPOS<1,2>
    WPOSNAME=ZPOS<1,3>
    WPOSLDID=ZPOS<1,4>
    WPOSDEBNAME=ZPOS<1,5>
    WPOSDEBLEGNAME=ZPOS<1,6>

    GUAR.CUS.ID = R.NEW(COLL.LOCAL.REF)<1,WPOSLI>
    LOAN.DEBTORS.ID = R.NEW(COLL.LOCAL.REF)<1,WPOSLDID>



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
