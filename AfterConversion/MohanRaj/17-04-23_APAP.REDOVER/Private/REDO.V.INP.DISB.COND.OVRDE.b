* @ValidationCode : Mjo0MzIyNjI4MzM6Q3AxMjUyOjE2ODE3Mjg0MTA1ODU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:16:50
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
SUBROUTINE REDO.V.INP.DISB.COND.OVRDE
*-----------------------------------------------------------------------------
*COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*-------------
*DEVELOPED BY: Temenos Application Management
*-------------
*SUBROUTINE TYPE: INPUT routine
*------------
*DESCRIPTION:
*------------
* This routine is used to raise the override if loan status and condition having block
*---------------------------------------------------------------------------
* Input / Output
*----------------
*
* Input / Output
* IN     : -na-
* OUT    : -na-
*
*-----------------------------------------------------------------------------
* Revision History
* Date           Who                Reference              Description
* 23-sep-2011   MARIMUTHU S        PACS00136030          Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER


MAIN:

    GOSUB PROCESS
    GOSUB PGM.END

PROCESS:

    LR.APP = 'FUNDS.TRANSFER'
    LR.FLDS = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    LR.POS = ''
    CALL MULTI.GET.LOC.REF(LR.APP,LR.FLDS,LR.POS)
    POS.L.LOAN.ST = LR.POS<1,1>
    POS.L.LOAN.CON = LR.POS<1,2>

    Y.STATUS = R.NEW(FT.LOCAL.REF)<1,POS.L.LOAN.ST>
    Y.COND = R.NEW(FT.LOCAL.REF)<1,POS.L.LOAN.CON>

    IF Y.STATUS MATCHES 'JudicialCollection' OR Y.STATUS MATCHES 'Write-off' THEN
        AF = FT.LOCAL.REF
        AV = POS.L.LOAN.ST
        CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM) + 1
        TEXT = 'REDO.LOAN.BLOCK.ST'
        CALL STORE.OVERRIDE(CURR.NO)
    END
    IF Y.COND MATCHES 'Legal' THEN
        AF = FT.LOCAL.REF
        AV = POS.L.LOAN.CON
        CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),@VM) + 1
        TEXT = 'REDO.LOAN.BLOCK.ST'
        CALL STORE.OVERRIDE(CURR.NO)
    END


RETURN


PGM.END:


END
