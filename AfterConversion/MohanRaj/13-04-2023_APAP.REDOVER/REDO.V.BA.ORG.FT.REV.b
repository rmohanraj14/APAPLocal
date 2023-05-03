* @ValidationCode : MjotODYzNTk5ODA2OkNwMTI1MjoxNjgxMzgyNDEyNjQyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:10:12
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
SUBROUTINE REDO.V.BA.ORG.FT.REV

*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Edwin Charles D
* Program Name  : REDO.V.BA.REAL.FT.TXN
*-------------------------------------------------------------------------
* Description: This routine is auth routine to process FT from REDO.FT.TT.TRANSACTION
*
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
* DATE         Name              ODR / HD REF              DESCRIPTION
* 14-06-17     Edwin Charles D   R15 Ugrade                Initial creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     F.READ TO CACHE.READ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.DISB.CHAIN

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:
*****
    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)

    FN.REDO.DISB.CHAIN = 'F.REDO.DISB.CHAIN'
    F.REDO.DISB.CHAIN = ''
    CALL OPF(FN.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN)

RETURN

PROCESS:
********

    Y.L.INITIAL.ID = R.NEW(FT.TN.L.INITIAL.ID)
    CALL F.READ(FN.REDO.DISB.CHAIN,Y.L.INITIAL.ID,R.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN,DISB.ERR)
    IF R.REDO.DISB.CHAIN THEN
        LOCATE ID.NEW IN R.REDO.DISB.CHAIN<DS.CH.FT.TEMP.REF,1> SETTING POS1 THEN
            IF R.REDO.DISB.CHAIN<DS.CH.TR.STATUS,POS1> EQ 'RNAU' THEN
                Y.FT.ID = R.REDO.DISB.CHAIN<DS.CH.TRANSACTION.ID,POS1>
            END
        END
    END
    IF Y.FT.ID THEN
        OFSVERSION = 'FUNDS.TRANSFER,REDO.DISB.REV'
        GOSUB POST.OFS
    END
RETURN

POST.OFS:
*********
    Y.USR = OPERATOR
    CALL CACHE.READ(FN.USER, Y.USR, R.USR, ERR.US) ;*R22 Auto code conversion
    OFS.USERNAME = R.USR<EB.USE.SIGN.ON.NAME>
    OFS.PASSWORD = R.USR<EB.USE.PASSWORD>
    Y.OFS.MSG = ''
    Y.OFS.MSG = OFSVERSION:'/R/PROCESS,':OFS.USERNAME:'/':OFS.PASSWORD:'/':ID.COMPANY:',':Y.FT.ID

    ofsRequest = Y.OFS.MSG
    CALL ofs.addLocalRequest(ofsRequest,'add',error)
    MSG.OUT = ofsRequest
RETURN
END
