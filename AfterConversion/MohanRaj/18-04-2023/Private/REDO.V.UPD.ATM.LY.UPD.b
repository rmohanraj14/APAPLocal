* @ValidationCode : MjotMTQ5ODA2NzYxNDpDcDEyNTI6MTY4MTgxNjAwMjczNzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:36:42
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
SUBROUTINE REDO.V.UPD.ATM.LY.UPD
*-----------------------------------------------------------------------------
* Developer   : TAM
* Date        : 08.04.2013
* Description : AUTH ROUTINE FOR VERSIONS AS FOLLOWS
* TELLER      : REDO.V.UPD.ATM.LY.UPD
*----------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : --N/A--
* Out : --N/A--
*----------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : --N/A--
* Called By : --N/A--
*----------------------------------------------------------------------------
* Revision History:
* -----------------
* Date          Name                                Reference                      Description
* -------       ----                                ---------                      ------------
* 08-04-2013  Prabhu N                              B.166                               Initial creation
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.LY.POINTS.US
    $INSERT I_F.ATM.REVERSAL
*

    GOSUB INITIALIZE
    GOSUB PROCESS
*
RETURN
*
***********
INITIALIZE:
***********
    Y.REF='AT.UNIQUE.ID'
    Y.APPLICATION=APPLICATION
    Y.POS=''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.REF,Y.POS)

    FN.ATM.REVERSAL='F.ATM.REVERSAL'
    F.ATM.REVERSAL =''
    CALL OPF(FN.ATM.REVERSAL,F.ATM.REVERSAL)

    FN.REDO.LY.POINTS.US='F.REDO.LY.POINTS.US'
    F.REDO.LY.POINTS.US =''
    CALL OPF(FN.REDO.LY.POINTS.US,F.REDO.LY.POINTS.US)

RETURN
*
********
PROCESS:
********
    IF R.NEW(FT.LOCAL.REF)<1,Y.POS> NE '' THEN
        Y.ATM.REV.ID=R.NEW(FT.LOCAL.REF)<1,Y.POS>
        CALL F.READ(FN.ATM.REVERSAL,Y.ATM.REV.ID,R.ATM.REVERSAL,F.ATM.REVERSAL,ATM.ERR)
        Y.LY.POINT.ID=R.ATM.REVERSAL<AT.REV.LY.PTS.US.REF>
*        CALL F.READ(FN.REDO.LY.POINTS.US,Y.LY.POINT.ID,R.REDO.LY.POINTS.US,F.REDO.LY.POINTS.US,ERR)
        R.REDO.LY.POINTS.US<REDO.PT.US.TXN.REF.US>=Y.ATM.REV.ID
        R.REDO.LY.POINTS.US<REDO.PT.US.DESC.US>   ='ATM txn'


        APP.NAME = 'REDO.LY.POINTS.US'
        OFSFUNCT='I'
        PROCESS  = ''
        OFSVERSION = 'REDO.LY.POINTS.US,CREATE.DC'
        GTSMODE = ''
        TRANSACTION.ID=''
        OFSRECORD = ''
        OFS.MSG.ID =''
        OFS.ERR = ''
        NO.OF.AUTH='0'
        TRANSACTION.ID=Y.LY.POINT.ID
        CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.REDO.LY.POINTS.US,STR.FT)
        R.FUNDS.TRANSFER=''
        OFS.SRC='DEBIT.CARD'

        OFS.STRING.FINAL=STR.FT
        CALL OFS.POST.MESSAGE(OFS.STRING.FINAL,OFS.MSG.ID,OFS.SRC,OPTIONS)

    END
RETURN
*
END
