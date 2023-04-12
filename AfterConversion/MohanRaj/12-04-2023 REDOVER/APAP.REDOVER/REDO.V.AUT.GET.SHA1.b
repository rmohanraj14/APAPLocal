* @ValidationCode : MjotODM1NzYzMzY0OkNwMTI1MjoxNjgxMjg2MDE4MTM3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:23:38
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
SUBROUTINE REDO.V.AUT.GET.SHA1
*******************************************************************************************************************

*Company   Name    : Asociacion Popular De Ahorros Y Pristamos Bank
*Developed By      : Temenos Application Management
*Program   Name    : REDO.V.AUT.GET.SHA1
*------------------------------------------------------------------------------------------------------------------

*Description       : Fetch the NAME FROM customer application if it is not exit then fetch short name,
*ID_CARD from local reference variable L.CU.CIDENT,INSTRUMENT from ID of AZ.ACCOUNT
*And form string as NAME: ID_CARD: INSTRUMENT Pass it as a parameter to  CALLJ function
*Store the return value in SHA1.CODE.  Make SHA1.CODE as id and store the Account id in REDO.T.SHA1 template

*Linked With       : AZ,REDO as AUTH.ROUTINE
*In  Parameter     : -N/A-
*Out Parameter     : -N/A-
*------------------------------------------------------------------------------------------------------------------

*Modification Details:
*=====================
*07/03/2011 - ODR-2009-10-0425 - PACS00032523 - SUDHARSANAN S - Based on customer type the input name parameter is updated
*24/05/2011 - ODR-2009-10-0425 - PACS00054327 - SUDHARSANAN S - Based on customer type the CARD ID value is updated
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM, VM TO @VM, S TO S.VAR
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.T.SHA1


    GOSUB INITIALISE
    GOSUB OPEN
    GOSUB PROCESS
RETURN
*------------
INITIALISE:
*------------
    NAME=''
    ID_CARD=0
    INSTRUMENT=''
    S.VAR='' ;*R22 Auto code conversion
    CUS.ID=''
    JAVAERROR=''

    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER=''
    R.CUSTOMER=''
    CUS.ERR1=''
    FLAG.ID = '' ; CIDENT.VALUE = '' ; LEGALID.VALUE = '' ; ACTANAC.VALUE = '' ;  NOUNICO.VALUE = ''
    param = ""
    ret = ""
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''

    FN.REDO.T.SHA1 = 'F.REDO.T.SHA1'
    F.REDO.T.SHA1 = ''
    FN.AZ.ACCOUNT='F.AZ.ACCOUNT'
    F.AZ.ACCOUNT=''

RETURN

**********************************************
OPEN:
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.REDO.T.SHA1,F.REDO.T.SHA1)
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)
RETURN
**************************************************

PROCESS:

    LREF.APPL = 'CUSTOMER':@FM:'AZ.ACCOUNT'
*PACS00032523 - S
    LREF.FIELDS = 'L.CU.CIDENT':@VM:'L.CU.TIPO.CL':@VM:'L.CU.RNC':@VM:'L.CU.ACTANAC':@VM:'L.CU.NOUNICO':@FM:'L.AZ.SHA1.CODE'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APPL,LREF.FIELDS,LREF.POS)
    CIDENT.POS = LREF.POS<1,1>
    TIPO.CL.POS = LREF.POS<1,2>
    RNC.POS = LREF.POS<1,3>
    ACTANAC.POS = LREF.POS<1,4>
    NOUNICO.POS = LREF.POS<1,5>
    SHA1.POS =LREF.POS<2,1>

    ACC.ID=ID.NEW
    CALL F.READ(FN.ACCOUNT,ACC.ID,R.ACC,F.ACCOUNT,ACC.ERR)
    IF R.ACC THEN
        CUS.ID = R.ACC<AC.CUSTOMER>
    END
    CALL F.READ(FN.CUSTOMER,CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR1)
    IF R.CUSTOMER THEN
        VAR.TIPO.CL = R.CUSTOMER<EB.CUS.LOCAL.REF,TIPO.CL.POS>
*PACS00054327 - S
        BEGIN CASE
            CASE VAR.TIPO.CL EQ 'PERSONA FISICA'
                GOSUB FIS.TYPE
            CASE VAR.TIPO.CL EQ 'PERSONA JURIDICA'
                GOSUB JUR.TYPE
            CASE OTHERWISE
                GOSUB OTHER.TYPE
        END CASE
    END

    SHA1.CODE = R.NEW(AZ.LOCAL.REF)<1,SHA1.POS>

    IF SHA1.CODE THEN
        RETURN
    END

*PACS00054327 - E
*PACS00032523 - E
    INSTRUMENT = ID.NEW
    S.VAR = NAME:ID_CARD:INSTRUMENT ;*R22 Auto code conversion
    param = S.VAR ;*R22 Auto code conversion
    CALLJ "Logic.Hash","SHA1", param SETTING ret ON ERROR
        E= 'Unable to call JAVA PGM'
    END
    SHA1.CODE=ret
    R.NEW(AZ.LOCAL.REF)<1,SHA1.POS>=SHA1.CODE
    CALL F.READ(FN.REDO.T.SHA1,SHA1.CODE,R.SHA1.CODE,F.REDO.T.SHA1,SHA1.ERR)
    IF SHA1.ERR THEN
        R.SHA1.CODE<RE.T.SH.AZ.ACCOUNT.NO> =ACC.ID  ;* Tus S/E
    END
    CALL F.WRITE(FN.REDO.T.SHA1,SHA1.CODE,R.SHA1.CODE)
RETURN
*PACS00054327 - S
*------------------------------------------------------------------------------------------
FIS.TYPE:
*------------------------------------------------------------------------------------------
    VAR.GIV.NAM  =  R.CUSTOMER<EB.CUS.GIVEN.NAMES>
    VAR.FAM.NAM = R.CUSTOMER<EB.CUS.FAMILY.NAME>
    NAME = VAR.GIV.NAM:" ":VAR.FAM.NAM
    CIDENT.VALUE = R.CUSTOMER<EB.CUS.LOCAL.REF,CIDENT.POS>
    IF CIDENT.VALUE THEN
        ID_CARD = CIDENT.VALUE
    END ELSE
        ID_CARD = R.CUSTOMER<EB.CUS.LEGAL.ID,1>
    END
RETURN
*------------------------------------------------------------------------------------------
JUR.TYPE:
*------------------------------------------------------------------------------------------
    VAR.NAME1=R.CUSTOMER<EB.CUS.NAME.1>
    VAR.NAME2=R.CUSTOMER<EB.CUS.NAME.2>
    NAME = VAR.NAME1:VAR.NAME2
    ID_CARD = R.CUSTOMER<EB.CUS.LOCAL.REF,RNC.POS>
RETURN
*------------------------------------------------------------------------------------------
OTHER.TYPE:
*------------------------------------------------------------------------------------------
    VAR.GIV.NAM  =  R.CUSTOMER<EB.CUS.GIVEN.NAMES>
    VAR.FAM.NAM = R.CUSTOMER<EB.CUS.FAMILY.NAME>
    NAME = VAR.GIV.NAM:" ":VAR.FAM.NAM
    CIDENT.VALUE  =  R.CUSTOMER<EB.CUS.LOCAL.REF,CIDENT.POS>
    IF CIDENT.VALUE THEN
        ID_CARD = CIDENT.VALUE
        FLAG.ID = 1
    END
    IF NOT(FLAG.ID) THEN
        LEGALID.VALUE = R.CUSTOMER<EB.CUS.LEGAL.ID,1>
        IF LEGALID.VALUE THEN
            ID_CARD = LEGALID.VALUE
            FLAG.ID = 1
        END
    END
    IF NOT(FLAG.ID) THEN
        ACTANAC.VALUE = R.CUSTOMER<EB.CUS.LOCAL.REF,ACTANAC.POS>
        IF ACTANAC.VALUE THEN
            ID_CARD = ACTANAC.VALUE
            FLAG.ID = 1
        END
    END
    IF NOT(FLAG.ID) THEN
        NOUNICO.VALUE = R.CUSTOMER<EB.CUS.LOCAL.REF,NOUNICO.POS>
        IF NOUNICO.VALUE THEN
            ID_CARD = NOUNICO.VALUE
            FLAG.ID = 1
        END
    END
RETURN
*PACS00054327 - E
*------------------------------------------------------------------------------------------
END
