* @ValidationCode : MjotMTc4NzU2MjQyMzpDcDEyNTI6MTY4MTk3MzE0MDE0ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:15:40
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
SUBROUTINE REDO.V.VAL.MGRITEM.CODE
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.V.VAL.MGRITEM.CODE
* ODR NO      : ODR-2009-12-0285
*----------------------------------------------------------------------
*DESCRIPTION: This routine is validation routine to ACCOUNT.2 or CREDIT.ACCOUNT
* in below versions,
* FUNDS.TRANSFER,MGR.CHQ.TAX
* FUNDS.TRANSFER,MGRUSD.CHQ.TAX
* FUNDS.TRANSFER,MGR.CHQ.NO.TAX
* FUNDS.TRANSFER,MGRUSD.CHQ.NO.TAX
* TELLER,MGR.CHQ.TAX
* TELLER,MGR.CHQ.NOTAX



*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: TELLER & FT
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*19.02.2010  H GANESH     ODR-2009-12-0285  INITIAL CREATION
*7-FEB-2011  KAVITHA      ODR-2009-12-0285  CODE CHANGE FOR HD1052466 FIX
*18-EB-2011  KAVITHA      ODR-2009-12-0285  CODE CHANGE FOR HD1054080 FIX
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.MANAGER.CHQ.PARAM
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.H.BANK.DRAFTS

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------
    FN.REDO.MANAGER.CHQ.PARAM='F.REDO.MANAGER.CHQ.PARAM'
    F.REDO.MANAGER.CHQ.PARAM=''

*HD1052466-s

*    FN.REDO.H.ADMIN.CHEQUES='F.REDO.H.ADMIN.CHEQUES'
    FN.REDO.H.ADMIN.CHEQUES='F.REDO.H.BANK.DRAFTS'
    F.REDO.H.ADMIN.CHEQUES=''

*HD1052466-E

RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    CALL OPF(FN.REDO.MANAGER.CHQ.PARAM,F.REDO.MANAGER.CHQ.PARAM)
    CALL OPF(FN.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES)
RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    Y.PARAM.ID='SYSTEM'
    CALL CACHE.READ(FN.REDO.MANAGER.CHQ.PARAM,Y.PARAM.ID,R.REDO.MANAGER.CHQ.PARAM,PARAM.ERR)

*****THIS PART HAS BEEN DONE IN REDO.V.VAL.DEFAULT.ACCT RTN
*IF APPLICATION EQ 'TELLER' THEN
*Y.ACCOUNT=R.NEW(TT.TE.ACCOUNT.2)
*GOSUB GET.ID
*R.NEW(TT.TE.NARRATIVE.1)=Y.NEXT.AVAILABLE.ID
*END

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        R.NEW(FT.CREDIT.ACCT.NO) = COMI
        Y.ACCOUNT = COMI
        GOSUB GET.ID
        R.NEW(FT.CREDIT.THEIR.REF)=Y.NEXT.AVAILABLE.ID
    END
RETURN
*----------------------------------------------------------------------
GET.ID:
*----------------------------------------------------------------------
* To get the next available from the received list of @ID'S

    LOCATE  Y.ACCOUNT IN R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ACCOUNT,1> SETTING POS1 THEN
        Y.ITEM.CODE=R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ITEM.CODE,POS1>

    END
    SEL.CMD='SSELECT ':FN.REDO.H.ADMIN.CHEQUES:' WITH ITEM.CODE EQ ':Y.ITEM.CODE:' AND BRANCH.DEPT EQ ':ID.COMPANY:' AND STATUS EQ AVAILABLE BY SERIAL.NO'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)

    Y.NEXT.AVAILABLE.ID=SEL.LIST<1,1>

    CALL F.READ(FN.REDO.H.ADMIN.CHEQUES,Y.NEXT.AVAILABLE.ID,R.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES,ERR)
*HD1054080-S
    IF R.REDO.H.ADMIN.CHEQUES THEN
        R.REDO.H.ADMIN.CHEQUES<REDO.BANK.STATUS> ="ISSUED"
    END
    CALL F.WRITE(FN.REDO.H.ADMIN.CHEQUES,Y.NEXT.AVAILABLE.ID,R.REDO.H.ADMIN.CHEQUES)
    Y.NEXT.AVAILABLE.ID = R.REDO.H.ADMIN.CHEQUES<REDO.BANK.SERIAL.NO>
*HD1054080-E

RETURN

END
