* @ValidationCode : MjotMTMyMzM1MTExOkNwMTI1MjoxNjgxMzgwNzg1MTQzOklUU1M6LTE6LTE6NjczOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 673
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.CHECK.STO.TRANSFER(ID.BEN.TO.DEL,Y.FLAG)
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By :
* Program Name : AI.REDO.CHECK.STO.TRANSFER
*-----------------------------------------------------------------------------
* Description : This subroutine is attached as a BUILD routine in the Enquiry AI.REDO.LOAN.ACCT.TO
* In Parameter : ENQ.DATA
* Out Parameter : None
*
**DATE           ODR                   DEVELOPER               VERSION
** 11-APR-2023     Conversion tool    R22 Auto conversion      IF Condition added
** 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System
    $INSERT I_EB.EXTERNAL.COMMON
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_F.STANDING.ORDER
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER
    $INSERT I_F.BENEFICIARY


    GOSUB INITIALISE
    GOSUB GET.STO.TRF.DETAILS
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*-----------------------------------------------------------------------------

    STO.WRK.ID=''
    CUSTOMER.ID = System.getVariable("EXT.SMS.CUSTOMERS")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - START
        CUSTOMER.ID = ""
    END					;*R22 Auto conversion - END

    FN.STO = 'F.STANDING.ORDER'
    F.STO = ''
    CALL OPF(FN.STO,F.STO)

    FN.CUS.ACC = 'F.CUSTOMER.ACCOUNT'
    F.CUS.ACC = ''
    CALL OPF(FN.CUS.ACC,F.CUS.ACC)

    FN.ARCIB.PARAM = 'F.AI.REDO.ARCIB.PARAMETER'
    F.ARCIB.PARAM = ''
    CALL OPF(FN.ARCIB.PARAM,F.ARCIB.PARAM)

    FN.STO.ACC.LIST= 'F.STO.ACCOUNT.LIST'
    F.STO.ACC.LIST = ''
    CALL OPF(FN.STO.ACC.LIST,F.STO.ACC.LIST)

RETURN
*----------------------------------------------------------------------------
GET.STO.TRF.DETAILS:
*-----------------------------------------------------------------------------


    R.CUST.ACC = ''
    CORRECT.STO.ID=''
    CUSTOMER.ID = System.getVariable('EXT.SMS.CUSTOMERS')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion -start
        CUSTOMER.ID = ""
    END					;*R22 Auto conversion - end
    CALL F.READ(FN.CUS.ACC,CUSTOMER.ID,R.CUST.ACC,F.CUS.ACC,CUS.ACC.ERR)
    IF NOT(CUS.ACC.ERR) THEN
        LOOP
            REMOVE ACCT.ID FROM R.CUST.ACC SETTING CUST.ACC.POS
        WHILE ACCT.ID:CUST.ACC.POS
            CALL F.READ(FN.STO.ACC.LIST,ACCT.ID,R.STO.LIST.REC,F.STO.ACC.LIST,STO.ACC.ERR)
            IF NOT(STO.ACC.ERR) THEN
                GOSUB CROSS.CHECK.STO
            END
        REPEAT
    END

RETURN

****************
CROSS.CHECK.STO:
****************

    LOOP
        REMOVE NO.ID.STO FROM R.STO.LIST.REC SETTING NO.ID.POS
    WHILE NO.ID.STO : NO.ID.POS
        CORRECT.STO.ID = ACCT.ID:".":NO.ID.STO
        R.STO.REC = ''
        CALL F.READ(FN.STO,CORRECT.STO.ID,R.STO.REC,F.STO,STO.ERR)
        IF NOT(STO.ERR) THEN
            STO.BEN.ID = R.STO.REC<STO.BENEFICIARY.ID>
            IF STO.BEN.ID EQ ID.BEN.TO.DEL THEN
                Y.FLAG = 1
                RETURN
            END
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
END
*---------*END OF SUBROUTINE*-------------------------------
