* @ValidationCode : MjotMTI3OTMxMjExNTpDcDEyNTI6MTY4MTgxNDk4MjA2Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:19:42
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.TEMP.CRD.AC

* Developed for : APAP
* Developed by : Edwin Charles D
* Date         : 2017/Jun/07
* Attached to : VERSION
*
*=======================================================================
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.FT.TT.TRANSACTION


    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.CR.AC = COMI
    CALL F.READ(FN.ACCOUNT,Y.CR.AC,R.ACCOUNT,F.ACCOUNT,AC.ERR)

    Y.CUR = R.ACCOUNT<AC.CURRENCY>
    R.NEW(FT.TN.CREDIT.CURRENCY) = Y.CUR

RETURN

END
