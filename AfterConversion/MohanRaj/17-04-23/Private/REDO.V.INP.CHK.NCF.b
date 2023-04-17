* @ValidationCode : Mjo3NzA4NDMzNzM6Q3AxMjUyOjE2ODE3MjY2MzgzOTc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 15:47:18
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
SUBROUTINE REDO.V.INP.CHK.NCF
*--------------------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : GANESH R  Program Name  : REDO.V.INP.CHK.NCF   ODR NUMBER : ODR-2009-10-0321
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ,SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
* Description : This i/p routine is triggered when FT,TT,MM,DD,DC,FX transaction is made
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.FOREX
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.DATA.CAPTURE
    $INSERT I_F.DD.DDI
    $INSERT I_F.TRANSACTION
    $INSERT I_F.DD.TXN.CODES
*

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
*
RETURN
*----------------------------------------------------------------------------------
********
INIT:
*Initialisation
    VAR.TXN.ID = ''
    LRF.APP    = APPLICATION
    LRF.FIELD  = 'L.NCF.REQUIRED'
    LRF.POS    = ''
    IF APPLICATION EQ 'TELLER' OR APPLICATION EQ 'FUNDS.TRANSFER' THEN
        LRF.FIELD  = 'L.NCF.REQUIRED':@VM:'L.TT.COMM.AMT':@VM:'L.TT.TAX.AMT':@VM:'L.TT.WV.COMM':@VM:'L.TT.WV.TAX'
    END
*
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)
    POS.NCF.REQ=LRF.POS<1,1>
*
    POS.WV.COM=LRF.POS<1,4>
    POS.WV.TAX=LRF.POS<1,5>
*
    FN.TRANSACTION='F.TRANSACTION'
    F.TRANSACTION=''
*
    FN.DD.TXN.CODES='F.DD.TXN.CODES'
    F.DD.TXN.CODES=''
*
RETURN
*
***********
OPEN.FILES:
***********
*
    CALL OPF(FN.TRANSACTION,F.TRANSACTION)
    CALL OPF(FN.DD.TXN.CODES,F.DD.TXN.CODES)
*
RETURN
********
PROCESS:
*Checking for the values in the fields and raising Override
    VAR.APPLN=APPLICATION
    IF VAR.APPLN EQ 'FUNDS.TRANSFER' THEN
        GOSUB FT.PROCESS
    END
    IF VAR.APPLN EQ 'TELLER' THEN
        GOSUB TT.PROCESS
    END
    IF VAR.APPLN EQ 'MM.MONEY.MARKET' THEN
        GOSUB MM.PROCESS
    END
    IF VAR.APPLN EQ 'DATA.CAPTURE' THEN
        GOSUB DC.PROCESS
    END
    IF VAR.APPLN EQ 'DD.DDI' THEN
        GOSUB DD.PROCESS
    END
    IF VAR.APPLN EQ 'FOREX' THEN
        GOSUB FX.PROCESS
    END
RETURN
*
* =========
FT.PROCESS:
* =========
*
*   Checking for the Local Field and raising Overrride
*
    Y.COM.POS       =LRF.POS<1,2>
    Y.TAX.POS       =LRF.POS<1,3>

    WT.OVERRIDE     = FT.OVERRIDE
* VAR.TOT.CHG.AMT = R.NEW(FT.TOTAL.CHARGE.AMOUNT)
    VAR.NCF.REQ     = R.NEW(FT.LOCAL.REF)<1,POS.NCF.REQ>
*

    VAR.TOT.CHG.AMT = R.NEW(FT.LOCAL.REF)<1,Y.COM.POS>
    VAR.TOT.TAX.AMT = R.NEW(FT.LOCAL.REF)<1,Y.TAX.POS>


    IF VAR.TOT.CHG.AMT OR VAR.TOT.TAX.AMT THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
* =========
TT.PROCESS:
* =========
*
*   Checking for the Local Field and raising Overrride
*
    WT.OVERRIDE     = TT.TE.OVERRIDE
    Y.COM.POS       =LRF.POS<1,2>
    Y.TAX.POS       =LRF.POS<1,3>
    VAR.CHG.AMT.LOC = R.NEW(TT.TE.CHRG.AMT.LOCAL)
*    VAR.CHG.AMT.FCC = R.NEW(TT.TE.CHRG.AMT.FCCY)
    VAR.NCF.REQ     = R.NEW(TT.TE.LOCAL.REF)<1,POS.NCF.REQ>
    VAR.TOT.CHG.AMT = R.NEW(TT.TE.LOCAL.REF)<1,Y.COM.POS>
    VAR.TOT.TAX.AMT = R.NEW(TT.TE.LOCAL.REF)<1,Y.TAX.POS>
*
    VAR.WV.COM = R.NEW(TT.TE.LOCAL.REF)<1,POS.WV.COM>
    VAR.WV.TAX = R.NEW(TT.TE.LOCAL.REF)<1,POS.WV.TAX>

    IF VAR.TOT.CHG.AMT OR VAR.TOT.TAX.AMT THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
* =========
FX.PROCESS:
* =========
*
*   Checking for the Local Field and raising Overrride
*
    WT.OVERRIDE     = FX.OVERRIDE
    VAR.DEL.CHG.AMT = R.NEW(FX.DEL.CHG.AMT)
    VAR.CHG.AMT     = R.NEW(FX.CHARGE.AMOUNT)
    VAR.TOT.CHG.AMT = VAR.DEL.CHG.AMT+VAR.CHG.AMT
    VAR.NCF.REQ     = R.NEW(FX.LOCAL.REF)<1,POS.NCF.REQ>
*
    IF VAR.TOT.CHG.AMT GT 0 THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
* =========
MM.PROCESS:
* =========
*
*   Checking for the Local Field and raising Overrride
*
    WT.OVERRIDE     = MM.OVERRIDE
    VAR.TOT.INT     = R.NEW(MM.TOT.INTEREST.AMT)
    VAR.CHG.AMT     = R.NEW(MM.CHARGE.AMOUNT)
    VAR.TOT.CHG     = R.NEW(MM.TOTAL.CHARGE)
    VAR.TOT.CHG.AMT = VAR.TOT.INT + VAR.CHG.AMT + VAR.TOT.CHG
    VAR.NCF.REQ     = R.NEW(MM.LOCAL.REF)<1,POS.NCF.REQ>
*
    IF VAR.TOT.CHG.AMT GT 0 THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
**********
DC.PROCESS:
*
*   Checking for the Local Field and raising Overrride
*
    WT.OVERRIDE  = DC.DC.OVERRIDE
    VAL.PL.CATEG = R.NEW(DC.DC.PL.CATEGORY)
    VAR.NCF.REQ  = R.NEW(DC.DC.LOCAL.REF)<1,POS.NCF.REQ>
*
    IF VAL.PL.CATEG GT 50000 AND VAL.PL.CATEG LT 52999 THEN
        VAR.TOT.CHG.AMT = R.NEW(DC.DC.AMOUNT.LCY)
    END ELSE
        VAR.TOT.CHG.AMT = ''
    END
    IF VAR.TOT.CHG.AMT NE '' THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
***********
DD.PROCESS:
*
*   Raising override by checking the local Field
*
    WT.OVERRIDE         = DD.DDI.OVERRIDE
    VAR.STATUS          = R.NEW(DD.DDI.STATUS)
*
    VAR.DD.TXN.CODES.ID = 'SYSTEM'

*  CALL F.READ(FN.DD.TXN.CODES,VAR.DD.TXN.CODES.ID,R.DD.TXN.CODES,F.DD.TXN.CODES,TXN.MSG) ;*Tus Start
    CALL CACHE.READ(FN.DD.TXN.CODES,VAR.DD.TXN.CODES.ID,R.DD.TXN.CODES,TXN.MSG) ; * Tus End
*
    BEGIN CASE
        CASE VAR.STATUS EQ 'NEW.ITEM'
            VAR.TXN.ID = R.DD.TXN.CODES<DD.TC.NEW.ITEM.DR>

        CASE VAR.STATUS EQ 'RETURNED.ITEM'
            VAR.TXN.ID = R.DD.TXN.CODES<DD.TC.RETURN.ITEM.DR>

        CASE VAR.STATUS EQ 'RESUBMIT.ITEM'
            VAR.TXN.ID = R.DD.TXN.CODES<DD.TC.RESUBMIT.ITEM.DR>

        CASE VAR.STATUS EQ 'CLAIM.ITEM'
            VAR.TXN.ID = R.DD.TXN.CODES<DD.TC.CLAIM.ITEM.DR>

        CASE VAR.STATUS EQ 'REJECT.ITEM'
            VAR.TXN.ID = R.DD.TXN.CODES<DD.TC.REJECT.ITEM.DR>
    END CASE
*
    CALL CACHE.READ(FN.TRANSACTION, VAR.TXN.ID, R.TRANSACTION, TXN.MSG) ;*R22 Auto code conversion
    VAR.CHG.KEY = R.TRANSACTION<AC.TRA.CHARGE.KEY>
*
    IF VAR.CHG.KEY NE '' THEN
        GOSUB RTN.SUB.PROCESS1
    END ELSE
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
* ===============
RTN.SUB.PROCESS1:
* ===============
*
*   Raising override by checking the local Field
*
    IF VAR.NCF.REQ EQ 'NO' THEN
        CURR.NO = DCOUNT(R.NEW(WT.OVERRIDE),@VM) + 1
        TEXT    = 'REDO.NCF.CHG.REQ'
        CALL STORE.OVERRIDE(CURR.NO)
    END
    ELSE
        Y.FLG.TAX = ""
        Y.FLG.COM = ""
        GOSUB CHK.WAIVE.COMTAX
    END
*
RETURN
*
* ===============
CHK.WAIVE.COMTAX:
* ===============
* Checking whether txn Comm and Tax charges both are waived, override raised
*
    VAR.ARR.CT = ""
    CHANGE @SM TO @FM IN VAR.WV.COM
    LOCATE "NO" IN VAR.WV.COM SETTING POS.1 THEN
        Y.FLG.TAX = 1
    END
*
    CHANGE @SM TO @FM IN VAR.WV.TAX
    LOCATE "NO" IN VAR.WV.TAX SETTING POS.2 THEN
        Y.FLG.COM = 1
    END
*
    IF Y.FLG.COM EQ "" AND Y.FLG.TAX EQ "" THEN
        GOSUB RTN.SUB.PROCESS2
    END
*
RETURN
*
* ===============
RTN.SUB.PROCESS2:
* ===============
*
*   Raising override by checking the local Field
*
    IF VAR.NCF.REQ EQ 'YES' AND (VAR.WV.COM NE "" OR VAR.WV.TAX NE "") THEN
        CURR.NO = DCOUNT(R.NEW(WT.OVERRIDE),@VM) + 1
        TEXT    = 'REDO.NCF.CHG.NOT.REQ'
        CALL STORE.OVERRIDE(CURR.NO)
    END
*
RETURN
*
END
