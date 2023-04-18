* @ValidationCode : MjotMTQ3MDgyOTU4MzpDcDEyNTI6MTY4MTc5NzM0MDk4Mzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 11:25:40
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
SUBROUTINE REDO.V.INP.USR.LIM.ERROR
*-----------------------------------------------------------------------------
*COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*-------------
*DEVELOPED BY: Temenos Application Management
*-------------
*SUBROUTINE TYPE: INPUT routine
*------------
*DESCRIPTION:
*------------
* This is Input routine attached to the versions of REDO.APAP.USER.LIMITS
* The routine raises error based on certain conditions
*---------------------------------------------------------------------------
* Input / Output
*----------------
*
* Input / Output
* IN     : -na-
* OUT    : -na-
*
*------------------------------------------------------------------------------------------------
* Revision History
* Date           Who                Reference              Description
* 29-DEC-2010   A.SabariKumar     ODR-2010-07-0075       Initial Creation
* 06-MAY-2011   Pradeep S         PACS00037714           For FX DOP amount should not be allowed
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.APAP.USER.LIMITS


    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*---------------------------------------------------------------------------
INITIALISE:
*------------
*Initialise/Open necessary varibles/files

    Y.USER = ''
    R.USR.LIM = ''
    USR.ERR = ''
    FN.REDO.APAP.USER.LIMITS = 'F.REDO.APAP.USER.LIMITS'
    F.REDO.APAP.USER.LIMITS = ''
    CALL OPF(FN.REDO.APAP.USER.LIMITS,F.REDO.APAP.USER.LIMITS)
RETURN
*---------------------------------------------------------------------------
PROCESS:
*----------
* This section process the values of certain fields and raise the error message
* accordingly

    Y.APPLICATION = R.NEW(REDO.USR.LIM.APPLICATION)
    Y.BPS.LIMIT = R.NEW(REDO.USR.LIM.BPS.LIMIT)
    Y.BPS.LIMIT.DATE = R.NEW(REDO.USR.LIM.BPS.LIM.VALID.DATE)
    Y.MM.LIMIT.DATE = R.NEW(REDO.USR.LIM.MM.LIMIT.DATE)
    Y.SC.LIMIT.DATE = R.NEW(REDO.USR.LIM.SC.LIMIT.DATE)
    CHANGE @VM TO @FM IN Y.APPLICATION
    LOCATE 'FX' IN Y.APPLICATION SETTING FX.POS THEN

        Y.SIN.TXM.AMT.DOP = R.NEW(REDO.USR.LIM.SIN.TXN.LIM.AMT)<1,FX.POS>
        Y.TOT.TXN.AMT.DOP = R.NEW(REDO.USR.LIM.TOT.TXN.LIM.AMT)<1,FX.POS>

        IF Y.SIN.TXM.AMT.DOP NE '' THEN
            AF = REDO.USR.LIM.SIN.TXN.LIM.AMT
            AV = FX.POS
            ETEXT = 'EB-FX.DOP.NOT.ALLOWED'
            CALL STORE.END.ERROR
            RETURN
        END

        IF Y.TOT.TXN.AMT.DOP NE '' THEN
            AF = REDO.USR.LIM.TOT.TXN.LIM.AMT
            AV = FX.POS
            ETEXT = 'EB-FX.DOP.NOT.ALLOWED'
            CALL STORE.END.ERROR
            RETURN
        END

        IF Y.BPS.LIMIT EQ '' OR Y.BPS.LIMIT.DATE EQ '' THEN
            AF = ''
            ETEXT = 'EB-ENTER.BPS.DETS'
            CALL STORE.END.ERROR
        END


    END
    LOCATE 'MM' IN Y.APPLICATION SETTING MM.POS THEN
        IF Y.MM.LIMIT.DATE EQ '' THEN
            AF = ''
            ETEXT = 'EB-ENTER.MM.LIM.DATE'
            CALL STORE.END.ERROR
        END
    END
    LOCATE 'SC' IN Y.APPLICATION SETTING SC.POS THEN
        IF Y.SC.LIMIT.DATE EQ '' THEN
            AF = ''
            ETEXT = 'EB-ENTER.SC.LIM.DATE'
            CALL STORE.END.ERROR
        END
    END
RETURN

*---------------------------------------------------------------------------
END
