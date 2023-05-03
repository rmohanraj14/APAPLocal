* @ValidationCode : MjotOTA2NTcyNzc4OkNwMTI1MjoxNjgxNzM1NzE5MDkwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 18:18:39
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
SUBROUTINE REDO.V.INP.CLAIM.DATE.RESOL
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION :A Input routine is written to update the DATE.OF.RESOLUTION from the
*local parameter table REDO.SLA.PARAM
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RENUGADEVI B
* PROGRAM NAME : REDO.V.INP.CLAIM.DATE.RESOL
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE WHO REFERENCE DESCRIPTION
* 27.07.2010 RENUGADEVI B ODR-2009-12-0283 INITIAL CREATION
* 27.05.2011 PRADEEP S PACS00071941 Coding standards changed
* 27-Jul-2012 Madhupriya PACS00209535 Locate statement updated
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO@FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.CLAIMS
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.SLA.PARAM

    GOSUB INIT
    GOSUB PROCESS
RETURN
*------------------------------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------------------------------
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.ISSUE.CLAIMS = 'F.REDO.ISSUE.CLAIMS'
    F.REDO.ISSUE.CLAIMS = ''
    CALL OPF(FN.REDO.ISSUE.CLAIMS,F.REDO.ISSUE.CLAIMS)

    FN.REDO.SLA.PARAM = 'F.REDO.SLA.PARAM'
    F.REDO.SLA.PARAM = ''
    CALL OPF(FN.REDO.SLA.PARAM,F.REDO.SLA.PARAM)

    LREF.APPLICATION = 'CUSTOMER'
    LREF.FIELD = 'L.CU.SEGMENTO'
    LREF.POS = ''
    CALL GET.LOC.REF(LREF.APPLICATION,LREF.FIELD,LREF.POS)
    L.CU.SEGMENTO.POS = LREF.POS
    FLAG = ''

RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------

    Y.CUS.ID = R.NEW(ISS.CL.CUSTOMER.CODE)
    CUST.ID = Y.CUS.ID
    CUST.NO = ''
    CUS.ERR = ''
    CALL APAP.SRTN.REDO.S.CUST.ID.VAL(CUST.ID,CUST.NO,CUS.ERR) ;* R22 Manual Conversion - CALL method format modified
    Y.CUS.ID = CUST.NO
    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    CUS.SEGMENT = R.CUSTOMER<EB.CUS.LOCAL.REF,L.CU.SEGMENTO.POS>
    CHANNEL.OPEN = R.NEW(ISS.CL.OPENING.CHANNEL)
    CHANNEL.SEGEMENT = CHANNEL.OPEN:'-':CUS.SEGMENT
    DATE.TODAY = TODAY

    Y.TYPE = R.NEW(ISS.CL.TYPE)
    Y.PRDT.TYPE = R.NEW(ISS.CL.PRODUCT.TYPE)

    Y.DATE.RESOL.ID = Y.TYPE:'-':Y.PRDT.TYPE
    DESC.CLAIM = R.NEW(ISS.CL.CLAIM.TYPE)
    DATE1 = R.NEW(ISS.CL.OPENING.DATE)

    CALL F.READ(FN.REDO.SLA.PARAM,Y.DATE.RESOL.ID,R.REDO.SLA.PARAM,F.REDO.SLA.PARAM,SLA.ERR)
    DESC.SLA = R.REDO.SLA.PARAM<SLA.DESCRIPTION>
    CHANGE @VM TO @FM IN DESC.SLA
*PACS00209535
    LOCATE DESC.CLAIM IN DESC.SLA SETTING SLA.POS THEN
        Y.START.CHANNEL = R.REDO.SLA.PARAM<SLA.START.CHANNEL,SLA.POS>
        LOCATE CHANNEL.SEGEMENT IN Y.START.CHANNEL<1,1,1> SETTING SEG.POS THEN
            GOSUB UPDATE.DATE.RES
            GOSUB UPDATE.SER.AGR.COMP
        END ELSE
            GOSUB DEFAULT.PROCESS
        END
        R.NEW(ISS.CL.SUPPORT.GROUP) = R.REDO.SLA.PARAM<SLA.SUPPORT.GROUP,SLA.POS>
        R.NEW(ISS.CL.RISK.LEVEL) = R.REDO.SLA.PARAM<SLA.RISK.LEVEL,SLA.POS>
    END
RETURN
*----------------------------------------------------------------------------------------------
UPDATE.DATE.RES:
*------------------------------------------------------------------------------------------
    DAYS.RESOL = R.REDO.SLA.PARAM<SLA.SEG.DAYS,SLA.POS,SEG.POS>:'C'
    CALL CDT('',DATE.TODAY,DAYS.RESOL)
    R.NEW(ISS.CL.DATE.RESOLUTION) = DATE.TODAY
RETURN
*------------------------------------------------------------------------------------------
UPDATE.SER.AGR.COMP:
*------------------------------------------------------------------------------------------
    DAYS.RESOL = R.REDO.SLA.PARAM<SLA.SEG.DAYS,SLA.POS,SEG.POS>
    NO.OF.DAYS = 'C'
    IF DATE1 AND TODAY THEN
        CALL CDD('',DATE1,TODAY,NO.OF.DAYS)
    END
    IF NO.OF.DAYS GT DAYS.RESOL THEN
        R.NEW(ISS.CL.SER.AGR.COMP) = "EXPIRED"
    END ELSE
        R.NEW(ISS.CL.SER.AGR.COMP) = "ONTIME"
    END
RETURN
*-----------------------------------------------------------------------------------------
DEFAULT.PROCESS:
*-----------------------------------------------------------------------------------------
    R.NEW(ISS.CL.DATE.RESOLUTION) = TODAY
    DAYS.RESOL = 0
    NO.OF.DAYS = 'C'
    IF DATE1 AND TODAY THEN
        CALL CDD('',DATE1,DATE.TODAY,NO.OF.DAYS)
    END
    IF NO.OF.DAYS GT DAYS.RESOL THEN
        R.NEW(ISS.CL.SER.AGR.COMP) = "EXPIRED"
    END ELSE
        R.NEW(ISS.CL.SER.AGR.COMP) = "ONTIME"
    END
RETURN
*-------------------------------------------------------------------------------------------
END
