* @ValidationCode : MjotMTI2NjU3NjcyNDpDcDEyNTI6MTY4MTMwMDQ5NDEyNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:24:54
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
SUBROUTINE REDO.V.AUT.REQUEST.LOG.UPDATE
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : This Auth routine to update the CR.CONTACT.LOG table
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RENUGADEVI B
* PROGRAM NAME : REDO.V.AUT.REQUEST.LOG.UPDATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE              WHO                REFERENCE         DESCRIPTION
* 25-AUG-2010       RENUGADEVI B       ODR-2009-12-0283  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CR.CONTACT.LOG
    $INSERT I_F.CUSTOMER
    $INSERT I_F.LOCKING
    $INSERT I_F.PW.PARTICIPANT
    $INSERT I_F.REDO.ISSUE.REQUESTS

    GOSUB INIT
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    R.CR.CONTACT.LOG             = ''
    FN.PW.PARTICIPANT            = 'F.PW.PARTICIPANT'
    F.PW.PARTICIPANT             = ''
    CALL OPF(FN.PW.PARTICIPANT,F.PW.PARTICIPANT)

    FN.REDO.ISSUE.REQUESTS         = 'F.REDO.ISSUE.REQUESTS'
    F.REDO.ISSUE.REQUESTS          = ''
    CALL OPF(FN.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS)

    FN.CR.CONTACT.LOG            = 'F.CR.CONTACT.LOG'
    F.CR.CONTACT.LOG             = ''
    CALL OPF(FN.CR.CONTACT.LOG, F.CR.CONTACT.LOG)

    FN.CUSTOMER                  = 'F.CUSTOMER'
    F.CUSTOMER                   = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    LREF.APPL                    = 'CR.CONTACT.LOG'
    LREF.FIELDS                  = 'L.CR.PROD.REQ':@VM:'L.CR.SER.REQ':@VM:'L.CR.INFOR.REQ':@VM:'L.CR.DUE.DATE':@VM:'L.CR.SUPP.GRP':@VM:'L.CR.STATUS':@VM:'L.CR.TYPE':@VM:'L.CR.USER':@VM:'L.CR.CUST.ID'
    LREF.POS                     = ''
    CALL MULTI.GET.LOC.REF(LREF.APPL, LREF.FIELDS, LREF.POS)
    L.CR.PROD.REQ.POS            = LREF.POS<1,1>
    L.CR.SER.REQ.POS             = LREF.POS<1,2>
    L.CR.INFOR.REQ.POS           = LREF.POS<1,3>
    L.CR.DUE.DATE.POS            = LREF.POS<1,4>
    L.CR.SUPP.GRP.POS            = LREF.POS<1,5>
    L.CR.STATUS.POS              = LREF.POS<1,6>
    L.CR.TYPE.POS                = LREF.POS<1,7>
    L.CR.USER.POS                = LREF.POS<1,8>
    L.CR.CUST.ID.POS             = LREF.POS<1,9>

RETURN

********
PROCESS:
********

    Y.ID.NEW           = ID.NEW
    Y.CASE.ID1 = FIELD(Y.ID.NEW,'.',1)
    Y.CASE.ID2 = FIELD(Y.ID.NEW,'.',2)
    Y.CASE.ID3 = FIELD(Y.ID.NEW,'.',3)
    Y.CASE.ID = Y.CASE.ID1:Y.CASE.ID2:Y.CASE.ID3
    Y.SAM.TIME            = TIMEDATE()
    Y.TIME                = Y.SAM.TIME[1,5]
    Y.CUST                = R.NEW(ISS.REQ.CUSTOMER.CODE)
    CALL F.READ(FN.CUSTOMER, Y.CUST, R.CUSTOMER, F.CUSTOMER, CUST.ERR)
    IF R.CUSTOMER THEN
        Y.CUST.NAME         = R.CUSTOMER<EB.CUS.NAME.1>
    END
    Y.DUE.DATE            = R.NEW(ISS.REQ.DATE.RESOLUTION)
    Y.SUPP.GRP            = R.NEW(ISS.REQ.SUPPORT.GROUP)
    Y.STATUS              = R.NEW(ISS.REQ.STATUS)
    Y.TYPE                = R.NEW(ISS.REQ.TYPE)
    Y.CHANNEL             = R.NEW(ISS.REQ.OPENING.CHANNEL)
    Y.USER                = R.NEW(ISS.REQ.INPUTTER)
    Y.CUSTOMER.ID         = R.NEW(ISS.REQ.CUST.ID.NUMBER)
    GOSUB LOG.UPDATE
RETURN

************
LOG.UPDATE:
************
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.CLIENT>                = Y.CUST
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.STATUS>                = 'NEW'
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.TYPE>                  = Y.TYPE
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.DESC>                  = Y.TYPE
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.CHANNEL>               = Y.CHANNEL
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.DATE>                  = TODAY
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTRACT.ID>                   = Y.CASE.ID
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.TIME>                  = Y.TIME
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.NOTES>                 = ''
* R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.STAFF>                = OPERATOR
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.SUPP.GRP.POS>   = Y.SUPP.GRP

    CALL F.READ(FN.PW.PARTICIPANT,Y.SUPP.GRP,R.PARTICIPANT,F.PW.PARTICIPANT,PAR.ERR)
    Y.PART.USER                                                 = R.PARTICIPANT<PW.PART.USER>
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.USER.POS>       = Y.PART.USER
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.STATUS.POS>     = Y.STATUS
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.TYPE.POS>       = Y.TYPE
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.PROD.REQ.POS>   = ''
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.SER.REQ.POS>    = 'REQUEST'
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.INFOR.REQ.POS>  = ''
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.CUST.ID.POS>    = Y.CUSTOMER.ID

    OFS.SOURCE.ID            = 'OFS.LOG.UPDATE'

    APPLICATION.NAME         = 'CR.CONTACT.LOG'
    TRANS.FUNC.VAL           = 'I'
    TRANS.OPER.VAL           = 'PROCESS'
    APPLICATION.NAME.VERSION = 'CR.CONTACT.LOG,LOG.INTERACT'
    NO.AUT                   = '0'
    OFS.MSG.ID               = ''
    APPLICATION.ID           = ''
    OFS.POST.MSG             = ''

    CALL OFS.BUILD.RECORD(APPLICATION.NAME,TRANS.FUNC.VAL,TRANS.OPER.VAL,APPLICATION.NAME.VERSION,"",NO.AUT,APPLICATION.ID,R.CR.CONTACT.LOG,OFS.REQ.MSG)
    CALL OFS.POST.MESSAGE(OFS.REQ.MSG,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
RETURN
END
