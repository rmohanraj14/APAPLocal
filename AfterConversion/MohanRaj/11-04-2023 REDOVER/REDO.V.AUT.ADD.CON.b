* @ValidationCode : MjotNDA0NjcyNzQzOkNwMTI1MjoxNjgxMjE3MjM0MDM3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:17:14
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
SUBROUTINE REDO.V.AUT.ADD.CON
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.AUT.ADD.CON
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is attached as authorization routine in all the version used
*                  in the development N.83.It will fetch the value from sunnel interface
*                  and assigns it in R.NEW
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 28-Dec-2010        Prabhu.N       ODR-2010-08-0031   Initial Creation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     IF Condition Added
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ADD.THIRDPARTY
    $INSERT I_System

    GOSUB OPEN.PARA
    GOSUB PROCESS.PARA

RETURN
*---------
OPEN.PARA:
*---------
    FN.CUS.CON.LIST = 'F.CUS.CON.LIST'
    F.CUS.CON.LIST  = ''
    CALL OPF(FN.CUS.CON.LIST,F.CUS.CON.LIST)

RETURN

*------------
PROCESS.PARA:
*------------
    CUSTOMER.ID = System.getVariable('EXT.SMS.CUSTOMERS')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        CUSTOMER.ID = ""
    END ;*R22 Auto code conversion-END
    GOSUB CHECK.EXISTING.CON

RETURN
*------------------
CHECK.EXISTING.CON:
*------------------
    CUS.CON.LIST.ID = CUSTOMER.ID
    CALL F.READ(FN.CUS.CON.LIST,CUS.CON.LIST.ID,R.CUS.CON.LIST,F.CUS.CON.LIST,CUS.CON.LIST.ER)
    R.CUS.CON.LIST<-1> = ID.NEW:'*':R.NEW(ARC.TP.CONTRACT.NO)

    CALL F.WRITE(FN.CUS.CON.LIST,CUS.CON.LIST.ID,R.CUS.CON.LIST)

RETURN
END
*---------------------------------------------*END OF SUBROUTINE*-------------------------------------------
