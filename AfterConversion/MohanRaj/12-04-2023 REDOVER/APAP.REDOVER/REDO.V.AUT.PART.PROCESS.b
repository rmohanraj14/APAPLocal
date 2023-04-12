* @ValidationCode : MjoxODM3OTYxMDA2OkNwMTI1MjoxNjgxMjg2NDc0MTMyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:31:14
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
SUBROUTINE REDO.V.AUT.PART.PROCESS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is an authorisation routine attached to below versions,
*TELLER,COLLECT.AA.REPAY

* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 28-06-2010        Sudharsanan S  ODR-2010-08-0017    Initial Creation
* 10-11-2010        JEEVA T        ODR-2010-08-0017    Baselined after few logic changes
* 10-08-2010        Sudharsanan S  PACS00094144
* 15-10-2011        Marimuthu S    PACS00126000
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     = TO EQ
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.VERSION
    $INSERT I_F.REDO.PART.TT.PROCESS
    $INSERT I_F.REDO.PART.TT.REJECT
    $INSERT I_F.REDO.MULTI.TXN.PROCESS
    $INSERT I_F.REDO.MULTI.TXN.REJECT
    $INSERT I_F.MULTI.TRANSACTION.SERVICE


    GOSUB INIT

    GOSUB PROCESS
RETURN

******
INIT:
******
*Initialize all the variables


    FN.MULTI.TRANSACTION.SERVICE = 'F.MULTI.TRANSACTION.SERVICE'
    F.MULTI.TRANSACTION.SERVICE = ''
    CALL OPF(FN.MULTI.TRANSACTION.SERVICE,F.MULTI.TRANSACTION.SERVICE)

    FN.REDO.PART.TT.PROCESS='F.REDO.PART.TT.PROCESS'
    F.REDO.PART.TT.PROCESS=''
    CALL OPF(FN.REDO.PART.TT.PROCESS,F.REDO.PART.TT.PROCESS)

    FN.REDO.PART.TT.REJECT='F.REDO.PART.TT.REJECT'
    F.REDO.PART.TT.REJECT=''
    CALL OPF(FN.REDO.PART.TT.REJECT,F.REDO.PART.TT.REJECT)

    FN.REDO.MULTI.TXN.PROCESS ='F.REDO.MULTI.TXN.PROCESS'
    F.REDO.MULTI.TXN.PROCESS   =''
    CALL OPF(FN.REDO.MULTI.TXN.PROCESS,F.REDO.MULTI.TXN.PROCESS)

    FN.REDO.MULTI.TXN.REJECT = 'F.REDO.MULTI.TXN.REJECT'
    F.REDO.MULTI.TXN.REJECT = ''
    CALL OPF(FN.REDO.MULTI.TXN.REJECT,F.REDO.MULTI.TXN.REJECT)

* PACS00126000 - S
    LREF.APPLICATION='FUNDS.TRANSFER'
    LREF.FIELDS='L.FT.DUE.PRS'
* PACS00126000 - E
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APPLICATION,LREF.FIELDS,LREF.POS)
    VAR.FT.ID=LREF.POS<1,1>
    VAR.MULTI.PROCESS.ID = ''

RETURN
*********
PROCESS:
*********
* Removal of Transaction ID from the local table

    VAR.NO.OF.AUTH = R.VERSION(EB.VER.NO.OF.AUTH)
    IF VAR.NO.OF.AUTH EQ '0' THEN
* PACS00126000 -S
        IF APPLICATION EQ 'FUNDS.TRANSFER' AND (V$FUNCTION EQ "I" OR V$FUNCTION EQ "A") THEN ;*R22 Auto code conversion
            TT.ID =R.NEW(FT.LOCAL.REF)<1,VAR.FT.ID>
            CALL F.DELETE(FN.REDO.PART.TT.PROCESS,TT.ID)
* PACS00126000 -E
        END
        IF APPLICATION EQ 'REDO.PART.TT.REJECT' AND V$FUNCTION EQ "I" AND PGM.VERSION EQ ",CREATE" THEN
            CALL F.DELETE(FN.REDO.PART.TT.PROCESS,ID.NEW)
        END
    END ELSE
* PACS00126000 -S
        IF APPLICATION EQ 'FUNDS.TRANSFER' AND V$FUNCTION EQ "A" THEN
            TT.ID = R.NEW(FT.LOCAL.REF)<1,VAR.FT.ID>
* PACS00126000 -E
            CALL F.DELETE(FN.REDO.PART.TT.PROCESS,TT.ID)
        END
        IF APPLICATION EQ 'REDO.PART.TT.REJECT' AND V$FUNCTION EQ "A" AND PGM.VERSION EQ ",CREATE" THEN
            CALL F.DELETE(FN.REDO.PART.TT.PROCESS,ID.NEW)
        END
    END

    IF APPLICATION EQ 'REDO.PART.TT.REJECT' AND PGM.VERSION EQ ",REJECT" THEN
        CALL F.DELETE(FN.REDO.PART.TT.REJECT,ID.NEW)
    END

    IF APPLICATION EQ 'REDO.PART.TT.PROCESS' AND PGM.VERSION EQ ',MODIFY' THEN
        CALL F.DELETE(FN.REDO.PART.TT.REJECT,ID.NEW)
    END

    IF APPLICATION EQ 'MULTI.TRANSACTION.SERVICE' AND PGM.VERSION EQ ",TXN" THEN
        VAR.MULTI.PROCESS.ID = R.NEW(REDO.MTS.RESERVED.1)
        IF VAR.MULTI.PROCESS.ID THEN
            CALL F.DELETE(FN.REDO.MULTI.TXN.PROCESS,VAR.MULTI.PROCESS.ID)
        END
    END

    IF APPLICATION EQ 'REDO.MULTI.TXN.REJECT' AND V$FUNCTION EQ "I" AND PGM.VERSION EQ ",CREATE" THEN
        CALL F.DELETE(FN.REDO.MULTI.TXN.PROCESS,ID.NEW)
    END

    IF APPLICATION EQ 'REDO.MULTI.TXN.REJECT' AND PGM.VERSION EQ ",REJECT" THEN
        CALL F.DELETE(FN.REDO.MULTI.TXN.REJECT,ID.NEW)
    END

    IF APPLICATION EQ 'REDO.MULTI.TXN.PROCESS' AND PGM.VERSION EQ ',MODIFY' THEN
        CALL F.DELETE(FN.REDO.MULTI.TXN.REJECT,ID.NEW)
    END

RETURN
*******************************************************************************************
END
