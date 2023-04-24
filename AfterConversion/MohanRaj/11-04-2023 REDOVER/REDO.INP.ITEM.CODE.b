* @ValidationCode : MjoyMDY2Mzk0OTIzOkNwMTI1MjoxNjgxMjE0MTA1ODg3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:25:05
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
SUBROUTINE REDO.INP.ITEM.CODE
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: MARIMUTHU S
* PROGRAM NAME: REDO.INP.ITEM.CODE
* ODR NO      : PACS00062902
*----------------------------------------------------------------------
*DESCRIPTION: This routine is input routine attached with FT,CHQ.TRANS.INTERNAL

*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: TELLER & FT
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*18-07-2011  Marimuthu                      PACS00062902
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion    TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.ADMIN.CHQ.PARAM
    $INSERT I_F.REDO.H.ADMIN.CHEQUES


    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN

*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------
    Y.ITEM.CODE=''
    FN.REDO.ADMIN.CHQ.PARAM='F.REDO.ADMIN.CHQ.PARAM'
    F.REDO.ADMIN.CHQ.PARAM=''
    FN.REDO.H.ADMIN.CHEQUES='F.REDO.H.ADMIN.CHEQUES'
    F.REDO.H.ADMIN.CHEQUES=''

RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    CALL OPF(FN.REDO.ADMIN.CHQ.PARAM,F.REDO.ADMIN.CHQ.PARAM)
    CALL OPF(FN.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES)
RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

    Y.PARAM.ID='SYSTEM'
    CALL CACHE.READ(FN.REDO.ADMIN.CHQ.PARAM,Y.PARAM.ID,R.REDO.ADMIN.CHQ.PARAM,PARAM.ERR)

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        Y.ACCOUNT=R.NEW(FT.CREDIT.ACCT.NO)
        GOSUB GET.ID
        R.NEW(FT.CREDIT.THEIR.REF)=Y.NEXT.AVAILABLE.ID
    END
RETURN
*----------------------------------------------------------------------
GET.ID:
*----------------------------------------------------------------------
* To get the next available from the received list of @ID'S

    IF V$FUNCTION EQ 'I' THEN
        LOCATE Y.ACCOUNT IN R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ACCOUNT,1> SETTING POS1 THEN
            Y.ITEM.CODE=R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ITEM.CODE,POS1>
        END
        SEL.CMD='SSELECT ':FN.REDO.H.ADMIN.CHEQUES:' WITH ITEM.CODE EQ ':Y.ITEM.CODE:' AND BRANCH.DEPT EQ ':ID.COMPANY:' AND STATUS EQ AVAILABLE BY SERIAL.NO'
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)
        Y.NEXT.AVAILABLE.ID=SEL.LIST<1,1>
        CALL F.READ(FN.REDO.H.ADMIN.CHEQUES,Y.NEXT.AVAILABLE.ID,R.REDO.H.ADMIN.CHEQUES,F.REDO.H.ADMIN.CHEQUES,ERR)
        IF R.REDO.H.ADMIN.CHEQUES THEN
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.STATUS> ="ISSUED"
            CON.DATE = OCONV(DATE(),"D-")
            DATE.TIME = CON.DATE[9,2]:CON.DATE[1,2]:CON.DATE[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.DATE.TIME>= DATE.TIME
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CO.CODE> = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CURR.NO> = 1
            R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.CO.CODE>=ID.COMPANY
            CALL F.WRITE(FN.REDO.H.ADMIN.CHEQUES,Y.NEXT.AVAILABLE.ID,R.REDO.H.ADMIN.CHEQUES)
        END
        Y.NEXT.AVAILABLE.ID = R.REDO.H.ADMIN.CHEQUES<REDO.ADMIN.SERIAL.NO>
        IF Y.NEXT.AVAILABLE.ID EQ '' THEN
            ETEXT = 'EB-DRAFT.NO.MISSING'
            AF = FT.CREDIT.THEIR.REF
            CALL STORE.END.ERROR
        END
    END

RETURN

END
