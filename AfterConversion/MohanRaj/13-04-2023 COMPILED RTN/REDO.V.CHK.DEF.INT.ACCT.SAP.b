* @ValidationCode : MjotNTY5MjcwMDE3OkNwMTI1MjoxNjgxMzkwMTAwNjgyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:18:20
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
SUBROUTINE REDO.V.CHK.DEF.INT.ACCT.SAP
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as the authorisation routine for the versions following:
*
* FUNDS.TRANSFER, CHQ.TAX
* FUNDS.TRANSFER, CHQ.OTHERS
* FUNDS.TRANSFER, REVERSE.CHQ
* FUNDS.TRANSFER, REINSTATE
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date               who           Reference            Description
*   ~~~~               ~~~           ~~~~~~~~~            ~~~~~~~~~~~
* 27-MAY-2010     SHANKAR RAJU     ODR-2010-03-0447     Initial Creation
* 04.01.2010      Janani           ODR-2010-11-0229     updated for sap teller
* 19.04.2011      Janani           PACS00035999         updated for sap issue
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.ADMIN.CHQ.PARAM
    $INSERT I_F.REDO.WS.APAP.CATEG.PARAM
    $INSERT I_F.REDO.APAP.WS.PARAM

    GOSUB INITIALISE
    IF V$FUNCTION EQ 'A' OR V$FUNCTION EQ 'S' OR V$FUNCTION EQ 'R' THEN
        GOSUB END.PGM
    END
    IF MESSAGE EQ 'VAL' THEN
        GOSUB END.PGM
    END
    GOSUB PROCESS
    GOSUB READ.ALL.ACCOUNT
RETURN
*--------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
    FN.CATEG.INT.ACCT = 'F.CATEG.INT.ACCT'
    F.CATEG.INT.ACCT = ''
    R.CATEG.INT.ACCT = ''

    FN.REDO.ADMIN.CHQ.PARAM = 'F.REDO.ADMIN.CHQ.PARAM'
    F.REDO.ADMIN.CHQ.PARAM = ''

    FN.APAP.CATEG.PARAM = 'F.REDO.WS.APAP.CATEG.PARAM'
    F.APAP.CATEG.PARAM = ''

    CALL OPF(FN.CATEG.INT.ACCT,F.CATEG.INT.ACCT)
    CALL OPF(FN.REDO.ADMIN.CHQ.PARAM,F.REDO.ADMIN.CHQ.PARAM)
    CALL OPF(FN.APAP.CATEG.PARAM,F.APAP.CATEG.PARAM)

    FN.REDO.APAP.WS.PARAM = 'F.REDO.APAP.WS.PARAM'
    F.REDO.APAP.WS.PARAM = ''
    CALL OPF(FN.REDO.APAP.WS.PARAM,F.REDO.APAP.WS.PARAM)

RETURN
*--------------------------------------------------------------------------
PROCESS:
*~~~~~~~

*    BEGIN CASE
*    CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",CHQ.NO.TAX.SAP")
*       Y.CATEGORY = '15006'
*  CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",CHQ.OTHERS.SAP")
*     Y.CATEGORY ='15005'
*END CASE

    CALL CACHE.READ(FN.APAP.CATEG.PARAM,"SYSTEM",R.APAP.CATEG.PARAM,ERR.CATEG)

    Y.PARAM.VERSION = R.APAP.CATEG.PARAM<REDO.WS.CATEG.VERSION.NAME>
    Y.TOTO.VERSION = DCOUNT(Y.PARAM.VERSION,@VM)
    Y.TOT = 1
    LOOP
    WHILE Y.TOTO.VERSION GE Y.TOT

        Y.IN.VERSION = Y.PARAM.VERSION<1,Y.TOT>
        PGM.VERSION.COMP = APPLICATION:PGM.VERSION
        IF PGM.VERSION.COMP EQ Y.IN.VERSION THEN
            Y.CATEGORY = R.APAP.CATEG.PARAM<REDO.WS.CATEG.CATEGORY><1,Y.TOT>
            Y.TOT += 1
        END
        Y.TOT += 1
    REPEAT

* assigning auto new content value to the corresponding fields from the param table

*PACS00035999 -S
    CALL CACHE.READ(FN.REDO.APAP.WS.PARAM,"SYSTEM",R.REDO.APAP.WS.PARAM,REA.ERR)
*PACS00035999 -E
    Y.VER = R.REDO.APAP.WS.PARAM<REDO.APAP.WS.VERSION.NAME>
    LOOP.CNT = 1
    LOCATE PGM.VERSION IN Y.VER<1,1> SETTING VER.POS THEN
        Y.FIELD.NAME = R.REDO.APAP.WS.PARAM<REDO.APAP.WS.AUTOM.FIELD.NO,VER.POS>
        Y.AUTO = R.REDO.APAP.WS.PARAM<REDO.APAP.WS.AUT.NEW.CONTENT,VER.POS>

        LOOP
            REMOVE I.FIELD.NAME FROM Y.FIELD.NAME SETTING LOOP.POS
        WHILE I.FIELD.NAME:LOOP.POS
            I.FIELD.NAME = R.REDO.APAP.WS.PARAM<REDO.APAP.WS.AUTOM.FIELD.NO,VER.POS,LOOP.CNT>
            I.AUTO = R.REDO.APAP.WS.PARAM<REDO.APAP.WS.AUT.NEW.CONTENT,VER.POS,LOOP.CNT>
            Y.LOC = FIELD(I.FIELD.NAME,'-',1)
            IF Y.LOC EQ 'LOCAL.REF' THEN
                LF.POS = FIELD(I.FIELD.NAME,'-',2)
                R.NEW(FT.LOCAL.REF)<1,LF.POS> = I.AUTO
            END ELSE
                Y.F.POS = I.FIELD.NAME
                CALL EB.GET.APPL.FIELD(APPLICATION,Y.F.POS,APPL.SS,ERR.MSG)
                IF I.AUTO EQ 'TODAY' OR I.AUTO EQ '!TODAY' THEN
                    R.NEW(Y.F.POS) = TODAY
                END ELSE
                    R.NEW(Y.F.POS) = I.AUTO
                END
            END
            LOOP.CNT += 1
        REPEAT
    END

RETURN
*--------------------------------------------------------------------------
READ.ALL.ACCOUNT:
*--------------------------------------------------------------------------
    Y.ADMIN.ID = 'SYSTEM'
*  CALL F.READ(FN.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ID,R.REDO.ADMIN.CHQ.PARAM,F.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ERR) ;*Tus Start
    CALL CACHE.READ(FN.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ID,R.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ERR) ; * Tus End
    Y.ACCOUNT.ALL = R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ACCOUNT>
    LOOP
        REMOVE Y.ACCT.ID FROM Y.ACCOUNT.ALL SETTING POS1
    WHILE Y.ACCT.ID:POS1
        Y.VALUE = Y.ACCT.ID[4,5]
        IF Y.VALUE EQ Y.CATEGORY THEN
            Y.ACCOUNT = Y.ACCT.ID
            R.NEW(FT.CREDIT.ACCT.NO) = Y.ACCOUNT

            CALL APAP.REDOVER.REDO.V.VAL.ITEM.CODE

            BREAK
        END
    REPEAT
RETURN

END.PGM:
*********
END
