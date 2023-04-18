* @ValidationCode : MjoxMzE5NDE2NzM5OkNwMTI1MjoxNjgxODE1OTQxMTkzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:35:41
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.UPD.ACCEPTED.STK
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CARD.REQUEST
    $INSERT I_F.REDO.STOCK.ENTRY
    $INSERT I_F.REDO.CARD.SERIES.PARAM
    $INSERT I_REDO.CRD.DMG.LST.COMMON

*----------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.VIRGIN.CARD.RETURN.AUTHORISE
*--------------------------------------------------------------------------------------------------------
*Description  : This is a authorisation routine to update the status of damaged cards in STOCK.REGISTER and
*               REDO.CARD.NUMBERS
*Linked With  : Application REDO.CARD.DAMAGE
*In Parameter : N/A
*Out Parameter: N/A
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
*                  Jeeva
*   16 apr 2011   Balagurunathan                                 issue fix for TDN4 delivery
*--------------------------------------------------------------------------------------------------------


    GOSUB INITIALISE
    GOSUB PROCESS
RETURN

***********
INITIALISE:
***********
    FN.REDO.CARD.REQUEST='F.REDO.CARD.REQUEST'
    F.REDO.CARD.REQUEST=''
    CALL OPF(FN.REDO.CARD.REQUEST,F.REDO.CARD.REQUEST)
    ID.STOCK=R.NEW(STK.BATCH.NO)
    FN.REDO.CARD.SERIES.PARAM='F.REDO.CARD.SERIES.PARAM'


    CALL F.READU(FN.REDO.CARD.REQUEST,ID.STOCK,R.READO.CARD.REQUEST,F.REDO.CARD.REQUEST,ERR,'P')
    CALL CACHE.READ(FN.REDO.CARD.SERIES.PARAM,'SYSTEM',R.REDO.CARD.SERIES.PARAM,ERR.SER)

RETURN

*STK.STOCK.SERIES
*STK.STOCK.QUANTITY
********
PROCESS:
********

    STK.SER=R.NEW(STK.STOCK.SERIES)

    STK.TYPE=''
    STK.VAL=R.NEW(STK.STOCK.QUANTITY)

    STK.SER.CNT=DCOUNT(STK.SER,@VM)


    FOR STK.SER.LOOP=1 TO STK.SER.CNT
*        LOCATE STK.SER<1,STK.SER.LOOP> IN R.REDO.CARD.SERIES.PARAM<REDO.CARD.SERIES.PARAM.CARD.SERIES,1> SETTING SER.POS THEN
*           STK.TYPE= R.REDO.CARD.SERIES.PARAM<REDO.CARD.SERIES.PARAM.CARD.TYPE,SER.POS>
*       END
        STK.TYPE = STK.SER<1,STK.SER.LOOP>

        LOCATE STK.TYPE IN R.READO.CARD.REQUEST<REDO.CARD.REQ.CARD.TYPE,1> SETTING TYP.POS THEN

            R.READO.CARD.REQUEST<REDO.CARD.REQ.REGOFF.ACCEPTQTY,TYP.POS>= R.READO.CARD.REQUEST<REDO.CARD.REQ.REGOFF.ACCEPTQTY,TYP.POS> + STK.VAL<1,STK.SER.LOOP>

        END
        STK.TYPE=''

    NEXT

    CALL F.WRITE(FN.REDO.CARD.REQUEST,ID.STOCK,R.READO.CARD.REQUEST)


RETURN
END
