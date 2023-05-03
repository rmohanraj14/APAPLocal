* @ValidationCode : MjotNjAzMjQ3MzQ3OkNwMTI1MjoxNjgxODg4OTI1NjA4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:52:05
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
SUBROUTINE REDO.V.VAL.DEF.CCY
*-----------------------------------------------------------------------------
* Developer   : VIGNESH A S
* Date        : 17.05.2010
* Description : VALIDATION ROUTINE FOR VERSIONS AS FOLLOWS - HOT FIELDS
* TELLER                  : CHQ.OTHERS, CHQ.NO.TAX, CHQ.TAX,
*                           MGR.CHQ.TAX, MGR.CHQ.NOTAX
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
* Date          Name             Reference                      Description
* -------       ----             ---------                      ------------
* 17-05-2010  VIGNESH A.S        ODR-2010-03-0447              Initial creation
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,F.READ TO CACHE.READ
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER

    GOSUB INITIALIZE
    GOSUB PROCESS
RETURN

***********
INITIALIZE:
***********
* Initialization of necessary variables is done in this section of code

    FN.FT.COMMISSION.TYPE='F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE=''
    R.FT.COMMISSION.TYPE=''
    FT.COMMISSION.TYPE.ERR=''

    FN.FT.CHARGE.TYPE='F.FT.CHARGE.TYPE'
    F.FT.CHARGE.TYPE=''
    R.FT.CHARGE.TYPE=''
    FT.CHARGE.TYPE.ERR=''

    FN.TAX='F.TAX'
    F.TAX=''
    R.TAX=''
    TAX.ERR=''

    Y.CHRG.AMT.LOOP="1"; Y.TOT.TAX="0"; Y.TOT.CHARGE="0"; Y.CHARGE.CODE=""; Y.CHRG.AMT.COUNT=""

    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
    CALL OPF(FN.FT.CHARGE.TYPE,F.FT.CHARGE.TYPE)
    CALL OPF(FN.TAX,F.TAX)

RETURN

********
PROCESS:
********


* Selection: To sum up with charge of tax

    Y.CHRG.AMT.LOCAL.LIST=R.NEW(TT.TE.CHRG.AMT.LOCAL)

    Y.CHRG.AMT.COUNT=DCOUNT(Y.CHRG.AMT.LOCAL.LIST,@VM)

    LOOP
    UNTIL Y.CHRG.AMT.LOOP GT Y.CHRG.AMT.COUNT

        Y.CHARGE.CODE=R.NEW(TT.TE.CHARGE.CODE)<1,Y.CHRG.AMT.LOOP>

        CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.CHARGE.CODE, R.FT.COMMISSION.TYPE, FT.COMMISSION.TYPE.ERR) ;*R22 Auto code conversion
        IF R.FT.COMMISSION.TYPE THEN
            GOSUB TOT.CHARGE
        END

        CALL CACHE.READ(FN.FT.CHARGE.TYPE, Y.CHARGE.CODE, R.FT.CHARGE.TYPE, FT.CHARGE.TYPE.ERR) ;*R22 Auto code conversion
        IF R.FT.CHARGE.TYPE THEN
            GOSUB TOT.CHARGE
        END

        CALL CACHE.READ(FN.TAX, Y.CHARGE.CODE, R.TAX, TAX.ERR) ;*R22 Auto code conversion
        IF R.TAX THEN
            GOSUB TOT.TAX
        END
        Y.CHRG.AMT.LOOP+=1
    REPEAT
    GOSUB TOTAL.SUM
RETURN

***********
TOT.CHARGE:
***********
* Sum of all the charges
    IF R.NEW(TT.TE.CURRENCY.1) EQ LCCY THEN
        Y.TOT.CHARGE=Y.TOT.CHARGE+R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,Y.CHRG.AMT.LOOP>
    END ELSE
        Y.TOT.CHARGE=Y.TOT.CHARGE+R.NEW(TT.TE.CHRG.AMT.FCCY)<1,Y.CHRG.AMT.LOOP>
    END
RETURN

********
TOT.TAX:
********
* Sum of all the taxes
    IF R.NEW(TT.TE.CURRENCY.1) EQ LCCY THEN
        Y.TOT.TAX=Y.TOT.TAX+R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,Y.CHRG.AMT.LOOP>
    END ELSE
        Y.TOT.TAX=Y.TOT.TAX+R.NEW(TT.TE.CHRG.AMT.FCCY)<1,Y.CHRG.AMT.LOOP>
    END
RETURN

***********
TOTAL.SUM:
***********
* Total all the tax, charge, Amount.1 and assign it to Amount.1 --- May be LCY or FCY
    IF R.NEW(TT.TE.CURRENCY.1) EQ LCCY THEN
        Y.AMT.LOCAL.1=R.NEW(TT.TE.AMOUNT.LOCAL.1)
        R.NEW(TT.TE.AMOUNT.LOCAL.1)=Y.TOT.TAX+Y.TOT.CHARGE+Y.AMT.LOCAL.1
    END ELSE
        Y.AMT.FCY.1=R.NEW(TT.TE.AMOUNT.FCY.1)
        R.NEW(TT.TE.AMOUNT.FCY.1)=Y.TOT.TAX+Y.TOT.CHARGE+Y.AMT.FCY.1
    END
RETURN

END
