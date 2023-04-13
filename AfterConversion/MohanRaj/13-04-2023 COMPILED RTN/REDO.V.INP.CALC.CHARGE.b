* @ValidationCode : Mjo5NzEwOTMxODg6Q3AxMjUyOjE2ODEzODg5ODM5Njk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:59:43
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
SUBROUTINE REDO.V.INP.CALC.CHARGE

*--------------------------------------------------------------------------------
*Company   Name    : Asociacion Popular de Ahorros y Prestamos
*Developed By      : GANESH.R
*Program   Name    : REDO.V.INP.CALC.CHARGE
*Reference         : ODR-2009-10-0424
*HD Issue No       : HD1037932
*---------------------------------------------------------------------------------

*DESCRIPTION       :THIS PROGRAM IS USED TO CALCULATE COMMISSION CHARGES FOR
*                   CUSTOMER DURING CLOSE OF ACCOUNT
*Modification on 20 Jan 2011 : Reduced the Code Rating
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,SM TO @SM,FM TO @FM,F.READ TO CACHE.READ,CONVERT TO CHANGE,= TO EQ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLOSURE
    $INSERT I_F.FT.COMMISSION.TYPE

    IF MESSAGE EQ '' THEN
        GOSUB INIT
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END
RETURN

*------------------------------------------------------------------------------
*DESCRIPTION : Initialising the variables
*------------------------------------------------------------------------------
INIT:

    VAL=''
    FT4.L.FT4.LRF.CCY=''
    ACL.CLO.CHARGE.AMT=''
    FT4.LRF.CCY=''
    ACL.CURRENCY=''

    LOC.REF.APPLICATION="FT.COMMISSION.TYPE":@FM:"ACCOUNT.CLOSURE"
    LOC.REF.FIELDS='L.FT4.LRF.CCY':@VM:'L.FT4.MIN.PER':@VM:'L.FT4.CLO.CHG':@FM:'L.ACL.WAIVE.CHG'
    LOC.REF.POS=''

RETURN

*------------------------------------------------------------------------------
*DESCRIPTION: Opening the files ACCOUNT, FT.COMMISSION.TYPE and ACCOUNT.CLOSURE
*------------------------------------------------------------------------------
OPEN.FILES:

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.FT.COMMISSION.TYPE='F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE=''
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)

    FN.ACCOUNT.CLOSURE='F.ACCOUNT.CLOSURE'
    F.ACCOUNT.CLOSURE=''
    CALL OPF(FN.ACCOUNT.CLOSURE,F.ACCOUNT.CLOSURE)
RETURN

*--------------------------------------------------------------------------------
*DESCRIPTION:Getting the position of the local fields from FT.COMMISSION
*             ACCOUNT.CLOSURE applications
*--------------------------------------------------------------------------------
PROCESS:
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    LOC.LRF.CCY=LOC.REF.POS<1,1>
    LOC.MIN.HOLD.PERIOD=LOC.REF.POS<1,2>
    LOC.EARLY.CLOSE.CHARGE=LOC.REF.POS<1,3>
    LOC.WAIVE.CHARGES=LOC.REF.POS<2,1>

*---------------------------------------------------------------------------------
*DESCRIPTION:Calculation of Charges
*---------------------------------------------------------------------------------

    ACCOUNT.ID=ID.NEW
    WAIVE.CHG=R.NEW(AC.ACL.LOCAL.REF)<1,LOC.WAIVE.CHARGES>
    ACCT.CLO.CURRENCY=R.NEW(AC.ACL.CURRENCY)

*Check for Waiver

    IF WAIVE.CHG EQ 'Y' THEN
        R.NEW(AC.ACL.CLO.CHARGE.AMT)=0
        CURR.NO = DCOUNT(R.NEW(AC.ACL.OVERRIDE),@VM) + 1
        TEXT='AC.CLOSE.WAIVE.CHGS'
        CALL STORE.OVERRIDE(CURR.NO)
    END

    IF WAIVE.CHG EQ '' THEN
        R.ACCOUNT =''
        CALL F.READ(FN.ACCOUNT,ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR)
        START.DATE=R.ACCOUNT<AC.OPENING.DATE>
        END.DATE = TODAY
        NO.OF.MONTHS = ''
        CALL EB.NO.OF.MONTHS(START.DATE,END.DATE,NO.OF.MONTHS)

        FTID=R.NEW(AC.ACL.CLO.CHARGE.TYPE)
        R.FT.COMMISSION.TYPE=''

        CALL CACHE.READ(FN.FT.COMMISSION.TYPE, FTID, R.FT.COMMISSION.TYPE, ERR) ;*R22 Auto code conversion

        LOC.CURR=R.FT.COMMISSION.TYPE<FT4.LOCAL.REF><1,LOC.LRF.CCY>

        CHANGE @SM TO @FM IN LOC.CURR ;*R22 Auto code conversion

        LOCATE ACCT.CLO.CURRENCY IN LOC.CURR<1> SETTING POS THEN
            GOSUB CALC.CHARGE
        END
    END
RETURN

**************
CALC.CHARGE:
**************
*Applying Charges

    CLOSE.CHG=R.FT.COMMISSION.TYPE<FT4.LOCAL.REF><1,LOC.EARLY.CLOSE.CHARGE,POS>
    MINIMUM.HOLD=R.FT.COMMISSION.TYPE<FT4.LOCAL.REF><1,LOC.MIN.HOLD.PERIOD,POS>
    IF MINIMUM.HOLD[1] EQ 'Y' THEN
        VAL=FIELD(MINIMUM.HOLD,'Y',1)
        MIN.HOLD.VALUE=VAL * 12
    END
    ELSE
        IF MINIMUM.HOLD[1] EQ 'M' THEN
            VAL=FIELD(MINIMUM.HOLD,'M',1)
            MIN.HOLD.VALUE=VAL
        END
    END

    IF NO.OF.MONTHS LT MIN.HOLD.VALUE  THEN
        R.NEW(AC.ACL.CLO.CHARGE.AMT)=CLOSE.CHG
        CURR.NO = DCOUNT(R.NEW(AC.ACL.OVERRIDE),@VM) + 1
        TEXT='AC.CLOSE.CHG.AMT'
        CALL STORE.OVERRIDE(CURR.NO)
    END

RETURN
END
