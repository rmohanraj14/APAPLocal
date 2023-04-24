* @ValidationCode : MjoxMzYwNzI2ODMwOkNwMTI1MjoxNjgxMjE1MjgxOTMzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:44:41
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
SUBROUTINE REDO.S.REJECT.DESC(DESC)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.REJECT.DESC
*Reference         :ODR2010090251
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the Reject Reason decription
*
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.OUTWARD.RETURN
    $INSERT I_F.REDO.REJECT.REASON

    GOSUB OPEN.FILE
    GOSUB PROCESS
RETURN

OPEN.FILE:
*Opening Files

    FN.REDO.OUTWARD.RETURN = 'F.REDO.OUTWARD.RETURN'
    F.REDO.OUTWARD.RETURN = ''
    CALL OPF(FN.REDO.OUTWARD.RETURN,F.REDO.OUTWARD.RETURN)

    FN.REDO.REJECT.REASON = 'F.REDO.REJECT.REASON'
    F.REDO.REJECT.REASON = ''
    CALL OPF(FN.REDO.REJECT.REASON,F.REDO.REJECT.REASON)

RETURN
PROCESS:
*Getting the Description of the Reject Code

    VAR.PAYMENT.DETAILS = R.NEW(FT.PAYMENT.DETAILS)
    CALL F.READ(FN.REDO.OUTWARD.RETURN,VAR.PAYMENT.DETAILS,R.REDO.OUTWARD.RETURN,F.REDO.OUTWARD.RETURN,OUTWARD.ERR)
    VAR.REJECT.ID = R.REDO.OUTWARD.RETURN<CLEAR.RETURN.REJECT.REASON>
    CALL F.READ(FN.REDO.REJECT.REASON,VAR.REJECT.ID,R.REDO.REJECT.REASON,F.REDO.REJECT.REASON,REASON.ERR)
    IF R.REDO.REJECT.REASON<REDO.REJ.DESC,LNGG> THEN
        DESC = R.REDO.REJECT.REASON<REDO.REJ.DESC,LNGG>
    END ELSE
        DESC = R.REDO.REJECT.REASON<REDO.REJ.DESC,1>
    END
RETURN
END
