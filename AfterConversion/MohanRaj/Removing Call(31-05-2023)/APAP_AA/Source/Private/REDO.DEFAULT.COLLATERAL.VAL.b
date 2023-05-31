* @ValidationCode : MjoxMjk1ODEwMTA4OkNwMTI1MjoxNjgwMTg0NjcyMjIwOklUU1M6LTE6LTE6NDY3OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 467
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.DEFAULT.COLLATERAL.VAL
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Temenos Application Management
*Program   Name    :REDO.DEFAULT.COLLATERAL.VAL
*Reference         :ODR-2010-03-0159
*Date              :08 AUG 2011
*---------------------------------------------------------------------------------
*
*DESCRIPTION       :This program is used to update the local reference field
*                   L.COL.VAL
*
*LINKED WITH       :Attached to ACTIVITY.API, for the activity LENDING-SETTLE-PAYMNET.RULES,LENDING-APPLYPAYMNET-PAYMNET.RULES and LENDING-CREDIT-
*                   triggered during PAYMENT update Action
*
*--------------------------------------------------------------------------------------------------------
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION           NO CHANGES

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.REDO.AA.PAYMENT.DETAILS
    $INSERT I_F.AA.PAYMENT.SCHEDULE


    VAR.STATUS = c_aalocActivityStatus
    IF VAR.STATUS EQ 'UNAUTH' THEN
        GOSUB OPEN.FILES
        GOSUB WRITE.VALUE

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

    FN.REDO.REMOVE.ACTUAL.AMT = 'F.REDO.REMOVE.ACTUAL.AMT'
    F.REDO.REMOVE.ACTUAL.AMT  = ''
    CALL OPF(FN.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT)



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
    GOSUB CHECK.ACTUAL.AMOUNT
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
            R.NEW(AA.AMT.LOCAL.REF)<1,L.AA.COL.VAL.POS,Y.CNT> = Y.EXE.VAL
        END
        Y.CNT += 1 ;* R22 Auto Conversion
    REPEAT
RETURN
*-----------------------------------------------------------------------------------------------------------------------------
CHECK.ACTUAL.AMOUNT:
*-----------------------------------------------------------------------------------------------------------------------------
*Added for PACS00578530
    CALL F.READ(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT,CNCT.ERR)
    Y.PAYMENT.TYPE     = R.NEW(AA.PS.PAYMENT.TYPE)
    Y.PAYMENT.TYPE.CNT = DCOUNT(Y.PAYMENT.TYPE,@VM)
    Y.VAR1 = 1

    IF  R.REDO.REMOVE.ACTUAL.AMT NE "" AND R.REDO.REMOVE.ACTUAL.AMT<1> NE "YES" THEN

        LOOP
        WHILE Y.VAR1 LE Y.PAYMENT.TYPE.CNT
            Y.PROPERTY = R.NEW(AA.PS.PROPERTY)<1,Y.VAR1>
            LOCATE 'ACCOUNT' IN Y.PROPERTY<1,1,1> SETTING POS1 THEN
                LOCATE 'PRINCIPALINT' IN Y.PROPERTY<1,1,1> SETTING POS2 THEN
                    IF R.NEW(AA.PS.ACTUAL.AMT)<1,Y.VAR1> THEN
                        R.NEW(AA.PS.ACTUAL.AMT)<1,Y.VAR1> = ""
                    END
                END
            END

            Y.VAR1 += 1 ;* R22 Auto Conversion
        REPEAT
    END
RETURN
*-----------------------------------------------------------------------------------------------------------------------------
GET.COLL.VAL:
*-----------------------------------------------------------------------------------------------------------------
    CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,Y.COL.ERR)
    IF R.COLLATERAL THEN
        Y.EXE.VAL = R.COLLATERAL<COLL.EXECUTION.VALUE>
    END
RETURN
END
