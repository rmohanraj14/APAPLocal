* @ValidationCode : Mjo3NjU4NjA5MzE6Q3AxMjUyOjE2ODExMTUxODgxMzc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:56:28
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
SUBROUTINE REDO.S.FETCH.CHARGE(SYS.DATE)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.FETCH.SYS.DATE
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the date and Convert the date into
*                   dd mon yy (e.g. 01 JAN 09)
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.LATAM.CARD.ORDER

    GOSUB PROCESS
RETURN

PROCESS:

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT =''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.ACCOUNT = R.NEW(CARD.IS.ACCOUNT)
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.ACCOUNT,F.ACCOUNT,Y.ACCOUNT.ERR)
    Y.CURR = R.ACCOUNT<AC.CURRENCY>
    SYS.DATE = Y.CURR

RETURN
END
