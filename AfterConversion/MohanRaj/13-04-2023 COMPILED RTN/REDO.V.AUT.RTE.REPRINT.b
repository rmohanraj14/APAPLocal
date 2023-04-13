* @ValidationCode : MjotOTUyMzExOTA4OkNwMTI1MjoxNjgxMzkxNjY5MDk5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:44:29
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
SUBROUTINE REDO.V.AUT.RTE.REPRINT(WID.HOLD)
****************************************************************
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : GANESH R
* Program Name  : REDO.V.AUT.RTE.REPRINT
* ODR NUMBER    : ODR-2009-10-0472
*-------------------------------------------------------------------------

* Description : This Auth routine is triggered when we authorise the transaction
* In parameter : WID.HOLD   ID of the HOLD.CONTROL record created.
* out parameter : None
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.REDO.REPRINT.TXN
    $INSERT I_F.USER
*
    GOSUB INITIALISE
    GOSUB OPEN.FILE
    GOSUB PROCESS
RETURN

INITIALISE:

    FN.REDO.REPRINT='F.REDO.REPRINT.TXN'
    F.REDO.REPRINT=''
*
    FN.REDO.FT.TT.LIVE.REC = 'F.REDO.FT.TT.LIVE.REC'
    F.REDO.FT.TT.LIVE.REC = ''
    CALL OPF(FN.REDO.FT.TT.LIVE.REC,F.REDO.FT.TT.LIVE.REC)
*
    CONTRACT.ID   = ID.NEW
*
    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
    VAR.UNIQUE.ID = UNIQUE.TIME
    CURR.NO       = 1
    INPUTTER      = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    AUTHORISER    = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    TEMPTIME      = OCONV(TIME(),"MTS")
    TEMPTIME      = TEMPTIME[1,5]
    CO.CODE       = ID.COMPANY
    DEPT.CODE     = R.USER<EB.USE.DEPARTMENT.CODE>
    CONTRACT.ID   = ID.NEW
*** Modify by CODE REVIEW
*    CONVERT ':' TO '' IN TEMPTIME
    CHANGE ':' TO '' IN TEMPTIME
***
    CHECK.DATE = DATE()
    DATE.TIME = OCONV(CHECK.DATE,"DY2"):OCONV(CHECK.DATE,"DM"):OCONV(CHECK.DATE,"DD"):TEMPTIME
*
    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        REPRINT.ID    = 'REDO.AML.FT':VAR.UNIQUE.ID
    END
    IF APPLICATION EQ 'TELLER' THEN
        REPRINT.ID    = 'REDO.AML.TT':VAR.UNIQUE.ID
    END
    IF APPLICATION EQ 'T24.FUND.SERVICES' THEN
        REPRINT.ID    = 'REDO.AML.TFS':VAR.UNIQUE.ID
    END
*
RETURN
*
*********
OPEN.FILE:
**********

*Opening Files

    CALL OPF(FN.REDO.REPRINT,F.REDO.REPRINT)

RETURN

**********
PROCESS:
*********
*
*        CALL F.READ(FN.REDO.REPRINT,REPRINT.ID,R.REDO.REPRINT,F.REDO.REPRINT,ERR.PRINT)
    R.REDO.REPRINT                          = ""
    R.REDO.REPRINT<REP.TXN.HOLD.CONTROL.ID> = WID.HOLD
    R.REDO.REPRINT<REP.TXN.CONTRACT.NO> = CONTRACT.ID
    R.REDO.REPRINT<REP.TXN.CURR.NO>     = CURR.NO
    R.REDO.REPRINT<REP.TXN.INPUTTER>    = INPUTTER
    R.REDO.REPRINT<REP.TXN.DATE.TIME>   = DATE.TIME
    R.REDO.REPRINT<REP.TXN.AUTHORISER>  = AUTHORISER
    R.REDO.REPRINT<REP.TXN.CO.CODE>     = CO.CODE
    R.REDO.REPRINT<REP.TXN.DEPT.CODE>   = DEPT.CODE
    CALL F.WRITE(FN.REDO.REPRINT,REPRINT.ID,R.REDO.REPRINT)
*
    GOSUB WR.TMP.TABLE
*
RETURN
*
*************
WR.TMP.TABLE:
*************
*
    R.REDO.FT.TT.LIVE.REC = "" ; LIVE.ERR = ""
    CALL F.READ(FN.REDO.FT.TT.LIVE.REC,TODAY,R.REDO.FT.TT.LIVE.REC,F.REDO.FT.TT.LIVE.REC,LIVE.ERR)
    IF R.REDO.FT.TT.LIVE.REC THEN
        R.REDO.FT.TT.LIVE.REC<-1> = CONTRACT.ID
    END ELSE
        R.REDO.FT.TT.LIVE.REC = CONTRACT.ID
    END
*
    CALL F.WRITE(FN.REDO.FT.TT.LIVE.REC,TODAY,R.REDO.FT.TT.LIVE.REC)
*
RETURN
*
END
