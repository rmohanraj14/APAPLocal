* @ValidationCode : MjoxMTQ1ODYyNzk2OkNwMTI1MjoxNjgxMzAwOTgwODY4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:33:00
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
SUBROUTINE REDO.V.AUT.STATUS.CHANGE
*-----------------------------------------------------------------------------

*------------
*DESCRIPTION:
*------------
* This Routine is attached as authorization routine in VERSION.CONTROL of CUST.DOCUMENT
*application.This routine reverse the EB.SECURE.MESSAGE generated for doument not received
*and deletes the entry in REDO.MSG.DET for the customer when STATUS in CUST.DOCUMENT is
*set to 1 (received)

*--------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-

*--------------
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-

*------------------
* Revision History:
*------------------
*   Date               who           Reference            Description
* 11-FEB-2010        Prabhu.N       ODR-2009-12-0279    Initial Creation
* 09 AUG 2011        Prabhu.N       PACS00100804        PACS PACS00100804-Received to not received added
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EB.SECURE.MESSAGE
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.REDO.T.MSG.DET
    $INSERT I_F.REDO.MSG.PARAMETER

    GOSUB INIT
    GOSUB PROCESS
RETURN
*----
INIT:
*----
    FN.REDO.T.MSG.DET='F.REDO.T.MSG.DET'
    F.REDO.T.MSG.DET=''
    CALL OPF(FN.REDO.T.MSG.DET,F.REDO.T.MSG.DET)
    FN.MSG.PARAMETER='F.REDO.MSG.PARAMETER'

RETURN
*-------
PROCESS:
*-------
    IF R.NEW(CUS.DOC.STATUS) EQ 1 AND R.OLD(CUS.DOC.STATUS) NE 1 THEN
        Y.CUSTOMER.ID=SWAP(ID.NEW, '*ACTDATOS', '')
        CALL F.READ(FN.REDO.T.MSG.DET,Y.CUSTOMER.ID,R.MSG.DET,F.REDO.T.MSG.DET,ERR)

        IF R.MSG.DET NE '' THEN
            R.SECURE.MSG=''
            TRANS.FUNC.VAL='R'
            APPLICATION.NAME.VERSION='EB.SECURE.MESSAGE,MSG.REV'
            OFS.SOURCE.ID = 'REDO.MSG.UPD'
            APPLICATION.NAME = 'EB.SECURE.MESSAGE'
            TRANS.OPER.VAL = 'PROCESS'
            NO.AUT = ''
            OFS.MSG.ID = ''
            APPLICATION.ID = R.MSG.DET
            OFS.REQ.MSG = ''
            CALL OFS.BUILD.RECORD(APPLICATION.NAME,TRANS.FUNC.VAL,TRANS.OPER.VAL,APPLICATION.NAME.VERSION,"",NO.AUT,APPLICATION.ID,R.SECURE.MSG,OFS.REQ.MSG)
            CALL OFS.POST.MESSAGE(OFS.REQ.MSG,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
            CALL F.DELETE(FN.REDO.T.MSG.DET,Y.CUSTOMER.ID)
        END

    END
*PACS00100804-S
    IF R.NEW(CUS.DOC.STATUS) EQ 2 AND R.OLD(CUS.DOC.STATUS) NE 2 THEN
        Y.CUSTOMER.ID=SWAP(ID.NEW, '*ACTDATOS', '')
        CALL F.READ(FN.REDO.T.MSG.DET,Y.CUSTOMER.ID,R.MSG.DET,F.REDO.T.MSG.DET,ERR)
        IF R.MSG.DET EQ '' THEN
            CALL CACHE.READ(FN.MSG.PARAMETER,'SYSTEM',R.MSG.PARM,ERR)
            R.SECURE.MSG=''
            R.SECURE.MSG<EB.SM.TO.CUSTOMER> =Y.CUSTOMER.ID
            R.SECURE.MSG<EB.SM.SUBJECT>=R.MSG.PARM<MG.SUBJECT>
            R.SECURE.MSG<EB.SM.MESSAGE>=R.MSG.PARM<MG.TEXT>
            TRANS.FUNC.VAL = 'I'
            APPLICATION.ID = ''
            APPLICATION.NAME.VERSION = 'EB.SECURE.MESSAGE,MSG.INPUT'
            OFS.SOURCE.ID = 'REDO.MSG.UPD'
            APPLICATION.NAME = 'EB.SECURE.MESSAGE'
            TRANS.OPER.VAL = 'PROCESS'
            NO.AUT = ''
            OFS.MSG.ID = ''
            OFS.REQ.MSG = ''
            CALL OFS.BUILD.RECORD(APPLICATION.NAME,TRANS.FUNC.VAL,TRANS.OPER.VAL,APPLICATION.NAME.VERSION,"",NO.AUT,APPLICATION.ID,R.SECURE.MSG,OFS.REQ.MSG)
            CALL OFS.POST.MESSAGE(OFS.REQ.MSG,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
        END
    END
*PACS00100804-E
RETURN
END
