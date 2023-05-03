* @ValidationCode : MjotMjA0NTM5OTQzMjpDcDEyNTI6MTY4MTgxNTExMzk1NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:21:53
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
SUBROUTINE REDO.V.TEMP.INTERNAL.REFERENCE

*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Pradeep S
* Program Name  : REDO.V.INP.INTERNAL.REFERENCE
*-------------------------------------------------------------------------
* Description: This routine is input routine to default
*              DEBIT.THIER.REFERENCE/CREDIT.THEIR.REFERENCE for REDO.FT.TT.TRANSACTION
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
* DATE                   Name          ODR / HD REF              DESCRIPTION
* 09-06-2017        Edwin Charles D         R15 Upgrade       Initial Creation
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.FT.TT.TRANSACTION

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

PROCESS:
*********

    BEGIN CASE

        CASE APPLICATION EQ "REDO.FT.TT.TRANSACTION"
            IF R.NEW(FT.TN.DEBIT.ACCT.NO) THEN
                Y.ACCT.ID = R.NEW(FT.TN.DEBIT.ACCT.NO)
                GOSUB READ.ACCT
                IF Y.AA.FLAG THEN
                    R.NEW(FT.TN.DEBIT.THEIR.REF) = Y.ACCT.ID
                    RETURN
                END
            END

            IF R.NEW(FT.TN.DEBIT.ACCT.NO) MATCHES "3A..." THEN
                Y.ACCT.ID = R.NEW(FT.TN.CREDIT.ACCT.NO)
                GOSUB READ.ACCT
                IF Y.AA.FLAG THEN
                    R.NEW(FT.TN.CREDIT.THEIR.REF) = Y.ACCT.ID
                    RETURN
                END
            END

    END CASE

RETURN

READ.ACCT:
***********

    R.ACC = ''
    Y.AA.ID = ''
    CALL F.READ(FN.ACCT,Y.ACCT.ID,R.ACC,F.ACCT,ERR.ACC)
    IF R.ACC AND R.ACC<AC.ARRANGEMENT.ID> MATCHES "AA..." THEN
        Y.AA.FLAG = @TRUE
        Y.AA.ID = R.ACC<AC.ARRANGEMENT.ID>
    END
RETURN


INIT:
******

    Y.AA.FLAG = @FALSE
    Y.ACCT.ID = ''

RETURN

OPEN.FILES:
************

    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    CALL OPF(FN.ACCT,F.ACCT)

RETURN

END
