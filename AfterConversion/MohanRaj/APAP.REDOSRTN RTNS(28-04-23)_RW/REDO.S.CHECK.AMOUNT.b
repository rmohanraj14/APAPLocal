* @ValidationCode : MjotMTIzNDkzMTpDcDEyNTI6MTY4MjY2MTc3ODQzNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 Apr 2023 11:32:58
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
$PACKAGE APAP.REDOSRTN
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.S.CHECK.AMOUNT(CHQ.AMT)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.CHECK.AMOUNT
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the Amount by checking Txn type

*LINKED WITH       :*Modification history
*Date                Who               Reference                  Description
*06-04-2023      conversion tool     R22 Auto code conversion     No changes
*06-04-2023      Mohanraj R          R22 Manual code conversion   No changes


* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.APAP.CLEAR.PARAM
    $INSERT I_F.T24.FUND.SERVICES


    Y.TXN.TYPE = R.NEW(TFS.TRANSACTION)
    Y.INIT.TXN = 1
    Y.TXN.COUNT = DCOUNT(Y.TXN.TYPE,@VM) ;*R22 Manual code conversion
    Y.TXN.AMT = 0
    CHQ.AMT = 0
    CASH.AMT = 0

    ARR.1 = 'CHQDEP'
    ARR.2 = 'FCHQDEP'
    Y.ENQ.ARR.LIST = ARR.1:@FM:ARR.2 ;*R22 Manual code conversion

    LOOP
        REMOVE Y.TXN.ID FROM Y.TXN.TYPE SETTING Y.TXN.POS
    WHILE Y.INIT.TXN LE Y.TXN.COUNT
        LOCATE Y.TXN.ID IN Y.ENQ.ARR.LIST SETTING Y.PARAM.POS THEN
            Y.TXN.AMT = R.NEW(TFS.AMOUNT)<1,Y.INIT.TXN>
            CHQ.AMT += Y.TXN.AMT
        END
        Y.INIT.TXN++
    REPEAT

RETURN
END
