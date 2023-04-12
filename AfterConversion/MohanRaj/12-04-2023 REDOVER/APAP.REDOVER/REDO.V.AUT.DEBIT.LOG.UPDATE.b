* @ValidationCode : MjotMzU0NzcxODQ2OkNwMTI1MjoxNjgxMjg1MjIxNTI5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:10:21
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
SUBROUTINE REDO.V.AUT.DEBIT.LOG.UPDATE
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : This Auth routine is used to Update the Log CR.CONTACT.LOG table
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RENUGADEVI B
* PROGRAM NAME : REDO.V.AUT.LETTER.LOG.UPDATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE              WHO                REFERENCE         DESCRIPTION
* 25-AUG-2010       RENUGADEVI B       ODR-2009-12-0283  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CR.CONTACT.LOG
    $INSERT I_F.LATAM.CARD.ORDER

    GOSUB INIT
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    R.CR.CONTACT.LOG             = ''
    FN.LATAM.CARD.ORDER = 'F.LATAM.CARD.ORDER'
    F.LATAM.CARD.ORDER = ''
    CALL OPF(FN.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER)

    FN.CR.CONTACT.LOG            = 'F.CR.CONTACT.LOG'
    F.CR.CONTACT.LOG             = ''
    CALL OPF(FN.CR.CONTACT.LOG, F.CR.CONTACT.LOG)

    LREF.APPL                    = 'CR.CONTACT.LOG'
    LREF.FIELDS                  = 'L.CR.SER.REQ'
    LREF.POS                     = ''
    CALL MULTI.GET.LOC.REF(LREF.APPL, LREF.FIELDS, LREF.POS)
    L.CR.SER.REQ.POS             = LREF.POS<1,1>

RETURN
********
PROCESS:
********
    Y.ID.NEW              = ID.NEW
    Y.ID1                 = FIELD(Y.ID.NEW,'.',1)
    Y.ID2                 = FIELD(Y.ID.NEW,'.',2)
    Y.ID                  = Y.ID1:Y.ID2
    Y.SAM.TIME            = TIMEDATE()
    Y.TIME                = Y.SAM.TIME[1,5]
    Y.CUST.ID             = R.NEW(CARD.IS.CUSTOMER.NO)<1,1>
    IF NOT(Y.CUST.ID) THEN
        Y.CUST.ID          = R.NEW(CARD.IS.CUSTOMER.NO)<1,2>
    END
    Y.INPUTTER            = R.NEW(CARD.IS.INPUTTER)
    Y.USER                = FIELD(Y.INPUTTER,'-',2)
    GOSUB UPDATE.LOG

RETURN
***********
UPDATE.LOG:
***********
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.CLIENT>             = Y.CUST.ID
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.STATUS>             = "NEW"
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.TYPE>               = "AUTOMATICO"
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.DESC>               = "DEBIT"
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.CHANNEL>            = "BRANCH"
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.DATE>               = TODAY
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.TIME>               = Y.TIME
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTRACT.ID>                = Y.ID
    R.CR.CONTACT.LOG<CR.CONT.LOG.CONTACT.STAFF>              = Y.USER
    R.CR.CONTACT.LOG<CR.CONT.LOG.LOCAL.REF,L.CR.SER.REQ.POS> = 'DEBIT'

    CALL CR.WRITE.CONTACT.LOG(R.CR.CONTACT.LOG)

RETURN
END
