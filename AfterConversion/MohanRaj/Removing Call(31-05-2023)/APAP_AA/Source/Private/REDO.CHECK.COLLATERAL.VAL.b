* @ValidationCode : MjoxMzgzODQ0MzI0OkNwMTI1MjoxNjgzNjk4NDI3MjM2OklUU1M6LTE6LTE6MzY5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:27
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 369
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.CHECK.COLLATERAL.VAL
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Temenos Application Management
*Program   Name    :REDO.CHECK.COLLATERAL.VAL
*Reference         :ODR-2010-03-0159
*Date              :21 JUL 2011
*---------------------------------------------------------------------------------
*
*DESCRIPTION       :This program is used to update the local CONCAT file
*                   REDO.AA.PAYMENT.DETAILS with the arrangement ID which is to be processed in online report
*
*LINKED WITH       :Attached to ACTIVITY.API, for the activity LENDING-SETTLE-PAYMNET.RULES,LENDING-APPLYPAYMNET-PAYMNET.RULES and LENDING-CREDIT-
*                   triggered during PAYMENT update Action
*
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE
* 29-MAR-2023   Conversion Tool             R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
*--------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.REDO.AA.PAYMENT.DETAILS


    VAR.STATUS = c_aalocActivityStatus
    IF VAR.STATUS EQ 'UNAUTH' THEN
        GOSUB OPEN.FILES
        GOSUB WRITE.VALUE
        GOSUB GET.PERIOD.BALANCES
    END
RETURN
*------------------------------------------------------------------------------------------------------------------
OPEN.FILES:
*----------

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.ALTERNATE.ACCOUNT = 'F.ALTERNATE.ACCOUNT'
    F.ALTERNATE.ACCOUNT = ''
    CALL OPF(FN.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT)

    APPL.ARRAY='AA.PRD.DES.TERM.AMOUNT'
    FLD.ARRAY='L.AA.COL':@VM:'L.AA.COL.VAL'
    FLD.POS=''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
    L.AA.COL.POS = FLD.POS<1,1>
    L.AA.COL.VAL.POS = FLD.POS<1,2>
RETURN
*-------------------------------------------------------------------------------------------------------------------
* Update the Arrangement ID in the CONCAT file REDO.AA.PAYMENT.DETAILS
*
WRITE.VALUE:
*-----------
    Y.COLL.OLD = ''
    Y.TOT.VAL = 0
    Y.COLL.OLD = R.OLD(AA.AMT.LOCAL.REF)<1,L.AA.COL.POS>
    Y.COLL.ID.LIST = R.NEW(AA.AMT.LOCAL.REF)<1,L.AA.COL.POS>
    Y.COLL.VAL.LIST = R.NEW(AA.AMT.LOCAL.REF)<1,L.AA.COL.VAL.POS>
    CHANGE @VM TO @FM IN Y.COLL.ID.LIST
    CHANGE @SM TO @FM IN Y.COLL.ID.LIST
    Y.CNT = 1
    Y.COUNT = DCOUNT(Y.COLL.ID.LIST,@FM)

    LOOP
    WHILE Y.CNT LE Y.COUNT
        Y.COLL.ID = ''

        Y.COLL.ID = Y.COLL.ID.LIST<Y.CNT>
        IF Y.COLL.ID THEN
            GOSUB GET.COLL.VAL
        END
        IF Y.COL.STATUS EQ 'LIQ' THEN
            AF = AA.AMT.LOCAL.REF
            AV = L.AA.COL.POS
            AS = Y.CNT
            ETEXT = 'EB-COLL.CLOSE':@FM:Y.COLL.ID
            CALL STORE.END.ERROR
            RETURN
        END
        Y.TOT.VAL += ABS(Y.EXE.VAL)
        Y.CNT += 1   ;*R22 Auto Conversion
    REPEAT
RETURN
*-----------------------------------------------------------------------------------------------------------------------------
GET.COLL.VAL:
*-----------------------------------------------------------------------------------------------------------------
    CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,Y.COL.ERR)
    IF R.COLLATERAL THEN
        Y.EXE.VAL = R.COLLATERAL<COLL.EXECUTION.VALUE>
        Y.COL.STATUS = R.COLLATERAL<COLL.STATUS>
    END
RETURN
*-------------------------------------------------------------------------------
GET.PERIOD.BALANCES:
*-------------------------------------------------------------------------------

    CURR.NO = DCOUNT(R.NEW(AA.AMT.CURR.NO),@VM)+1
    BALANCE.TO.CHECK = 'CURACCOUNT':@VM:'DUEACCOUNT':@VM:'DELACCOUNT':@VM:'DE1ACCOUNT':@VM:'GRCACCOUNT':@VM:'NABACCOUNT'
    Y.AA.ID = c_aalocArrId
    CALL F.READ(FN.ALTERNATE.ACCOUNT,Y.AA.ID,R.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT,ALT.ERR)
    Y.ACC.ID = R.ALTERNATE.ACCOUNT
    Y.AMT = 0

    LOOP
        REMOVE Y.BAL FROM BALANCE.TO.CHECK SETTING BAL.POS
    WHILE Y.BAL:BAL.POS
        REQUEST.TYPE<4>='ECB'
        CALL AA.GET.PERIOD.BALANCES (Y.ACC.ID, Y.BAL, REQUEST.TYPE, START.DATE, END.DATE, SYSTEM.DATE, BAL.DETAILS, ERR.MSG)
        Y.AMT += ABS(BAL.DETAILS<4>)
    REPEAT

    IF Y.COLL.OLD THEN
        IF Y.AMT GT Y.TOT.VAL THEN
            TEXT='COLL.AMT.LESS'
            CALL STORE.OVERRIDE(CURR.NO)
        END
    END
    IF Y.TOT.VAL AND Y.AMT GT Y.TOT.VAL THEN
        TEXT='COLL.AMT.LESS'
        CALL STORE.OVERRIDE(CURR.NO)
    END

RETURN

END
