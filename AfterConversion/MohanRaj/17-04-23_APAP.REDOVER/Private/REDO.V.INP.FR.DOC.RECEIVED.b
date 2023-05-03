* @ValidationCode : MjotMTM3MDMxNjkyOTpDcDEyNTI6MTY4MTcyODYyNTM3MDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:20:25
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
SUBROUTINE REDO.V.INP.FR.DOC.RECEIVED
*---------------------------------------------------------------------------------
*This is an input routine for the version REDO.FRONT.REQUESTS,NEW. It will change
*the next next version based on DOC.RECEIVED
*----------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : Pradeep S
* Program Name  : REDO.V.INP.FR.DOC.RECEIVED
* ODR NUMBER    :
* HD Reference  : PACS00060849
*LINKED WITH: REDO.FRONT.REQUESTS
*----------------------------------------------------------------------
*Input param = none
*output param =none
*-----------------------------------------------------------------------
*MODIFICATION DETAILS:
* Date              Name             Reference           Description
* 16-02-2011        Pradeep S        PACS00060849        Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    $INSERT I_GTS.COMMON
    $INSERT I_F.VERSION
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.REDO.FRONT.REQUESTS

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

OPEN.FILES:
************

    FN.CUS.ACCT = 'F.CUSTOMER.ACCOUNT'
    F.CUS.ACCT = ''
    CALL OPF(FN.CUS.ACCT,F.CUS.ACCT)

    FN.JOINT.CONTRACTS.XREF = 'F.JOINT.CONTRACTS.XREF'
    F.JOINT.CONTRACTS.XREF = ''
    CALL OPF(FN.JOINT.CONTRACTS.XREF,F.JOINT.CONTRACTS.XREF)

RETURN

PROCESS:
*********

    Y.DOC.NAME     = R.NEW(FR.CM.DOC.NAME)
    Y.DOC.RECEIVED = R.NEW(FR.CM.DOC.REV)
    IF Y.DOC.NAME THEN
        GOSUB CHECK.DOCS.REV
        GOSUB CHECK.DOCS
    END

    Y.CUST.NO = R.NEW(FR.CM.CUSTOMER.CODE)
    Y.ACCT.NO = R.NEW(FR.CM.ACCOUNT.ID)
    Y.CARD.NO = R.NEW(FR.CM.CARD.NO)

    IF Y.ACCT.NO THEN
        R.CUS.ACCT = ''
        CALL F.READ(FN.CUS.ACCT,Y.CUST.NO,R.CUS.ACCT,F.CUS.ACCT,CUS.ERR)
        CALL F.READ(FN.JOINT.CONTRACTS.XREF,Y.CUST.NO,R.JOIN.CUS,F.JOINT.CONTRACTS.XREF,ERR.JOIN)
        R.CUST.ACCOUNT = R.CUS.ACCT:@FM:R.JOIN.CUS
        LOCATE Y.ACCT.NO IN R.CUST.ACCOUNT SETTING ACC.POS ELSE
            AF = FR.CM.ACCOUNT.ID
            ETEXT = 'EB-NO.CUST.ACCT'
            CALL STORE.END.ERROR
        END
    END
RETURN

*--------------------------------------------------------
CHECK.DOCS.REV:
*--------------------------------------------------------

    LOCATE "" IN Y.DOC.RECEIVED<1,1> SETTING REV.POS THEN
        AF = FR.CM.DOC.REV
        AV = REV.POS
        ETEXT = 'EB-MAND.INP'
        CALL STORE.END.ERROR
    END

RETURN
*--------------------------------------------------------
CHECK.DOCS:
*--------------------------------------------------------
    LOCATE 'NO' IN Y.DOC.RECEIVED<1,1> SETTING DOC.POS THEN
        R.VERSION(EB.VER.NEXT.VERSION) = ''
        R.NEW(FR.CM.STATUS)='DOCUMENT.PENDING'
    END ELSE
        R.NEW(FR.CM.STATUS)=''
    END
RETURN
*--------------
END
