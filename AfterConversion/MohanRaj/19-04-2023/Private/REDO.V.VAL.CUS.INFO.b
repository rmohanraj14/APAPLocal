* @ValidationCode : MjoxMzU4NjI1NjYzOkNwMTI1MjoxNjgxODg4MDc3MzkwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:37:57
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
SUBROUTINE REDO.V.VAL.CUS.INFO
*--------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This Routine will return customer details for REDO.L.NCF.ISSUE table
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
*   Date               who           Reference            Description
* 25-MAR-2010       Prabhu.N       ODR-2009-10-0321    Initial Creation
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------
    $INSERT I_F.CUSTOMER
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.L.NCF.ISSUE

    GOSUB INIT
    GOSUB PROCESS
RETURN
*----
INIT:
*----
    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER =''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    LREF.APP='CUSTOMER'
    LREF.FIELDS='L.CU.CIDENT':@VM:'L.CU.RNC':@VM:'L.CU.ACTANAC':@VM:'L.CU.NOUNICO'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
RETURN
*-------
PROCESS:
*-------

    VAR.CUSTOMER.ID=COMI
    CALL F.READ(FN.CUSTOMER,VAR.CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,ERR)
    VAR.CEDULA=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LREF.POS<1,2>>
    R.NEW(NCF.IS.CEDULE.ID)=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LREF.POS<1,1>>
    R.NEW(NCF.IS.RNC.NUMBER)=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LREF.POS<1,2>>
    R.NEW(NCF.IS.IDENDITY.TYPE)=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LREF.POS<1,3>>
    R.NEW(NCF.IS.UNIQUE.ID.NUM)=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LREF.POS<1,4>>
    R.NEW(NCF.IS.PASSPORT)=R.CUSTOMER<EB.CUS.LEGAL.ID>
RETURN
END
