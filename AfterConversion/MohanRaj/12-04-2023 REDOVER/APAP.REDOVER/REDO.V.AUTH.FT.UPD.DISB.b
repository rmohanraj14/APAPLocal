* @ValidationCode : MjotMTc1NzY1NDQ0NzpDcDEyNTI6MTY4MTMwMzY3OTY5NTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:17:59
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
SUBROUTINE REDO.V.AUTH.FT.UPD.DISB
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is an Auth routine attached to version.control FUNDS.TRANSFER,DSB
*
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
*Modification History:-
* Date                 Who                Reference                     Description
*------------------------------------------------------------------------------------
* 09/06/2017       Edwin Charles D       R15 Upgrade                Initial Creation
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.DISB.CHAIN

    GOSUB INIT
    GOSUB PROCESS

RETURN
******
INIT:
******
*Initialize all the variables

    FN.REDO.DISB.CHAIN = 'F.REDO.DISB.CHAIN'
    F.REDO.DISB.CHAIN = ''
    CALL OPF(FN.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN)

    LREF.APP = 'FUNDS.TRANSFER'
    LREF.FIELDS = 'L.INITIAL.ID'

    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    POS.L.INITIAL.ID       = LREF.POS<1,1>

RETURN
***********
PROCESS:
***********

    Y.INITIAL.ID = ''; Y.TEMP.FT.ID = '' ; R.REDO.DISB.CHAIN = ''
    Y.INITIAL.ID   = R.NEW(FT.LOCAL.REF)<1,POS.L.INITIAL.ID>
    Y.TEMP.FT.ID   = R.NEW(FT.CREDIT.THEIR.REF)
    CALL F.READ(FN.REDO.DISB.CHAIN,Y.INITIAL.ID,R.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN,CHAIN.ERR)
    IF R.REDO.DISB.CHAIN THEN
        TEMP.FT.ID.ARR = R.REDO.DISB.CHAIN<DS.CH.FT.TEMP.REF>
        LOCATE Y.TEMP.FT.ID IN TEMP.FT.ID.ARR<1,1> SETTING FT.POS THEN
            R.REDO.DISB.CHAIN<DS.CH.TRANSACTION.ID, FT.POS> = ID.NEW
            R.REDO.DISB.CHAIN<DS.CH.VERSION, FT.POS>        = APPLICATION:PGM.VERSION
        END

        CALL F.WRITE(FN.REDO.DISB.CHAIN,Y.INITIAL.ID,R.REDO.DISB.CHAIN)
    END
RETURN
******************************************************************************************************
END
