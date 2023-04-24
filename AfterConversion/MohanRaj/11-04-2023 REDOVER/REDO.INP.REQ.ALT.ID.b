* @ValidationCode : MjoxNDIzNjk0OTpDcDEyNTI6MTY4MTIxNDM5NTk3ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:29:55
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
SUBROUTINE REDO.INP.REQ.ALT.ID
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : This Input routine is used to update the alternate.id field
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.INP.REQ.ALT.ID
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 27.08.2010      SUDHARSANAN S     ODR-2009-12-0283  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.ISSUE.REQUESTS
    $INSERT I_F.REDO.CUST.REQUESTS
    $INSERT I_F.CUSTOMER

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

    FN.REDO.CUST.REQUESTS = 'F.REDO.CUST.REQUESTS'
    F.REDO.CUST.REQUESTS = ''
    CALL OPF(FN.REDO.CUST.REQUESTS,F.REDO.CUST.REQUESTS)

RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------
*    DEBUG

    Y.CUST.ID = R.NEW(ISS.REQ.CUSTOMER.CODE)

*  CALL F.READ(FN.REDO.CUST.REQUESTS,'SYSTEM',R.REDO.CUST.REQ,F.REDO.CUST.REQUESTS,CUST.REQ.ERR) ;*Tus Start
    CALL CACHE.READ(FN.REDO.CUST.REQUESTS,'SYSTEM',R.REDO.CUST.REQ,CUST.REQ.ERR) ; * Tus End
    VAR.CUST.ID = R.REDO.CUST.REQ<CUST.REQ.CUST.ID>
    CHANGE @VM TO @FM IN VAR.CUST.ID
    LOCATE Y.CUST.ID IN VAR.CUST.ID SETTING POS1 THEN
        VAR.SEQ.NO = R.REDO.CUST.REQ<CUST.REQ.CUST.SEQ.NO,POS1>
        VAR.CUS.SEQ.NO = VAR.SEQ.NO+1
        R.REDO.CUST.REQ<CUST.REQ.CUST.SEQ.NO,POS1> = VAR.CUS.SEQ.NO
        Y.APAP.SEQ=R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO>
        Y.SEQ = Y.APAP.SEQ+1
        R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO> = Y.SEQ
    END ELSE
        CNT = DCOUNT(VAR.CUST.ID,@FM)
        VAR.CUS.SEQ.NO = '1'
        R.REDO.CUST.REQ<CUST.REQ.CUST.ID,CNT+1> = Y.CUST.ID
        R.REDO.CUST.REQ<CUST.REQ.CUST.SEQ.NO,CNT+1>  = VAR.CUS.SEQ.NO
    END
    APAP.SEQ.NO = R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO>
    IF APAP.SEQ.NO THEN
        Y.APAP.SEQ=R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO>
        Y.SEQ = Y.APAP.SEQ+1
        R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO> = Y.SEQ
    END ELSE
        R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO> = '1'
        Y.SEQ = R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO>
        R.REDO.CUST.REQ<CUST.REQ.APAP.SEQ.NO> = Y.SEQ
    END
*        R.NEW(ISS.REQ.ALTERNATE.ID) = Y.CUST.ID:'-':VAR.CUS.SEQ.NO:'-':Y.SEQ
*        CUST.REQ.ID = 'SYSTEM'
*        CALL F.WRITE(FN.REDO.CUST.REQUESTS,CUST.REQ.ID,R.REDO.CUST.REQ)
*END
    R.NEW(ISS.REQ.ALTERNATE.ID) = Y.CUST.ID:'-':VAR.CUS.SEQ.NO:'-':Y.SEQ
    CUST.REQ.ID = 'SYSTEM'
    CALL F.WRITE(FN.REDO.CUST.REQUESTS,CUST.REQ.ID,R.REDO.CUST.REQ)
RETURN
*------------------------------------------------------------------------------------------------------------
END
