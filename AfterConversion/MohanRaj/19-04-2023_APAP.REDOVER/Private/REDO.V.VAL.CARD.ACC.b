* @ValidationCode : MjotMjAyMTgxNzc5OkNwMTI1MjoxNjgxODkyNzMwNzQxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:55:30
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
SUBROUTINE REDO.V.VAL.CARD.ACC
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.VAL.CREDIT
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is attached as authorization routine in all the version used
*                  in the development N.83.It will fetch the value from sunnel interface
*                  and assigns it in R.NEW
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 16-APR-2010        Prabhu.N       ODR-2009-10-0536    Initial Creation
* 03-DEC-2010        Prabhu.N       ODR-2010-11-0211    Modified based on Sunnel
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     IF CONDITION ADDED
*19-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    IF VAL.TEXT EQ '' THEN
        IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
            Y.ARRAY='BUSCAR_TARJETA_CUENTA.FT'
        END
        CALL APAP.REDOVER.REDO.V.WRAP.SUNNEL(Y.ARRAY) ;*R22 Manual Code Conversion-Call Method Format Modified
        COMI=COMI[1,4]:'********':COMI[13,4]
        Y.CARD.CLIENT=Y.ARRAY<15>
        CUSTOMER.ID = System.getVariable('EXT.SMS.CUSTOMERS')
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
            CUSTOMER.ID = ""
        END ;*R22 Auto code conversion-END
        IF CUSTOMER.ID NE Y.CARD.CLIENT THEN
            ETEXT="EB-INVALID.CARD"
            CALL STORE.END.ERROR
        END
    END
RETURN
END
