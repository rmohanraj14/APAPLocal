* @ValidationCode : MjotMjA2NTg0NDcwMzpDcDEyNTI6MTY4MTMwMTUyOTA1OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:42:09
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
SUBROUTINE REDO.V.AUT.UPD.FX.POS
*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Pradeep S
* Program Name  : REDO.V.AUT.UPD.FX.POS
* ODR NUMBER    : PACS00051758
*----------------------------------------------------------------------------------
* Description   : This is an authorisation routine attached in Version Control for FOREX/TELLER/FT
*                 which is used to update the table REDO.FX.CCY.POSN for local currency
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
*    Date           Author          Reference           Description
* 13-Apr-2011       Pradeep S       PACS00051758        Initial Creation
* 07-Nov-2011       Pradeep S       PACS00157021        Deletion flag included
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR, SM TO @SM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER
    $INSERT I_F.FOREX
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.FX.CCY.POSN
*
    GOSUB PERF.PRE.VAL          ;* PERFORMANCE FIX TO EXCLUDE THE CALL FOR FX POSITION

    IF Y.PERF.FLAG ELSE
        GOSUB OPEN.PARA
        GOSUB INITIAL.PROCESS
        GOSUB READ.DETS

        IF V$FUNCTION EQ 'R' OR Y.REC.STAT EQ 'RNAU' OR Y.REC.STAT EQ 'RNAO' THEN
            GOSUB REVE.PROCESS
        END ELSE
            GOSUB WRITE.DETS
        END
    END
*
RETURN
*
*=========
OPEN.PARA:
*=========

    FN.FOREX = 'F.FOREX'
    F.FOREX  = ''
    CALL OPF(FN.FOREX, F.FOREX)

    FN.TELLER = 'F.TELLER'
    F.TELLER  = ''
    CALL OPF(FN.TELLER, F.TELLER)

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)

    FN.REDO.FX.CCY.POSN = 'F.REDO.FX.CCY.POSN'
    F.REDO.FX.CCY.POSN  = ''
    CALL OPF(FN.REDO.FX.CCY.POSN, F.REDO.FX.CCY.POSN)

RETURN

*===============
INITIAL.PROCESS:
*===============

    BEGIN CASE

        CASE (APPLICATION EQ 'FUNDS.TRANSFER')

            Y.REC.STAT = R.NEW(FT.RECORD.STATUS)

            GOSUB UPDATE.FT

        CASE (APPLICATION EQ 'FOREX')

            Y.REC.STAT = R.NEW(FX.RECORD.STATUS)

            GOSUB UPDATE.FX

        CASE (APPLICATION EQ 'TELLER')

            Y.REC.STAT = R.NEW(TT.TE.RECORD.STATUS)

            GOSUB UPDATE.TT

        CASE OTHERWISE
            GOSUB PGM.END
    END CASE

RETURN

*=========
UPDATE.FT:
*=========

    Y.TRANS.REF = ID.NEW

    Y.BUY.CCY      = R.NEW(FT.DEBIT.CURRENCY)
    Y.BUY.NOM.TEMP = R.NEW(FT.AMOUNT.DEBITED)
    Y.BUY.LGTH     = LEN(Y.BUY.NOM.TEMP)
    Y.BUY.NOM      = Y.BUY.NOM.TEMP[4,Y.BUY.LGTH]
    Y.BUY.RATE     = R.NEW(FT.TREASURY.RATE)

    Y.SELL.CCY      = R.NEW(FT.CREDIT.CURRENCY)
    Y.SELL.NOM.TEMP = R.NEW(FT.AMOUNT.CREDITED)
    Y.SELL.LGTH     = LEN(Y.SELL.NOM.TEMP)
    Y.SELL.NOM      = Y.SELL.NOM.TEMP[4,Y.SELL.LGTH]
    Y.SELL.RATE     = R.NEW(FT.TREASURY.RATE)

RETURN

*=========
UPDATE.FX:
*=========

    Y.TRANS.REF = ID.NEW

    Y.BUY.CCY   = R.NEW(FX.CURRENCY.BOUGHT)
    Y.BUY.NOM   = R.NEW(FX.AMOUNT.BOUGHT)
    Y.BUY.RATE  = R.NEW(FX.SPOT.RATE)

    Y.SELL.CCY  = R.NEW(FX.CURRENCY.SOLD)
    Y.SELL.NOM  = R.NEW(FX.AMOUNT.SOLD)
    Y.SELL.RATE = R.NEW(FX.SPOT.RATE)

RETURN

*=========
UPDATE.TT:
*=========

    Y.TRANS.REF = ID.NEW

    Y.DR.CR.MARKER = R.NEW(TT.TE.DR.CR.MARKER)

    IF Y.DR.CR.MARKER EQ 'DEBIT' THEN

        Y.BUY.CCY       = R.NEW(TT.TE.CURRENCY.1)

        IF Y.BUY.CCY EQ LCCY THEN
            Y.BUY.NOM   = R.NEW(TT.TE.AMOUNT.LOCAL.1)
        END ELSE
            Y.BUY.NOM = R.NEW(TT.TE.AMOUNT.FCY.1)
        END

        Y.BUY.RATE      = R.NEW(TT.TE.DEAL.RATE)

        Y.SELL.CCY      = R.NEW(TT.TE.CURRENCY.2)

        IF Y.SELL.CCY EQ LCCY THEN
            Y.SELL.NOM  = R.NEW(TT.TE.AMOUNT.LOCAL.2)
        END ELSE
            Y.SELL.NOM  = R.NEW(TT.TE.AMOUNT.FCY.2)
        END

        Y.SELL.RATE = R.NEW(TT.TE.DEAL.RATE)

    END

    IF Y.DR.CR.MARKER EQ 'CREDIT' THEN

        Y.BUY.CCY  = R.NEW(TT.TE.CURRENCY.2)

        IF Y.BUY.CCY EQ LCCY THEN
            Y.BUY.NOM  = R.NEW(TT.TE.AMOUNT.LOCAL.2)
        END ELSE
            Y.BUY.NOM  = R.NEW(TT.TE.AMOUNT.FCY.2)
        END

        Y.BUY.RATE = R.NEW(TT.TE.DEAL.RATE)

        Y.SELL.CCY = R.NEW(TT.TE.CURRENCY.1)

        IF Y.SELL.CCY EQ LCCY THEN
            Y.SELL.NOM  = R.NEW(TT.TE.AMOUNT.LOCAL.1)
        END ELSE
            Y.SELL.NOM  = R.NEW(TT.TE.AMOUNT.FCY.1)
        END

        Y.SELL.RATE = R.NEW(TT.TE.DEAL.RATE)

    END

RETURN

*=========
READ.DETS:
*=========

    Y.BUY.ID  = Y.BUY.CCY:TODAY
    Y.SELL.ID = Y.SELL.CCY:TODAY

    CALL F.READU(FN.REDO.FX.CCY.POSN,Y.BUY.ID,R.BUY.REDO.FX.CCY.POSN,F.REDO.FX.CCY.POSN,Y.ERR.BUY,'')

    CALL F.READU(FN.REDO.FX.CCY.POSN,Y.SELL.ID,R.SELL.REDO.FX.CCY.POSN,F.REDO.FX.CCY.POSN,Y.ERR.SELL,'')

RETURN

*===========
WRITE.DETS:
*===========

    Y.TEMP.TIME = OCONV(TIME(),"MTS")
    Y.TEMP.TIME = Y.TEMP.TIME[1,5]
    CHANGE ':' TO '' IN Y.TEMP.TIME

    Y.CHECK.DATE = DATE()
    Y.DATE.TIME = OCONV(Y.CHECK.DATE,"DY2"):FMT(OCONV(Y.CHECK.DATE,"DM"),'R%2'):FMT(OCONV(Y.CHECK.DATE,"DD"),'R%2'):Y.TEMP.TIME

    IF (Y.BUY.CCY EQ LCCY) AND (Y.SELL.CCY NE LCCY) THEN
        GOSUB UPDATE.BUY.CCY.NOM
        GOSUB UPDATE.BUY.AUDIT.FIELS
        GOSUB WRITE.FINAL
    END

    IF (Y.SELL.CCY EQ LCCY) AND (Y.BUY.CCY NE LCCY) THEN
        GOSUB UPDATE.SELL.CCY.NOM
        GOSUB UPDATE.SELL.AUDIT.FIELS
        GOSUB WRITE.FINAL
    END


RETURN

*======================
UPDATE.BUY.AUDIT.FIELS:
*======================

    R.BUY.REDO.FX.CCY.POSN<REDO.FX.DATE.TIME>             = Y.DATE.TIME
    R.BUY.REDO.FX.CCY.POSN<REDO.FX.INPUTTER>              = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto Code Conversion
    R.BUY.REDO.FX.CCY.POSN<REDO.FX.AUTHORISER>            = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto Code Conversion
    R.BUY.REDO.FX.CCY.POSN<REDO.FX.CO.CODE>               = ID.COMPANY
    R.BUY.REDO.FX.CCY.POSN<REDO.FX.DEPT.CODE>             = R.USER<EB.USE.DEPARTMENT.CODE>
    Y.CURR.NO =  R.BUY.REDO.FX.CCY.POSN<REDO.FX.CURR.NO>
    R.BUY.REDO.FX.CCY.POSN<REDO.FX.CURR.NO>               = Y.CURR.NO + 1

RETURN

*=======================
UPDATE.SELL.AUDIT.FIELS:
*=======================

    R.SELL.REDO.FX.CCY.POSN<REDO.FX.DATE.TIME>              = Y.DATE.TIME
    R.SELL.REDO.FX.CCY.POSN<REDO.FX.AUTHORISER>             = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto Code Conversion
    R.SELL.REDO.FX.CCY.POSN<REDO.FX.CO.CODE>                = ID.COMPANY
    R.SELL.REDO.FX.CCY.POSN<REDO.FX.DEPT.CODE>              = R.USER<EB.USE.DEPARTMENT.CODE>
    Y.CURR.NO =  R.SELL.REDO.FX.CCY.POSN<REDO.FX.CURR.NO>
    R.SELL.REDO.FX.CCY.POSN<REDO.FX.CURR.NO>                = Y.CURR.NO + 1

RETURN


*======================
UPDATE.BUY.CCY.NOM:
*======================

    Y.POS.CCY = R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY>
    Y.TXN.REF = R.BUY.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF>
    Y.TXN.REF.CNT = DCOUNT(Y.TXN.REF,@SM)
    Y.TXN.REF.CNT += 1

    LOCATE Y.SELL.CCY IN Y.POS.CCY<1,1> SETTING CCY.POS THEN

        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS> -= Y.BUY.NOM
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,CCY.POS,Y.TXN.REF.CNT> = ''
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,CCY.POS,Y.TXN.REF.CNT> = Y.BUY.NOM
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS,-1> = ID.NEW

    END ELSE
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY,-1> = Y.SELL.CCY
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,-1> = Y.BUY.NOM
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,-1> = ''
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,-1> = Y.BUY.NOM
        R.BUY.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,-1> = ID.NEW

    END

RETURN

*======================
UPDATE.SELL.CCY.NOM:
*======================

    Y.POS.CCY = R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY>
    Y.TXN.REF = R.SELL.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF>
    Y.TXN.REF.CNT = DCOUNT(Y.TXN.REF,@SM)
    Y.TXN.REF.CNT += 1

    LOCATE Y.BUY.CCY IN Y.POS.CCY<1,1> SETTING CCY.POS THEN

        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS> += Y.SELL.NOM
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,CCY.POS,Y.TXN.REF.CNT> = ''
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,CCY.POS,Y.TXN.REF.CNT> = Y.SELL.NOM
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS,-1> = ID.NEW

    END ELSE
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY,-1> = Y.BUY.CCY
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,-1> = Y.SELL.NOM
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,-1> = ''
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,-1> = Y.SELL.NOM
        R.SELL.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,-1> = ID.NEW

    END

RETURN

*===========
REVE.PROCESS:
*===========


    IF Y.BUY.CCY EQ LCCY THEN
        GOSUB REVE.BUY.CCY.NOM
    END


    IF Y.SELL.CCY EQ LCCY THEN
        GOSUB REVE.SELL.CCY.NOM
    END

*PACS00157021 - S
    IF Y.WRITE.FLAG THEN
        GOSUB WRITE.FINAL
    END
*PACS00157021 - E

RETURN



*================
REVE.BUY.CCY.NOM:
*================

    Y.WRITE.FLAG = ''
    Y.POS.CCY = R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY>

    LOCATE Y.SELL.CCY IN Y.POS.CCY<1,1> SETTING CCY.POS THEN

        Y.TXN.REF = R.BUY.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS>
        Y.TXN.REF.CNT = DCOUNT(Y.TXN.REF,@SM)

        LOCATE ID.NEW IN Y.TXN.REF<1,1,1> SETTING TXN.POS THEN

            R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS> += Y.BUY.NOM
            DEL R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,CCY.POS,TXN.POS>
            DEL R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,CCY.POS,TXN.POS>
            DEL R.BUY.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS,TXN.POS>

            IF Y.TXN.REF.CNT EQ 1 THEN
                DEL R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY,CCY.POS>
                DEL R.BUY.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS>
            END

            Y.WRITE.FLAG = @TRUE

        END

    END

RETURN

*==================
REVE.SELL.CCY.NOM:
*==================

    Y.WRITE.FLAG = ''

    Y.POS.CCY = R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY>

    LOCATE Y.BUY.CCY IN Y.POS.CCY<1,1> SETTING CCY.POS THEN

        Y.TXN.REF = R.SELL.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS>
        Y.TXN.REF.CNT = DCOUNT(Y.TXN.REF,@SM)

        LOCATE ID.NEW IN Y.TXN.REF<1,1,1> SETTING TXN.POS THEN

            R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS> -= Y.SELL.NOM
            DEL R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.SEL.POS,CCY.POS,TXN.POS>
            DEL R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.BUY.POS,CCY.POS,TXN.POS>
            DEL R.SELL.REDO.FX.CCY.POSN<REDO.FX.CCY.TXN.REF,CCY.POS,TXN.POS>

            IF Y.TXN.REF.CNT EQ 1 THEN
                DEL R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY,CCY.POS>
                DEL R.SELL.REDO.FX.CCY.POSN<REDO.FX.TXN.CCY.TOT,CCY.POS>
            END

            Y.WRITE.FLAG = @TRUE

        END

    END

RETURN

*===========
WRITE.FINAL:
*===========

    IF Y.BUY.CCY EQ LCCY THEN
        CALL F.WRITE(FN.REDO.FX.CCY.POSN,Y.BUY.ID,R.BUY.REDO.FX.CCY.POSN)
        CALL F.RELEASE(FN.REDO.FX.CCY.POSN,Y.BUY.ID,F.BUY.REDO.FX.CCY.POSN)
    END

    IF Y.SELL.CCY EQ LCCY THEN
        CALL F.WRITE(FN.REDO.FX.CCY.POSN,Y.SELL.ID,R.SELL.REDO.FX.CCY.POSN)
        CALL F.RELEASE(FN.REDO.FX.CCY.POSN,Y.SELL.ID,F.SELL.REDO.FX.CCY.POSN)
    END


RETURN


*-----------*
PERF.PRE.VAL:
*-----------*

    Y.PERF.FLAG = ''

    BEGIN CASE
        CASE APPLICATION EQ 'FOREX'
            Y.PERF.DCCY = R.NEW(FX.CURRENCY.SOLD)
            Y.PERF.CCCY = R.NEW(FX.CURRENCY.BOUGHT)

        CASE APPLICATION EQ 'FUNDS.TRANSFER'
            Y.PERF.DCCY = R.NEW(FT.DEBIT.CURRENCY)
            Y.PERF.CCCY = R.NEW(FT.CREDIT.CURRENCY)

        CASE APPLICATION EQ 'TELLER'
            Y.PERF.DCCY = R.NEW(TT.TE.CURRENCY.1)
            Y.PERF.CCCY = R.NEW(TT.TE.CURRENCY.2)

    END CASE

    IF Y.PERF.DCCY EQ LCCY AND Y.PERF.CCCY EQ LCCY THEN
        Y.PERF.FLAG = '1'
    END

RETURN

*---------------------------------------------------------------------------------------------------------------------

*=======
PGM.END:
*=======

END
