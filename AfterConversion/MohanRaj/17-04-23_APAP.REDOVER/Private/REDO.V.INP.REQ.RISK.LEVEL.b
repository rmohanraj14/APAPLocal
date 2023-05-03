* @ValidationCode : MjoyMDI2OTY2OTUzOkNwMTI1MjoxNjgxNzMyODA1MDMwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:30:05
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
SUBROUTINE REDO.V.INP.REQ.RISK.LEVEL
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* DESCRIPTION :An Input routine is written to update the RISK.LEVEL from the
* local parameter table REDO.SLA.PARAM
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RENUGADEVI B
* PROGRAM NAME : REDO.V.INP.REQ.RISK.LEVE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 27.07.2010       RENUGADEVI B       ODR-2009-12-0283  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.REQUESTS
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.SLA.PARAM

    GOSUB INIT
    GOSUB PROCESS
RETURN

*****
INIT:
*****
    FN.REDO.ISSUE.REQUESTS = 'F.REDO.ISSUE.REQUESTS'
    F.REDO.ISSUE.REQUESTS  = ''
    CALL OPF(FN.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS)
    FN.REDO.SLA.PARAM = 'F.REDO.SLA.PARAM'
    F.REDO.SLA.PARAM  = ''
    CALL OPF(FN.REDO.SLA.PARAM,F.REDO.SLA.PARAM)
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    LREF.APPLICATION = 'CUSTOMER'
    LREF.FIELD = 'L.CU.SEGMENTO'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APPLICATION,LREF.FIELD,LREF.POS)
    L.CU.SEGMENTO.POS = LREF.POS<1,1>

RETURN
********
PROCESS:
********
    Y.CUST         = R.NEW(ISS.REQ.CUSTOMER.CODE)
    CALL F.READ(FN.CUSTOMER,Y.CUST,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        Y.SEGMENT  = R.CUSTOMER<EB.CUS.LOCAL.REF,L.CU.SEGMENTO.POS>
    END

    Y.PROD         = R.NEW(ISS.REQ.PRODUCT.TYPE)
*    Y.PRODUCT      = FIELD(Y.PROD,'-',2)
    Y.TYPE1        = R.NEW(ISS.REQ.TYPE)
*    Y.TYPE         = FIELD(Y.TYPE1,'-',2)
    Y.OPEN.CHANNEL = R.NEW(ISS.REQ.OPENING.CHANNEL)
    Y.DESC.CLAIM   = R.NEW(ISS.REQ.CLAIM.TYPE)
    Y.SLA.ID       = Y.TYPE1:'-':Y.PROD
    Y.SEG.CHA      = Y.OPEN.CHANNEL:'-':Y.SEGMENT
    CALL F.READ(FN.REDO.SLA.PARAM,Y.SLA.ID,R.REDO.SLA,F.REDO.SLA.PARAM,SLA.ERR)
    IF R.REDO.SLA THEN
        Y.SLA.DESC = R.REDO.SLA<SLA.DESCRIPTION>
    END
    CHANGE @VM TO @FM IN Y.SLA.DESC
    LOCATE Y.DESC.CLAIM IN Y.SLA.DESC SETTING SLA.POS THEN
        Y.RISK     = R.REDO.SLA<SLA.RISK.LEVEL,SLA.POS>
    END
    IF Y.RISK NE '' THEN
        R.NEW(ISS.REQ.RISK.LEVEL) = Y.RISK
    END ELSE
        R.NEW(ISS.REQ.RISK.LEVEL) = ''
    END
RETURN
END
