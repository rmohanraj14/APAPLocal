* @ValidationCode : MjoxMjQzMTE0NTQ5OkNwMTI1MjoxNjgxNzI4NDYyMTIxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:17:42
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
SUBROUTINE REDO.V.INP.DISBURSE.OTI
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is an INPUT routine attached to below versions,
*

* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description*
* 21-07-2011         Bharath G        PACS00085750       Local Fields included in the version.
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,F.READ TO CACHE.READ
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*------------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COMPANY

    GOSUB INIT
    GOSUB PROCESS
RETURN

******
INIT:
******
*Initialize all the variables

    FN.CUSTOMER = 'F.CUSTOMER'
    FN.CMPNY    = 'F.COMPANY'
    F.CUSTOMER = ''
    F.CMPNY    = ''
    CALL OPF(FN.CUSTOMER ,F.CUSTOMER)
    CALL OPF(FN.CMPNY ,F.CMPNY)

RETURN
***********
PROCESS:
***********
* PACS00085750 - S
    LREF.APP = 'FUNDS.TRANSFER'
    LREF.FIELDS = 'L.FT.CLIENT.COD':@VM:'L.FT.CLIENT.NME':@VM:'L.FT.CMPNY.ID':@VM:'L.FT.CMPNY.NAME'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    VAR.L.FT.CLIENT.COD.POS = LREF.POS<1,1>
    VAR.L.FT.CLIENT.NME.POS = LREF.POS<1,2>
    VAR.L.FT.CMPNY.ID.POS   = LREF.POS<1,3>
    VAR.L.FT.CMPNY.NAME.POS = LREF.POS<1,4>
*PACS00085750 - E

    Y.CUS.NO      =   R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CLIENT.COD.POS>
    Y.CMPNY.ID     =   R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CMPNY.ID.POS>

    CALL F.READ(FN.CUSTOMER,Y.CUS.NO,R.CUSTOMER,F.CUSTOMER,Y.CUS.ERR)
    CALL CACHE.READ(FN.CMPNY, Y.CMPNY.ID, R.CMPNY, Y.CMPNY.ERR) ;*R22 Auto code conversion
    IF R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CLIENT.NME.POS> EQ '' THEN
        R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CLIENT.NME.POS> = R.CUSTOMER<EB.CUS.SHORT.NAME>
    END
    IF R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CMPNY.NAME.POS> EQ '' THEN
        R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CMPNY.NAME.POS> = R.CMPNY<EB.COM.COMPANY.NAME>
    END

RETURN
******************************************************************************************************
END
