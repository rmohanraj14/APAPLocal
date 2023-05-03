* @ValidationCode : MjoyMDgwNjQ1MzIxOkNwMTI1MjoxNjgxODg4MTk1NDc5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:39:55
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
SUBROUTINE REDO.V.VAL.CUST.ID
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used to get the value of customer id based on identification entered to various id's such as RNC,CEDULA.
*------------------------------------------------------------------------------------------
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
* 16-02-2011        Prabhu.N         B.88-HD1040884      Initial Creation
* 15-08-2011        Prabhu N         PACS00103352        eb.lookup modification
* 19-04-2012        Pradeep S        PACS00190839        Fix data migration issue
* 16-07-2018       Gopala Krishnan R PACS00686394        Even customer is not an APAP customer customer name should save.
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.APAP.H.GARNISH.DETAILS
    $INSERT I_GTS.COMMON


    GOSUB OPENFILE
    GOSUB PROCESS
RETURN
*--------
OPENFILE:
*--------
    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER=''
    CUS.ID=''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

*PACS00190839 - S
    FN.CUS.L.CU.RNC = 'F.CUSTOMER.L.CU.RNC'
    F.CUS.L.CU.RNC  = ''
    CALL OPF(FN.CUS.L.CU.RNC,F.CUS.L.CU.RNC)

    FN.CUS.L.CU.CIDENT = 'F.CUSTOMER.L.CU.CIDENT'
    F.CUS.L.CU.CIDENT  = ''
    CALL OPF(FN.CUS.L.CU.CIDENT,F.CUS.L.CU.CIDENT)

    FN.CUS.LEGAL.ID = 'F.REDO.CUSTOMER.LEGAL.ID'
    F.CUS.LEGAL.ID  = ''
    CALL OPF(FN.CUS.LEGAL.ID,F.CUS.LEGAL.ID)
*PACS00190839 - E

RETURN
*---------
PROCESS:
*---------
    ID.TYPE=R.NEW(APAP.GAR.IDENTITY.TYPE)
    SEL.VAL=COMI

*PACS00190839 - S
    BEGIN CASE

        CASE ID.TYPE EQ 'ID.CARD'
            R.CUS.CIDENT = ''
            CALL F.READ(FN.CUS.L.CU.CIDENT,COMI,R.CUS.CIDENT,FN.CUS.L.CU.CIDENT,CID.ERR)
            CUS.ID = FIELD(R.CUS.CIDENT,"*",2)
            GOSUB READ.CUS

        CASE ID.TYPE EQ 'PASSPORT'
            R.CUS.LEGAL = ''
            CALL F.READ(FN.CUS.LEGAL.ID,COMI,R.CUS.LEGAL,F.CUS.LEGAL.ID,LEGAL.ERR)
            CUS.ID = FIELD(R.CUS.LEGAL,"*",2)
            GOSUB READ.CUS

        CASE ID.TYPE EQ 'RNC'
            R.CUS.RNC = ''
            CALL F.READ(FN.CUS.L.CU.RNC,COMI,R.CUS.RNC,F.CUS.L.CU.RNC,RNC.ERR)
            CUS.ID = FIELD(R.CUS.RNC,"*",2)
            GOSUB READ.CUS
    END CASE

*PACS00190839 - E
RETURN

*---------
READ.CUS:
*---------
    R.CUSTOMER = ''
    R.NEW(APAP.GAR.CUSTOMER) = CUS.ID
    CALL F.READ(FN.CUSTOMER,CUS.ID,R.CUSTOMER,F.CUSTOMER,ERR)
*PACS00686394 - S
    IF R.CUSTOMER THEN
        R.NEW(APAP.GAR.INDIVIDUAL.NAME) = R.CUSTOMER<EB.CUS.NAME.1>
    END
*PACS00686394 - E
RETURN

END
