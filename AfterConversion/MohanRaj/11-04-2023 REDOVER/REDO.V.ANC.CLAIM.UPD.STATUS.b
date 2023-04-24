* @ValidationCode : MjoyNTc2ODMzMDQ6Q3AxMjUyOjE2ODEyMTYzMjEwNDk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:02:01
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
SUBROUTINE REDO.V.ANC.CLAIM.UPD.STATUS
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Pradeep S
* Program Name  : REDO.V.ANC.CLAIM.UPD.STATUS
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Description   : This ANC routine attached in notify version for Request to update the STATUS field
* In parameter  : None
* out parameter : None
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 21-May-2011      Pradeep S          PACS00071941      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.CLAIMS

    GOSUB PROCESS

RETURN
*-------
PROCESS:
*-------
    Y.CURR.STATUS = R.NEW(ISS.CL.STATUS)
    Y.CURR.CLOSE.STATUS = R.NEW(ISS.CL.CLOSING.STATUS)

    BEGIN CASE

        CASE Y.CURR.CLOSE.STATUS EQ 'ACCEPTED'
            R.NEW(ISS.CL.STATUS) = 'RESOLUCION NOTIFICADA'

        CASE Y.CURR.CLOSE.STATUS EQ 'REJECTED'
            R.NEW(ISS.CL.STATUS) = 'RECHAZADA NOTIFICADA'

    END CASE

RETURN
END
