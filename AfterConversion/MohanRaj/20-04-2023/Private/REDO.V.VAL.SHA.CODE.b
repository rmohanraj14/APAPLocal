* @ValidationCode : MjotNDY5OTYxMzIxOkNwMTI1MjoxNjgxOTc0ODYyNDk1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:44:22
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
SUBROUTINE REDO.V.VAL.SHA.CODE
*-----------------------------------------------------------------------------
*Company   Name    : Asociacion Popular De Ahorros Y Pristamos Bank
*Developed By      : SUJITHA.S
*Program   Name    : REDO.V.VAL.SHA.CODE
*------------------------------------------------------------------------------------------------------------------

*Description       : Fetch the NAME FROM customer application if it is not exit then fetch short name,
*ID_CARD from local reference variable L.CU.CIDENT,INSTRUMENT from ID of AZ.ACCOUNT
*And form string as NAME: ID_CARD: INSTRUMENT Pass it as a parameter to  CALLJ function
*Store the return value in SHA1.CODE.  Make SHA1.CODE as id and store the Account id in REDO.T.SHA1 template


*Linked With       : AZ.ACCOUNT,RE as validation routine
*In  Parameter     : -N/A-
*Out Parameter     : -N/A-
*------------------------------------------------------------------------------------------------------------------

*Modification Details:
*=====================
*07/07/2010 - ODR-2009-10-0332
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------


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

*---------------------------------------------------------------------------
INITIALISE:
*---------------------------------------------------------------------------

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
    REF.POS=0
    param = ""
    ret = ""
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''

    FN.REDO.T.SHA1 = 'F.REDO.T.SHA1'
    F.REDO.T.SHA1 = ''
    FN.AZ.ACCOUNT='F.AZ.ACCOUNT'
    F.AZ.ACCOUNT=''

RETURN

*---------------------------------------------------------------------------
OPEN:
*---------------------------------------------------------------------------

    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.REDO.T.SHA1,F.REDO.T.SHA1)
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)

RETURN

*---------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------

    LREF.APPL = 'CUSTOMER':@FM:'AZ.ACCOUNT'
    LREF.FIELDS = 'L.CU.CIDENT':@FM:'L.AZ.SHA1.CODE'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APPL,LREF.FIELDS,LREF.POS)
    REF.POS = LREF.POS<1,1>
    SHA1.POS =LREF.POS<2,1>

    ACC.ID=ID.NEW
    CALL F.READ(FN.ACCOUNT,ACC.ID,R.ACC,F.ACCOUNT,ACC.ERR)
    IF R.ACC THEN
        CUS.ID = R.ACC<AC.CUSTOMER>
    END

    CALL F.READ(FN.CUSTOMER,CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR1)
    IF R.CUSTOMER THEN
        ID_CARD=R.CUSTOMER<EB.CUS.LOCAL.REF,REF.POS>
        NAME=R.CUSTOMER<EB.CUS.NAME.1>
        IF NAME EQ "" THEN
            NAME=R.CUSTOMER<EB.CUS.SHORT.NAME>
        END
    END

    INSTRUMENT = ID.NEW
    S.VAR = NAME:ID_CARD:INSTRUMENT ;*R22 Auto code conversion
    param = S.VAR ;*R22 Auto code conversion
    CALLJ "Logic.Hash","SHA1", param SETTING ret ON ERROR
        E= 'Unable to call JAVA PGM'
    END
    SHA1.CODE=ret

    CALL F.READ(FN.AZ.ACCOUNT,ACC.ID,R.AZ.ACC,F.AZ.ACCOUNT,AZ.ERR)
    IF R.AZ.ACC THEN
        R.AZ.ACC<AZ.LOCAL.REF,SHA1.POS> = SHA1.CODE
    END ELSE
        COMI = SHA1.CODE
    END

    CALL F.READ(FN.REDO.T.SHA1,SHA1.CODE,R.SHA1.CODE,F.REDO.T.SHA1,SHA1.ERR)
    IF SHA1.ERR THEN
*    R.SHA1.CODE<1> =ACC.ID
* Tus Start
        R.SHA1.CODE<RE.T.SH.AZ.ACCOUNT.NO> =ACC.ID
* Tus End
    END
    CALL F.WRITE(FN.REDO.T.SHA1,SHA1.CODE,R.SHA1.CODE)

RETURN
END
