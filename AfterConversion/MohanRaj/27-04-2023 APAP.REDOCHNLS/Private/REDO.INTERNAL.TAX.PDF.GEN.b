* @ValidationCode : MjotNzIwMDA3NDkwOkNwMTI1MjoxNjgxMzgwODU5NDQ5OklUU1M6LTE6LTE6MjMxMjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 2312
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERNAL.TAX.PDF.GEN(Y.ARRAY)
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.INTERNAL.TAX.PDF.GEN
* ODR NO      : ODR-2009-10-0838
*----------------------------------------------------------------------
*DESCRIPTION: This routine is attched in NOFILE ENQUIRY
* to get the details of the Product selected for LETTER

*IN PARAMETER:  NA
*OUT PARAMETER: Y.ARRAY
*LINKED WITH: REDO.LETTER.ISSUE
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*18.03.2010  H GANESH     ODR-2009-10-0838   INITIAL CREATION
*15.07.2011  RIYAS          PACS00072839   MODIFY-CHECK THE LEGAL ID
*24.08.2011  Sudharsanan   PACS00120764   Get the id value of REDO.ISSUE.LETTER and get the customer and product values
* 10-APR-2023     Conversion tool   R22 Auto conversion      FM TO @FM, VM to @VM, ++ to +=, F.READ to CACHE.READ, IF condition added
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.CATEGORY
    $INSERT I_F.AZ.SCHEDULES
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.OFFICERS.LIST
    $INSERT I_F.REDO.LETTER.ISSUE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ENQUIRY
    $INSERT I_F.TELLER
    $INSERT I_System
    $INSERT I_F.USER
* Tus Start
    $INSERT I_F.EB.CONTRACT.BALANCES
* Tus End

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB LOCAL.REF
    GOSUB PROCESS
RETURN

*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    FN.ACCOUNT.HIS='F.ACCOUNT$HIS'
    F.ACCOUNT.HIS=''
    FN.CATEGORY='F.CATEGORY'
    F.CATEGORY=''
    FN.AZ.ACCOUNT='F.AZ.ACCOUNT'
    F.AZ.ACCOUNT=''
    FN.AZ.SCHEDULES='F.AZ.SCHEDULES'
    F.AZ.SCHEDULES=''
    Y.ARRAY=''
    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER=''
    FN.REDO.OFFICERS.LIST='F.REDO.OFFICERS.LIST'
    F.REDO.OFFICERS.LIST=''
    FN.REDO.LETTER.ISSUE='F.REDO.LETTER.ISSUE'
    F.REDO.LETTER.ISSUE=''
    CHK.VALUE = 1 ; Y.COMPANY.PREFIX = ''
RETURN

*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------

    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.CATEGORY,F.CATEGORY)
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)
    CALL OPF(FN.AZ.SCHEDULES,F.AZ.SCHEDULES)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.REDO.OFFICERS.LIST,F.REDO.OFFICERS.LIST)
    CALL OPF(FN.ACCOUNT.HIS,F.ACCOUNT.HIS)
    CALL OPF(FN.REDO.LETTER.ISSUE,F.REDO.LETTER.ISSUE)
RETURN

*----------------------------------------------------------------------
LOCAL.REF:
*----------------------------------------------------------------------

    LOC.REF.APPLICATION="ACCOUNT":@FM:"TELLER":@FM:"CUSTOMER"
    LOC.REF.FIELDS='L.AC.STATUS1':@FM:'L.LETTER.ID':@FM:'L.CU.CIDENT':@VM:'L.CU.TIPO.CL':@VM:'L.CU.RNC'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AC.STATUS1=LOC.REF.POS<1,1>
    POS.L.LETTER.ID=LOC.REF.POS<2,1>
    POS.L.CU.CIDENT=LOC.REF.POS<3,1>
    POS.L.CU.TIPO.CL = LOC.REF.POS<3,2>
    POS.L.CU.RNC = LOC.REF.POS<3,3>
RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
* Get the details of Customer and Product Details
*PACS00120764 - S
    IF APPLICATION EQ 'TELLER' THEN
        Y.LETTER.INT.ISSUE.ID=R.NEW(TT.TE.LOCAL.REF)<1,POS.L.LETTER.ID>
        CALL F.READ(FN.REDO.LETTER.ISSUE,Y.LETTER.INT.ISSUE.ID,R.LETTER.INT.ISSUE,F.REDO.LETTER.ISSUE,LETTER.ERR)
    END ELSE
        Y.LETTER.INT.ISSUE.ID = System.getVariable("CURRENT.INT")
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - START
            Y.LETTER.INT.ISSUE.ID = ""
        END				   ;*R22 Auto conversion - END
        CALL F.READ(FN.REDO.LETTER.ISSUE,Y.LETTER.INT.ISSUE.ID,R.LETTER.INT.ISSUE,F.REDO.LETTER.ISSUE,ERR.IS)
    END

    Y.RECIPIENT.NAME=R.LETTER.INT.ISSUE<REDO.LET.ISS.RECIPIENT>
    Y.RECIPIENT.CITY=R.LETTER.INT.ISSUE<REDO.LET.ISS.RECIPIENT.CITY>
    Y.CUSTOMER.ID=R.LETTER.INT.ISSUE<REDO.LET.ISS.CUSTOMER.ID>
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    Y.CU.NAME=R.LETTER.INT.ISSUE<REDO.LET.ISS.CU.NAME>
    Y.TIPO.CL = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.L.CU.TIPO.CL>
    IF Y.TIPO.CL EQ 'PERSONA FISICA' THEN
        Y.COMPANY.PREFIX = 'la Cedula de Identidad Personal No.'
        Y.CUDELA=R.CUSTOMER<EB.CUS.LOCAL.REF,POS.L.CU.CIDENT>
        IF NOT(Y.CUDELA) THEN
            Y.COMPANY.PREFIX = 'Pasaporte No.'
            Y.CUDELA = R.CUSTOMER<EB.CUS.LEGAL.ID,1>
        END
    END ELSE
        IF Y.TIPO.CL EQ 'PERSONA JURIDICA' THEN
            Y.COMPANY.PREFIX = 'la Compania el RNC No.'
            Y.CUDELA=R.CUSTOMER<EB.CUS.LOCAL.REF,POS.L.CU.RNC>
        END
    END

    Y.START.DATE=R.LETTER.INT.ISSUE<REDO.LET.ISS.START.DATE>
    IF Y.START.DATE NE '' THEN
        Y.START.DATE=Y.START.DATE[7,2]:'/':Y.START.DATE[5,2]:'/':Y.START.DATE[1,4]
    END
    Y.END.DATE=R.LETTER.INT.ISSUE<REDO.LET.ISS.END.DATE>
    IF Y.END.DATE NE '' THEN
        Y.END.DATE=Y.END.DATE[7,2]:'/':Y.END.DATE[5,2]:'/':Y.END.DATE[1,4]
    END
    Y.PRODUCT=R.LETTER.INT.ISSUE<REDO.LET.ISS.PRODUCTS>
    Y.PRODUCT.CNT=DCOUNT(Y.PRODUCT,@VM)
    VAR1=1
    LOOP
    WHILE VAR1 LE Y.PRODUCT.CNT

        Y.ORG.AMOUNT=0
        Y.INTEREST.ACCURED=0
        Y.PRODUCT.ID=Y.PRODUCT<1,VAR1>
*   Tus Start
        ACC.LIVE.FLAG = ''
        R.ECB = ''
        ECB.ERR = ''
*   Tus End
        CALL F.READ(FN.ACCOUNT,Y.PRODUCT.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
* Tus Start
        CALL EB.READ.HVT("EB.CONTRACT.BALANCES", Y.PRODUCT.ID, R.ECB, ECB.ERR)
        IF R.ECB THEN

            ACC.LIVE.FLAG = 1
        END ; * Tus End

        IF R.ACCOUNT EQ '' THEN
            Y.ACC.ID=Y.PRODUCT.ID
            CALL EB.READ.HISTORY.REC(F.ACCOUNT.HIS,Y.ACC.ID,R.ACCOUNT,YERROR)
            IF R.ACCOUNT EQ '' THEN
                Y.ACC.ID = Y.PRODUCT.ID:';':CHK.VALUE
                CALL F.READ(FN.ACCOUNT.HIS,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT.HIS,ERR.ACC)
            END
        END
        Y.CATEGORY=R.ACCOUNT<AC.CATEGORY>
        CALL CACHE.READ(FN.CATEGORY, Y.CATEGORY, R.CATEGORY, CAT.ERR) ;*R22 Auto conversion
        Y.CATEGORY.DES=R.CATEGORY<EB.CAT.DESCRIPTION>
        CALL F.READ(FN.AZ.ACCOUNT,Y.PRODUCT.ID,R.AZ.ACCOUNT,F.AZ.ACCOUNT,AZ.ERR)
        IF R.AZ.ACCOUNT NE '' THEN
            Y.ORG.AMOUNT=R.AZ.ACCOUNT<AZ.ORIG.PRINCIPAL>
        END
        Y.ORG.AMOUNT=FMT(Y.ORG.AMOUNT,"L2,RD$#25")
        CALL F.READ(FN.AZ.SCHEDULES,Y.PRODUCT.ID,R.AZ.SCHEDULES,F.AZ.SCHEDULES,AZ.SCH.ERR)
        IF R.AZ.SCHEDULES NE '' THEN
            GOSUB INT.CALC
        END
        Y.INTEREST.ACCURED=FMT(Y.INTEREST.ACCURED,"L2,RD$#25")
* Tus Start
        IF ACC.LIVE.FLAG THEN
            Y.BALANCE=R.ECB<ECB.WORKING.BALANCE>
        END ELSE
*  Y.BALANCE=R.ACCOUNT<AC.WORKING.BALANCE>
        END ; * Tus End
        IF Y.BALANCE EQ '' THEN
            Y.BALANCE= 0
        END
        Y.BALANCE=FMT(Y.BALANCE,"L2,RD$#25")
        Y.OPENING.DATE=R.ACCOUNT<AC.OPENING.DATE>
        Y.OPENING.DATE=Y.OPENING.DATE[7,2]:'/':Y.OPENING.DATE[5,2]:'/':Y.OPENING.DATE[1,4]
        Y.STATUS=R.ACCOUNT<AC.LOCAL.REF,POS.L.AC.STATUS1>
        GOSUB CHECK.STA.DES
        Y.PROD.LEN=LEN(Y.PRODUCT.ID)
        Y.PROD.NO='********':Y.PRODUCT.ID[Y.PROD.LEN-3,Y.PROD.LEN]
        Y.ARRAY1:=Y.CATEGORY.DES:":":Y.PROD.NO:":":Y.ORG.AMOUNT:":":Y.INTEREST.ACCURED:":":Y.BALANCE:":":Y.OPENING.DATE:":":VAR.STATUS:"@":@VM
        VAR1 += 1
    REPEAT
    Y.OFFICER.CODE=R.LETTER.INT.ISSUE<REDO.LET.ISS.ISS.OFFICER>
    CALL F.READ(FN.REDO.OFFICERS.LIST,Y.OFFICER.CODE,R.REDO.OFFICERS.LIST,F.REDO.OFFICERS.LIST,OFF.ERR)
    Y.OFFICER.NAME=R.REDO.OFFICERS.LIST<REDO.OFF.LIS.OFFICER.NAME>
    Y.OFFICER.POSITION=R.REDO.OFFICERS.LIST<REDO.OFF.LIS.DESIGNATION>
    Y.OFFICER.DEPT=R.REDO.OFFICERS.LIST<REDO.OFF.LIS.DEPT.BRANCH>
    Y.DEBIT.ACC=R.LETTER.INT.ISSUE<REDO.LET.ISS.CHARGE.LIQ.ACT>
    Y.CHARGE.AMT=R.LETTER.INT.ISSUE<REDO.LET.ISS.CHARGE.AMT>
    Y.CHARGE.AMT=FMT(Y.CHARGE.AMT,"L2,RD$#25")
    Y.CHARGE.CCY=R.LETTER.INT.ISSUE<REDO.LET.ISS.CHARGE.CCY>
    Y.ARRAY=TODAY[7,2]:'/':TODAY[5,2]:'/':TODAY[1,4]:"#":Y.RECIPIENT.NAME:"#":Y.RECIPIENT.CITY:"#":Y.CU.NAME:"#":Y.CUDELA:"#":Y.START.DATE:"#":Y.END.DATE:"#":Y.ARRAY1:"#":Y.OFFICER.NAME:"#":Y.OFFICER.POSITION:"#":Y.OFFICER.DEPT:"#":Y.DEBIT.ACC:"#":Y.CHARGE.AMT:"#":Y.CHARGE.CCY:"#":Y.COMPANY.PREFIX
*PACS00120764 - E
RETURN

*----------------------------------------------------------------------
INT.CALC:
*----------------------------------------------------------------------
* Interest Accured for AZ.ACCOUNT calculation

    Y.DATE=R.AZ.SCHEDULES<AZ.SLS.DATE>
    Y.DATE.CNT=DCOUNT(Y.DATE,@VM)
    VAR2=1
    LOOP
    WHILE VAR2 LE Y.DATE.CNT
        IF Y.DATE<1,VAR2> GT TODAY THEN
            Y.INTEREST.ACCURED=R.AZ.SCHEDULES<AZ.SLS.TYPE.I,VAR2>
            VAR2 = Y.DATE.CNT
        END
        VAR2 += 1
    REPEAT
RETURN
*----------------------------------------------------------------------------------
CHECK.STA.DES:
*-----------------------------------------------------------------------------------
    VAR.USER.LANG  =  R.USER<EB.USE.LANGUAGE>
    VAR.VIRTUAL.TABLE = "L.AC.STATUS1"
    CALL EB.LOOKUP.LIST(VAR.VIRTUAL.TABLE)
    CNT.VTABLE= DCOUNT(VAR.VIRTUAL.TABLE,@FM)
    VIRTUAL.TABLE.IDS = VAR.VIRTUAL.TABLE<2>        ;*2nd Part
    VIRTUAL.TABLE.VALUES = VAR.VIRTUAL.TABLE<CNT.VTABLE>
    CHANGE '_' TO @FM IN VIRTUAL.TABLE.VALUES
    CHANGE '_' TO @FM IN VIRTUAL.TABLE.IDS
    LOCATE Y.STATUS IN VIRTUAL.TABLE.IDS SETTING POS THEN
        VAL.DESC = ''
        VAL.DESC = VIRTUAL.TABLE.VALUES<POS,VAR.USER.LANG>
        IF NOT(VAL.DESC) THEN
            VAR.STATUS = VIRTUAL.TABLE.VALUES<POS,1>
        END ELSE
            VAR.STATUS = VAL.DESC
        END
    END
RETURN
*----------------------------------------------------------------------------------
END
