* @ValidationCode : MjoxNjkyMDQzMTI5OkNwMTI1MjoxNjgxMzAwMTg4NTkxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:19:48
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
SUBROUTINE REDO.V.AUT.RENEW.CARDS
*------------------------------------------------------------------------------
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: S KAVITHA
* PROGRAM NAME: REDO.V.AUT.RENEW.CARDS
* ODR NO      : ODR-2010-03-0400
*----------------------------------------------------------------------
* DESCRIPTION: Renewal card authorisation.
* IN PARAMETER: NONE
* OUT PARAMETER: NONE
* LINKED WITH: LATAM.CARD.ORDER,REDO.PRINCIPAL , LATAM.CARD.ORDER,REDO.ADDITIONAL,
*
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*09.08.2011   S KAVITHA     ODR-2010-03-0400    INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LATAM.CARD.ORDER
    $INSERT I_F.REDO.STOCK.REGISTER
    $INSERT I_F.REDO.CARD.SERIES.PARAM
*   $INSERT I_F.REDO.STOCK.REGISTER



    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*********
OPEN.FILES:

    FN.STOCK.REG = 'F.REDO.STOCK.REGISTER'
    F.STOCK.REG = ''
    CALL OPF(FN.STOCK.REG,F.STOCK.REG)

    FN.REDO.CARD.SERIES.PARAM = 'F.REDO.CARD.SERIES.PARAM'
    F.REDO.CARD.SERIES.PARAM = ''
    CALL OPF(FN.REDO.CARD.SERIES.PARAM,F.REDO.CARD.SERIES.PARAM)

RETURN
*--------------------
PROCESS:

    Y.ID.CARD.SERIES = 'SYSTEM'

    CALL CACHE.READ('F.REDO.CARD.SERIES.PARAM',Y.ID.CARD.SERIES,R.REDO.CARD.SERIES.PARAM,PARAM.ERR)
    RECD.DEPT.CODE = R.REDO.CARD.SERIES.PARAM<REDO.CARD.SERIES.PARAM.RECEIVE.DEPT.CODE>
    CARD.TYPE.LIST = R.REDO.CARD.SERIES.PARAM<REDO.CARD.SERIES.PARAM.CARD.TYPE>
    CARD.SERIES.LIST = R.REDO.CARD.SERIES.PARAM<REDO.CARD.SERIES.PARAM.CARD.SERIES>

    GET.ID.CARD.TYPE = FIELD(ID.NEW,'.',1)

    CHANGE @VM TO @FM IN CARD.TYPE.LIST
    CHANGE @VM TO @FM IN CARD.SERIES.LIST

    LOCATE GET.ID.CARD.TYPE IN CARD.TYPE.LIST SETTING PARAM.POS THEN
        Y.SERIES.ID = CARD.SERIES.LIST<PARAM.POS>
    END


    CO.CODE = R.NEW(CARD.IS.CO.CODE)
    GET.RENEW.STATUS = R.NEW(CARD.IS.RENEW.STATUS)

    R.STOCK.REGISTER   =''
    STOCK.REGISTER.ERR = ''
    Y.STOCK.REGISTER.ID = 'CARD.':CO.CODE:"-":RECD.DEPT.CODE
    CALL F.READU(FN.STOCK.REG,Y.STOCK.REGISTER.ID,R.STOCK.REGISTER,F.STOCK.REG,STOCK.REGISTER.ERR,"")

    STOCK.SERIES.ID = R.STOCK.REGISTER<STK.REG.SERIES.ID>
    CHANGE @VM TO @FM IN STOCK.SERIES.ID

    LOCATE Y.SERIES.ID IN STOCK.SERIES.ID SETTING Y.SERIES.ID.POS THEN
        R.STOCK.REGISTER<STK.REG.SERIES.BAL,Y.SERIES.ID.POS> = R.STOCK.REGISTER<STK.REG.SERIES.BAL,Y.SERIES.ID.POS> - 1
        R.STOCK.REGISTER<STK.REG.STO.REG.BAL> = R.STOCK.REGISTER<STK.REG.STO.REG.BAL> - 1
    END

* PACS00755208 - S
    IF R.STOCK.REGISTER<STK.REG.SERIES.BAL,Y.SERIES.ID.POS> LT '0' THEN
        R.STOCK.REGISTER<STK.REG.SERIES.BAL,Y.SERIES.ID.POS> = '0'
    END
* PACS00755208 - E


    CALL F.WRITE(FN.STOCK.REG,Y.STOCK.REGISTER.ID,R.STOCK.REGISTER)

    IF R.NEW(CARD.IS.RENEW.STATUS) EQ 94 THEN
        R.NEW(CARD.IS.RENEW.STATUS) = ''
        R.NEW(CARD.IS.ISSUE.DATE) = ''
        R.NEW(CARD.IS.EXPIRY.DATE) = ''
        R.NEW(CARD.IS.RENEW.REQ.ID) = ''

    END

RETURN
*-----------------------------------------------------------------------
END
