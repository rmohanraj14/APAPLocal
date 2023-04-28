* @ValidationCode : MjoyNTgwNzk1MDE6Q3AxMjUyOjE2ODI2NzUyMjcyMDY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 28 Apr 2023 15:17:07
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
$PACKAGE APAP.REDOSRTN
*-----------------------------------------------------------------------------
* <Rating>-85</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.S.CUSTOMER.NAME1.NV(Y.OUT)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :SUDHARSANAN S
*Program   Name    :REDO.S.CUSTOMER.NAME1
*---------------------------------------------------------------------------------
*DESCRIPTION       :This program is used to get the all mapping details for RTE form
*
*Date           ref                 who             description
*16-08-2011   PACS000100501         Prabhu          PACS000100501-Customer mapping added for credit cards
*15-11-2011   PACS00142988          Pradeep S       Positions defined for Nature of Operation fields
*Modification history
*Date                Who               Reference                  Description
*06-04-2023      conversion tool     R22 Auto code conversion     No changes
*06-04-2023      Mohanraj R          R22 Manual code conversion   SM TO @SM,FM TO @FM,VM TO @VM

* ----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.TELLER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.T24.FUND.SERVICES
    $INSERT I_REDO.DEAL.SLIP.COMMON
    $INSERT I_F.REDO.PAY.TYPE
    $INSERT I_F.REDO.RTE.CATEG.POSITION
    $INSERT I_F.REDO.TFS.PROCESS

    GOSUB INIT
    GOSUB READ.RTE.CATEG.POS
    GOSUB PROCESS
RETURN
*********
INIT:
*********
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    F.TELLER.TRANSACTION = ''
    CALL OPF(FN.TELLER.TRANSACTION,F.TELLER.TRANSACTION)

    FN.REDO.PAY.TYPE = 'F.REDO.PAY.TYPE'
    F.REDO.PAY.TYPE = ''
    CALL OPF(FN.REDO.PAY.TYPE,F.REDO.PAY.TYPE)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.RTE.CATEG.POS = 'F.REDO.RTE.CATEG.POSITION'
    F.REDO.RTE.CATEG.POS = ''
    CALL OPF(FN.REDO.RTE.CATEG.POS,F.REDO.RTE.CATEG.POS)

    FN.REDO.TFS.PROCESS = 'F.REDO.TFS.PROCESS'
    F.REDO.TFS.PROCESS = ''
    CALL OPF(FN.REDO.TFS.PROCESS,F.REDO.TFS.PROCESS)

    LRF.APP = "CUSTOMER":@FM:"TELLER":@FM:"TELLER.TRANSACTION":@FM:"T24.FUND.SERVICES" ;*R22 Manual code conversion
    LRF.FIELD     = "L.CU.CIDENT":@VM:"L.CU.RNC":@VM:"L.CU.RES.SECTOR":@VM:"L.CU.TEL.TYPE":@VM:"L.CU.TEL.NO":@VM:"L.CU.TIPO.CL":@VM:"L.CU.TEL.AREA" ;*R22 Manual code conversion
    LRF.FIELD<-1> = "L.TT.CLIENT.COD":@VM:"L.TT.CR.ACCT.NO" ;*R22 Manual code conversion
    LRF.FIELD<-1> = "L.TT.PAY.TYPE"
    LRF.FIELD<-1> = "L.TT.PROCESS"
    LRF.POS = ''
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)

    VAR.SOCIAL = '' ; VAR.RNC = '' ;
    VAR.NAME1 = ''; VAR.NAME2 = ''; VAR.LASTNAME1 = '' ; VAR.LASTNAME2 = ''
    VAR.GENDER = '' ; VAR.DOB= '' ; VAR.NATION = '' ; VAR.CEDULA = '' ; VAR.PASSPORT = ''
    VAR.ADD1 = ''; VAR.ADD2 = ''; VAR.ADD3 = ''; VAR.ADD4 = ''; VAR.RES.SECTOR = ''
    VAR.STREET = ''; VAR.CITY = '' ; VAR.TOWN.COUNTRY = ''; VAR.OFF = ''; VAR.TEL.TYPE = '' ; VAR.TEL.NO = ''
    VAR.HOME = '' ; VAR.CELL = '' ; VAR.SECTOR = '' ; VAR.RTE.POS = ''
    Y.TEL.AREA=''
    CID.POS = LRF.POS<1,1>
    RNC.POS = LRF.POS<1,2>
    SEC.POS = LRF.POS<1,3>
    TYP.POS = LRF.POS<1,4>
    TEL.POS = LRF.POS<1,5>
    TIPO.POS = LRF.POS<1,6>
    Y.TEL.AREA.POS=LRF.POS<1,7>
    Y.CUST.COD.POS=LRF.POS<2,1>
    Y.CUST.CRED.ACC = LRF.POS<2,2>
    Y.TT.PAY.TYPE.POS = LRF.POS<3,1>
    POS.TT.PROCESS = LRF.POS<4,1>

    FN.FT.NAU = 'F.FUNDS.TRANSFER$NAU'
    F.FT.NAU = ''
    CALL OPF(FN.FT.NAU,F.FT.NAU)

RETURN

********************
READ.RTE.CATEG.POS:
********************
*New section included for PACS00142988

    R.RTE.CATEG.POS = ''
    CALL CACHE.READ(FN.REDO.RTE.CATEG.POS,"SYSTEM",R.RTE.CATEG.POS,CATEG.ERR)

    Y.RTE.POSITION = R.RTE.CATEG.POS<REDO.RTE.POS.RTE.POSITION>
    Y.CATEG.INIT   = R.RTE.CATEG.POS<REDO.RTE.POS.CATEG.INIT>
    Y.CATEG.END    = R.RTE.CATEG.POS<REDO.RTE.POS.CATEG.END>

RETURN

**************
PROCESS:
*************
*This para is used to get credit customer id based on application
    GOSUB FT.PROCESS

    GOSUB GET.CUST.DETAILS

RETURN
**************
FT.PROCESS:
*************

    Y.ID = ID.NEW

    CALL F.READ(FN.FT.NAU,Y.ID,R.FT.NAU,F.FT.NAU,FT.NAU.ERR)
    IF R.FT.NAU THEN
        VAR.CUS = R.FT.NAU<FT.CREDIT.CUSTOMER>
        VAR.AMOUNT = R.FT.NAU<FT.CREDIT.AMOUNT>
        IF NOT(VAR.AMOUNT) THEN
            VAR.AMOUNT = R.FT.NAU<FT.DEBIT.AMOUNT>
        END
        VAR.ACCOUNT = R.FT.NAU<FT.CREDIT.ACCT.NO>
    END ELSE
        VAR.CUS = R.NEW(FT.CREDIT.CUSTOMER)
        VAR.AMOUNT = R.NEW(FT.CREDIT.AMOUNT)
        IF NOT(VAR.AMOUNT) THEN
            VAR.AMOUNT = R.NEW(FT.DEBIT.AMOUNT)
        END
        VAR.ACCOUNT = R.NEW(FT.CREDIT.ACCT.NO)
    END

RETURN

****************
GET.CUST.DETAILS:
*****************
*This para is used to fetch required customer details
    CALL F.READ(FN.CUSTOMER,VAR.CUS,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    VAR.CLIENT.TYPE = R.CUSTOMER<EB.CUS.LOCAL.REF,TIPO.POS>

    IF VAR.CLIENT.TYPE EQ "PERSONA JURIDICA" THEN
        Y.NAME1 = R.CUSTOMER<EB.CUS.NAME.1>
        Y.NAME2 = R.CUSTOMER<EB.CUS.NAME.2>
        VAR.SOCIAL = Y.NAME1:" ":Y.NAME2
        VAR.RNC = R.CUSTOMER<EB.CUS.LOCAL.REF,RNC.POS>
    END ELSE
        VAR.NAME1 = FIELD(R.CUSTOMER<EB.CUS.GIVEN.NAMES>," ",1)
        VAR.NAME2 = FIELD(R.CUSTOMER<EB.CUS.GIVEN.NAMES>," ",2)
        VAR.LASTNAME1 = FIELD(R.CUSTOMER<EB.CUS.FAMILY.NAME>," ",1)
        VAR.LASTNAME2 = FIELD(R.CUSTOMER<EB.CUS.FAMILY.NAME>," ",2)
        VAR.GENDER = R.CUSTOMER<EB.CUS.GENDER>
        Y.DOB = R.CUSTOMER<EB.CUS.DATE.OF.BIRTH>
        Y.DOB=ICONV(Y.DOB,"D2")
        VAR.DOB=OCONV(Y.DOB,"D4")
        VAR.NATION = R.CUSTOMER<EB.CUS.NATIONALITY>
        VAR.CEDULA = R.CUSTOMER<EB.CUS.LOCAL.REF,CID.POS>
        VAR.PASSPORT = R.CUSTOMER<EB.CUS.LEGAL.ID>
    END
    VAR.ADD1 = R.CUSTOMER<EB.CUS.ADDRESS,1>
    VAR.ADD2 = R.CUSTOMER<EB.CUS.ADDRESS,2>
    VAR.ADD3 = R.CUSTOMER<EB.CUS.ADDRESS,3>
*    VAR.ADD4 = R.CUSTOMER<EB.CUS.ADDRESS,4>
    VAR.ADD4 = R.CUSTOMER<EB.CUS.RESIDENCE>
    VAR.RES.SECTOR = R.CUSTOMER<EB.CUS.LOCAL.REF,SEC.POS>
    VAR.STREET = R.CUSTOMER<EB.CUS.STREET>
    VAR.CITY = R.CUSTOMER<EB.CUS.COUNTRY>
    VAR.TOWN.COUNTRY = R.CUSTOMER<EB.CUS.TOWN.COUNTRY>
*    VAR.OFF = R.CUSTOMER<EB.CUS.OFF.PHONE>
    VAR.TEL.TYPE = R.CUSTOMER<EB.CUS.LOCAL.REF,TYP.POS>
    VAR.TEL.NO = R.CUSTOMER<EB.CUS.LOCAL.REF,TEL.POS>
    VAR.TEL.AREA = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.TEL.AREA.POS>
    CHANGE @SM TO @FM IN VAR.TEL.TYPE ;*R22 Manual code conversion
    CHANGE @SM TO @FM IN VAR.TEL.NO ;*R22 Manual code conversion
    CHANGE @SM TO @FM IN VAR.TEL.AREA ;*R22 Manual code conversion
    LOCATE '01' IN VAR.TEL.TYPE SETTING POS THEN
        VAR.HOME = VAR.TEL.AREA<POS>:VAR.TEL.NO<POS>
    END
    LOCATE '05' IN VAR.TEL.TYPE SETTING POS2 THEN
        VAR.OFF = VAR.TEL.AREA<POS2>:VAR.TEL.NO<POS2>
    END
    LOCATE '06' IN VAR.TEL.TYPE SETTING POS1 THEN
        VAR.CELL = VAR.TEL.AREA<POS1>:VAR.TEL.NO<POS1>
    END
    VAR.SECTOR = R.CUSTOMER<EB.CUS.SECTOR>
    Y.OUT = VAR.NAME1
RETURN
*------------------------------------------------------------------------------------
END
