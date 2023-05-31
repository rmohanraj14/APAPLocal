* @ValidationCode : MjotMTU5MjgwOTA1ODpDcDEyNTI6MTY4NTUyODI5OTQ0OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:48:19
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
SUBROUTINE REDO.AA.INTEREST.CHARGE.AUTHORISE
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used to define fields that will update NCF table based on Interest paid.
*------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference                                    Description
* 14-dec-2011          Prabhu.N     PACS00167681 and PACS00167681                 Initial Creation
* Date                 who                   Reference
* 29-03-2023          CONVERSTION TOOL   R22 AUTO CONVERSTION VM TO @VM AND FM TO @FM
* 29-03-2023          ANIL KUMAR B       R22 MANUAL CONVERSTION                 CALL method format changed
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.AA.INTEREST.CHARGE
    $INSERT I_F.REDO.NCF.ISSUED
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $INSERT I_F.REDO.L.NCF.STOCK
    $USING APAP.REDOCHNLS
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
PROCESS:


    Y.DATE=R.NEW(REDO.IC.DATE)
    Y.ACCOUNT.ID=ID.NEW

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACC,F.ACCOUNT,ERR)
    Y.CURRENCY=R.ACC<AC.CURRENCY>

    FN.REDO.L.NCF.STOCK='F.REDO.L.NCF.STOCK'

    CALL CACHE.READ(FN.REDO.L.NCF.STOCK,'SYSTEM',R.REDO.L.NCF.STOCK,ERR)

    FN.REDO.NCF.ISSUED='F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED =''
    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)

    Y.TOT.CHG.LIST=R.REDO.L.NCF.STOCK<ST.AA.IC.TYPE>
    CHANGE @VM TO @FM IN Y.TOT.CHG.LIST
    Y.CHG.CNT=1
    Y.CHG.CNT.TOT=DCOUNT(Y.TOT.CHG.LIST,@FM)
    LOOP
    WHILE Y.CHG.CNT LE Y.CHG.CNT.TOT
        Y.BALANCE.TYPE=Y.TOT.CHG.LIST<Y.CHG.CNT>
        CALL AA.GET.ECB.BALANCE.AMOUNT(Y.ACCOUNT.ID, Y.BALANCE.TYPE, Y.DATE, Y.BALANCE.AMOUNT,Y.RET.ERROR)
        Y.TOT.CHARGE.AMT+=Y.BALANCE.AMOUNT
        Y.CHG.CNT += 1 ;*29-03-2023 R22 Auto Conversion
    REPEAT

    Y.FT.CHARGE.AMT =Y.TOT.CHARGE.AMT-Y.TOTAL.CHG.INT.PREV
    Y.FT.CHARGE.AMT =Y.CURRENCY :' ':Y.FT.CHARGE.AMT

    CALL F.READ(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED,ERR)
    CALL F.READ(FN.REDO.NCF.UNMAPPED,Y.NCF.ID,R.REDO.NCF.UNMAPPED,F.REDO.NCF.UNMAPPED,ERR)

    Y.NCF.LIST=R.REDO.NCF.ISSUED<ST.IS.NCF>
    Y.NCF.LIST.CNT=DCOUNT(Y.NCF.LIST,@VM)
    Y.TAX.AMOUNT=R.REDO.NCF.ISSUED<ST.IS.TAX.AMOUNT>

    IF Y.TAX.AMOUNT AND Y.NCF.LIST.CNT EQ 1 AND Y.FT.CHARGE.AMT THEN
        APAP.REDOCHNLS.redoAssignNcf(Y.NCF.ID,Y.FT.CHARGE.AMT);* R22 Manual conversion
        RETURN
    END

    IF NOT(Y.TAX.AMOUNT) AND NOT(Y.NCF.LIST.CNT) AND Y.FT.CHARGE.AMT AND NOT(R.REDO.NCF.UNMAPPED) THEN
        APAP.REDOCHNLS.redoAssignNcf(Y.NCF.ID,Y.FT.CHARGE.AMT);* R22 Manual conversion
        RETURN
    END

    IF NOT(R.REDO.NCF.ISSUED) THEN
        GOSUB UNMAP.PROCESS
    END
    ELSE
        IF R.REDO.NCF.ISSUED<ST.IS.CHARGE.AMOUNT> ELSE
            R.REDO.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>=Y.FT.CHARGE.AMT
            CALL F.WRITE(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.REDO.NCF.ISSUED)
        END
    END
RETURN
INITIALISE:

    FN.REDO.NCF.ISSUED ='F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED=''
    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)

    FN.REDO.NCF.UNMAPPED='F.REDO.L.NCF.UNMAPPED'
    F.REDO.NCF.UNMAPPED=''
    CALL OPF(FN.REDO.NCF.UNMAPPED,F.REDO.NCF.UNMAPPED)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.NCF.OLD.DATE=R.OLD(REDO.IC.DATE)
    Y.NCF.DATE=R.NEW(REDO.IC.DATE)
    Y.NCF.ID  =R.NEW(REDO.IC.NCF.ID)
    Y.TOTAL.CHG.INT.PREV =R.NEW(REDO.IC.TOTAL.INT.BEF)

RETURN
UNMAP.PROCESS:
    IF R.REDO.NCF.UNMAPPED THEN
        IF R.REDO.NCF.UNMAPPED<ST.UN.CHARGE.AMOUNT> ELSE
            R.REDO.NCF.UNMAPPED<ST.UN.CHARGE.AMOUNT>=Y.FT.CHARGE.AMT
            CALL F.WRITE(FN.REDO.NCF.UNMAPPED,Y.NCF.ID,R.REDO.NCF.UNMAPPED)
        END
    END
RETURN
END
