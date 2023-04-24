* @ValidationCode : MjotMTM3NTQ3MDMzOTpDcDEyNTI6MTY4MTIxNjAyMjU2MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:57:02
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
SUBROUTINE REDO.V.ANC.AZ.REINV.FREQ

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AZ.ACCOUNT

*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date            Who                 Reference            Description
* 17-Apr-2010     Sudharsanan S       PACS00192055         INITIAL VERSION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     > TO GT, = TO EQ
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------

    GOSUB PROCESS

RETURN

*********
PROCESS:
*********



    Y.DATE = TODAY
    Y.DATE.BK = Y.DATE

    IF Y.DATE[5,2] EQ '01' THEN ;*R22 Auto code conversion
        GOSUB CHECK.JAN.MON
    END
    ELSE
        IF Y.DATE[5,2] EQ '02'  THEN ;*R22 Auto code conversion
            GOSUB CHECK.FEB.MON
        END
        ELSE
            Y.DAYS = "+31C"
            CALL CDT('',Y.DATE,Y.DAYS)
        END
    END


*    CALL AWD('',Y.DATE,DATE.TYPE)

*    IF DATE.TYPE EQ 'H' THEN
*        Y.DAYS = "-1W"
*        CALL CDT('',Y.DATE,Y.DAYS)
*    END

    R.NEW(AZ.FREQUENCY) = Y.DATE:"M01":Y.DATE.BK[7,2]

    R.NEW(AZ.VALUE.DATE) = TODAY

RETURN

CHECK.JAN.MON:

    IF Y.DATE[7,2] GE "29" THEN
        IF MOD(Y.DATE[1,4],4) GT 0 THEN ;*R22 Auto code conversion
            Y.DATE = Y.DATE[1,4]:'0228'
        END ELSE
            Y.DATE = Y.DATE[1,4]:'0229'
        END
    END
    ELSE
        Y.DAYS = "+31C"
        CALL CDT('',Y.DATE,Y.DAYS)
    END

RETURN

CHECK.FEB.MON:

    IF MOD(Y.DATE[1,4],4) GT 0 THEN ;*R22 Auto code conversion
        Y.DAYS = "+28C"
        CALL CDT('',Y.DATE,Y.DAYS)
    END ELSE
        Y.DAYS = '+29C'
        CALL CDT('',Y.DATE,Y.DAYS)
    END

RETURN


END
