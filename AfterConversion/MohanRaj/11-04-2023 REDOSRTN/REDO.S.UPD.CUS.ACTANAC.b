* @ValidationCode : Mjo4NjYzNzQ5Nzg6Q3AxMjUyOjE2ODEyMTUzNDQ3Njc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:45:44
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
SUBROUTINE REDO.S.UPD.CUS.ACTANAC(Y.CUS.ID)

* Correction routine to update the file F.CUSTOMER.L.CU.ACTANAC
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_REDO.S.UPD.CUS.ACTANAC.COMMON

    GOSUB PROCESS

RETURN

**********
PROCESS:
*********
** Section to get the Actanac value
    R.CUS = ''
    CALL F.READ(FN.CUS,Y.CUS.ID,R.CUS,F.CUS,CUS.ERR)
    IF R.CUS THEN
        Y.ACT.ID = R.CUS<EB.CUS.LOCAL.REF,ACT.LRF.POS>
        GOSUB UPD.FILE
    END

RETURN

**********
UPD.FILE:
**********
* Section to update the file F.CUSTOMER.L.CU.ACTANAC

    R.ACT.ID = ''
    CALL F.READ(FN.CUS.ACTANAC,Y.ACT.ID,R.ACT.ID,F.CUS.ACTANAC,ACT.ERR)
    IF ACT.ERR THEN
        R.VALUE = R.CUS<EB.CUS.COMPANY.BOOK>:"*":Y.CUS.ID
        CALL F.WRITE(FN.CUS.ACTANAC,Y.ACT.ID,R.VALUE)
    END

RETURN

END
