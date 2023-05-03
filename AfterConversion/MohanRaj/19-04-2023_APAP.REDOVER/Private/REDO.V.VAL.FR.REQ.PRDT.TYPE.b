* @ValidationCode : MjotOTU5MDU3ODY2OkNwMTI1MjoxNjgxODkxMDQzOTc5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:27:23
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
SUBROUTINE REDO.V.VAL.FR.REQ.PRDT.TYPE
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.VAL.FR.REQ.PRDT.TYPE
*--------------------------------------------------------------------------------
* Description: This Validation routine is used to check on what product does the
* customer logs the request
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE         WHO         REFERENCE         DESCRIPTION
* 24-May-2011   Pradeep S   PACS00071066      INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.REDO.FRONT.REQUESTS

    IF MESSAGE EQ 'VAL' OR cTxn_CommitRequests EQ 1 THEN
        RETURN
    END

    GOSUB PRE.PROCESS
RETURN

PRE.PROCESS:
*************
    IF COMI THEN
        GOSUB PROCESS
    END ELSE
        R.NEW(FR.CM.CLAIM.TYPE) = ''
        R.NEW(FR.CM.DOC.NAME) = ''
        R.NEW(FR.CM.DOC.REV) = ''
        ETEXT = 'EB-MAND.INP'
        CALL STORE.END.ERROR
    END

RETURN

PROCESS:
*********

    Y.DOC.REQ = R.NEW(FR.CM.DOC.NAME)

*IF Y.DOC.REQ THEN
*    N(FR.CM.DOC.REV):= '.1'
*END ELSE
*    T(FR.CM.DOC.REV)<3> = 'NOINPUT'
*END

    BEGIN CASE

        CASE COMI EQ 'TARJETA.DE.CREDITO'
            T(FR.CM.ACCOUNT.ID)<3> = 'NOINPUT'
            N(FR.CM.CARD.NO) := '.1'
            R.NEW(FR.CM.ACCOUNT.ID) = ''
        CASE COMI EQ 'OTROS'
            R.NEW(FR.CM.ACCOUNT.ID) = ''
            R.NEW(FR.CM.CARD.NO) = ''
        CASE 1
            T(FR.CM.CARD.NO)<3> = 'NOINPUT'
            N(FR.CM.ACCOUNT.ID) := '.1'
            R.NEW(FR.CM.CARD.NO) = ''
    END CASE

RETURN

END
