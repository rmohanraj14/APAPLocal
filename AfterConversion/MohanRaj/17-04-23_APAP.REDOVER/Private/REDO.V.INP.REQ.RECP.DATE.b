* @ValidationCode : MjoyNjQxNjI1NzQ6Q3AxMjUyOjE2ODE3MzI1ODc1NTg6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:26:27
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
SUBROUTINE REDO.V.INP.REQ.RECP.DATE
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is Input routine to update the values of DATE & TIME field of REDO.ISSUE.REQUESTS
* at the time of commitment
* This development is for ODR Reference ODR-2009-12-0283
* Input/Output:
*--------------
* IN  : N/A
* OUT : N/A
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
* Revision History:
*------------------------------------------------------------------------------------------
* Date              who              Reference            Description
* 27-JUL-2010       B Renugadevi     ODR-2009-12-0283    Initial Creation
*13-MAR-2011        Prabhu N         HD1100441           Manadatory check removed for the fields CLIENT.CONTACTED,CL.NOTES,CLOSE.NOTIFICATION
* 13-MAY-2011       Pradeep S        PACS00060849        RECEPTION.TIME updated only once
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.REQUESTS

    GOSUB INIT
    GOSUB PROCESS
RETURN

******
INIT:
******
    FN.REDO.ISSUE.REQUESTS = 'F.REDO.ISSUE.REQUESTS'
    F.REDO.ISSUE.REQUESTS  = ''
    CALL OPF(FN.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS)
RETURN

*********
PROCESS:
*********
    Y.TIME      = OCONV(TIME(), 'MTS')
    IF R.NEW(ISS.REQ.STATUS) EQ "OPEN" THEN
        R.NEW(ISS.REQ.OPENING.DATE) = TODAY
    END
    IF R.NEW(ISS.REQ.STATUS) EQ 'RESOLVED NOTIFIED' THEN
        R.NEW(ISS.REQ.DATE.NOTIFICATION) = TODAY
    END
    IF R.NEW(ISS.REQ.STATUS) EQ 'CLOSED' THEN
        R.NEW(ISS.REQ.CLOSING.DATE) = TODAY
        GOSUB UPDATE.CLOSED.FIELD
    END

*PACS00060849 - S
    Y.RECP.TIME = R.NEW(ISS.REQ.RECEPTION.TIME)
    R.NEW(ISS.REQ.RECEPTION.TIME) = Y.TIME
    IF NOT(Y.RECP.TIME) THEN
        R.NEW(ISS.REQ.RECEPTION.TIME) = Y.TIME
    END
*PACS00060849 - E

RETURN
********************
UPDATE.CLOSED.FIELD:
********************

    IF R.NEW(ISS.REQ.CLOSING.STATUS) EQ ''  THEN
        AF = ISS.REQ.CLOSING.STATUS
        ETEXT = 'EB-INPUT.MAND'
        CALL STORE.END.ERROR
    END

    IF R.NEW(ISS.REQ.CLOSING.REMARKS) EQ '' THEN
        AF = ISS.REQ.CLOSING.REMARKS
        ETEXT = 'EB-INPUT.MAND'
        CALL STORE.END.ERROR
    END

    IF R.NEW(ISS.REQ.INTERNAL.REMARKS) EQ '' THEN
        AF = ISS.REQ.INTERNAL.REMARKS
        ETEXT = 'EB-INPUT.MAND'
        CALL STORE.END.ERROR
    END

    IF R.NEW(ISS.REQ.USER.REMARKS) EQ '' THEN
        AF = ISS.REQ.USER.REMARKS
        ETEXT = 'EB-INPUT.MAND'
        CALL STORE.END.ERROR
    END
RETURN
*---------------------------------------------------------------------------------------------------
END
