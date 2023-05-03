* @ValidationCode : MjotMTg0NTg1NjIyMDpDcDEyNTI6MTY4MTM4OTA2NzM3Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:01:07
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
SUBROUTINE REDO.V.INP.CALC.TAX.AMOUNT
*----------------------------------------------------------------------------------------------------------------------
* Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By      : Temenos Application Management
* Program   Name    : REDO.V.INP.CALC.TAX.AMOUNT
*----------------------------------------------------------------------------------------------------------------------
* Description       : Routine to default the local development field values to raise the TAX entries from the INT ACC
* Linked With       : VERSION ROUTINE
* In  Parameter     : N/A
* Out Parameter     : N/A
* Files  Used       : TT
*----------------------------------------------------------------------------------------------------------------------
* Modification Details:
* =====================
* Date         Who                  Reference      Description
* ------       -----                ------------   -------------
* 03-09-2013   Vignesh Kumaar M R   PACS00293638   TELLER ACCOUNTING ISSUE
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_F.TELLER

    IF PGM.VERSION EQ ',REDO.PAYMENT.CHQAPAP' THEN

        WAPP.LST = "TELLER"
        WFLD.LST = 'L.DEBIT.AMOUNT' : @VM : 'L.CREDIT.AMOUNT' : @VM : 'L.TT.TAX.AMT' : @VM : 'L.TT.WV.TAX' : @VM : 'L.TT.TAX.CODE' : @VM : 'L.TT.WV.TAX.AMT' : @VM : 'L.TT.BASE.AMT'
        YPOS = ""
        CALL MULTI.GET.LOC.REF(WAPP.LST,WFLD.LST,YPOS)
        WPOS.DB    = YPOS<1,1>
        WPOS.CR    = YPOS<1,2>
        WPOS.TX    = YPOS<1,3>
        WPOS.TX.FLAG = YPOS<1,4>
        WPOS.TX.CODE = YPOS<1,5>
        WPOS.TX.AMT = YPOS<1,6>
        WPOS.TX.BASE = YPOS<1,7>

        IF OFS$HOT.FIELD EQ 'AMOUNT.LOCAL.1.1' THEN
            R.NEW(TT.TE.LOCAL.REF)<1,WPOS.CR> = COMI
        END ELSE

            R.NEW(TT.TE.LOCAL.REF)<1,WPOS.CR> = R.NEW(TT.TE.NET.AMOUNT)

            IF R.NEW(TT.TE.WAIVE.CHARGES) EQ 'YES' THEN
                R.NEW(TT.TE.WAIVE.CHARGES) = 'NO'
                CALL TT.PERFORM.DEF.PROCESSING
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX> = R.NEW(TT.TE.CHRG.AMT.LOCAL)
*            R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.AMT> = ''
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.FLAG> = 'YES'
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.CODE> = R.NEW(TT.TE.CHARGE.CODE)
                R.NEW(TT.TE.WAIVE.CHARGES) = 'YES'
                GOSUB CLEAR.TT.CHARGES
            END

            IF R.NEW(TT.TE.WAIVE.CHARGES) EQ 'NO' THEN
                CALL TT.PERFORM.DEF.PROCESSING
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX> = R.NEW(TT.TE.CHRG.AMT.LOCAL)
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.FLAG> = 'NO'
                R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.CODE> = R.NEW(TT.TE.CHARGE.CODE)
            END

            R.NEW(TT.TE.LOCAL.REF)<1,WPOS.DB> = R.NEW(TT.TE.NET.AMOUNT)
            R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TX.BASE> = R.NEW(TT.TE.NET.AMOUNT)
        END
    END
RETURN

*----------------------------------------------------------------------------------------------------------------------
CLEAR.TT.CHARGES:
*----------------------------------------------------------------------------------------------------------------------

    DEL R.NEW(TT.TE.CHARGE.CUSTOMER)<1,1>
    DEL R.NEW(TT.TE.CHARGE.ACCOUNT)<1,1>
    DEL R.NEW(TT.TE.CHARGE.CATEGORY)<1,1>
    DEL R.NEW(TT.TE.CHRG.DR.TXN.CDE)<1,1>
    DEL R.NEW(TT.TE.CHRG.CR.TXN.CDE)<1,1>
    DEL R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,1>
    DEL R.NEW(TT.TE.CHRG.AMT.FCCY)<1,1>
    DEL R.NEW(TT.TE.CHARGE.CODE)<1,1>

RETURN
