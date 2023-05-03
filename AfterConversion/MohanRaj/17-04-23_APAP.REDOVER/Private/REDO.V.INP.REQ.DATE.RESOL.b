* @ValidationCode : Mjo1NTY3ODQwNjU6Q3AxMjUyOjE2ODE3MzI1NTA3NTY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:25:50
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
SUBROUTINE REDO.V.INP.REQ.DATE.RESOL
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION :A Input routine is written to update the DATE.OF.RESOLUTION from the
*local parameter table REDO.APAP.SLA.PARAM
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.INP.REQ.DATE.RESOL
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE WHO REFERENCE DESCRIPTION
* 30.07.2010 RENUGADEVI B ODR-2009-12-0283 INITIAL CREATION
* 20.05.2011 PRADEEP S PACS00060849 Coding standards changed
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    CONVERT TO CHANGE,FM TO @FM,SM TO @SM,VM TO @VM
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
*------------------------------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------------------------------
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.ISSUE.REQUESTS = 'F.REDO.ISSUE.REQUESTS'
    F.REDO.ISSUE.REQUESTS = ''
    CALL OPF(FN.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS)

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

    Y.CUS.ID = R.NEW(ISS.REQ.CUSTOMER.CODE)
    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    CUS.SEGMENT = R.CUSTOMER<EB.CUS.LOCAL.REF,L.CU.SEGMENTO.POS>
    CHANNEL.OPEN = R.NEW(ISS.REQ.OPENING.CHANNEL)
    CHANNEL.SEGEMENT = CHANNEL.OPEN:'-':CUS.SEGMENT
    DATE.TODAY = TODAY

    Y.TYPE = R.NEW(ISS.REQ.TYPE)
    Y.PRDT.TYPE = R.NEW(ISS.REQ.PRODUCT.TYPE)

    Y.DATE.RESOL.ID = Y.TYPE:'-':Y.PRDT.TYPE
    DESC.CLAIM = R.NEW(ISS.REQ.CLAIM.TYPE)
    DATE1 = R.NEW(ISS.REQ.OPENING.DATE)

    CALL CACHE.READ(FN.REDO.SLA.PARAM,Y.DATE.RESOL.ID,R.REDO.SLA.PARAM,SLA.ERR)
    DESC.SLA = R.REDO.SLA.PARAM<SLA.DESCRIPTION>
    CHANGE @VM TO @FM IN DESC.SLA

    LOCATE DESC.CLAIM IN DESC.SLA SETTING SLA.POS THEN
        Y.START.CHANNEL = R.REDO.SLA.PARAM<SLA.START.CHANNEL,SLA.POS>
*PACS00562454 - CRM request SLA date updation issue
        CHANGE @SM TO @FM IN Y.START.CHANNEL ;*R22 Auto code conversion
        LOCATE CHANNEL.SEGEMENT IN Y.START.CHANNEL SETTING SEG.POS THEN
            GOSUB UPDATE.DATE.RES
            GOSUB UPDATE.SER.AGR.COMP
        END ELSE
            GOSUB DEFAULT.PROCESS
        END
        R.NEW(ISS.REQ.SUPPORT.GROUP) = R.REDO.SLA.PARAM<SLA.SUPPORT.GROUP,SLA.POS>
        R.NEW(ISS.REQ.RISK.LEVEL) = R.REDO.SLA.PARAM<SLA.RISK.LEVEL,SLA.POS>
    END
RETURN
*----------------------------------------------------------------------------------------------
UPDATE.DATE.RES:
*------------------------------------------------------------------------------------------
    DAYS.RESOL = R.REDO.SLA.PARAM<SLA.SEG.DAYS,SLA.POS,SEG.POS>:'C'
    CALL CDT('',DATE.TODAY,DAYS.RESOL)
    R.NEW(ISS.REQ.DATE.RESOLUTION) = DATE.TODAY
RETURN
*------------------------------------------------------------------------------------------
UPDATE.SER.AGR.COMP:
*------------------------------------------------------------------------------------------
    DAYS.RESOL = R.REDO.SLA.PARAM<SLA.SEG.DAYS,SLA.POS,SEG.POS>
    NO.OF.DAYS = 'C'
    CALL CDD('',DATE1,TODAY,NO.OF.DAYS)
    IF NO.OF.DAYS GT DAYS.RESOL THEN
        R.NEW(ISS.REQ.SER.AGR.COMP) = "EXPIRED"
    END ELSE
        R.NEW(ISS.REQ.SER.AGR.COMP) = "ONTIME"
    END
RETURN
*-----------------------------------------------------------------------------------------
DEFAULT.PROCESS:
*-----------------------------------------------------------------------------------------
    R.NEW(ISS.REQ.DATE.RESOLUTION) = TODAY
    DAYS.RESOL = 0
    NO.OF.DAYS = 'C'
    IF DATE1 AND TODAY THEN
        CALL CDD('',DATE1,TODAY,NO.OF.DAYS)
    END
    IF NO.OF.DAYS GT DAYS.RESOL THEN
        R.NEW(ISS.REQ.SER.AGR.COMP) = "EXPIRED"
    END ELSE
        R.NEW(ISS.REQ.SER.AGR.COMP) = "ONTIME"
    END
RETURN
*-------------------------------------------------------------------------------------------
END
