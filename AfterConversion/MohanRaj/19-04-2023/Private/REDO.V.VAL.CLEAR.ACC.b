* @ValidationCode : MjotMTA2MzQwNTA2ODpDcDEyNTI6MTY4MTg4NzEzNjM0Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:22:16
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
SUBROUTINE REDO.V.VAL.CLEAR.ACC
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Shankar Raju
* Program Name  : REDO.V.VAL.CLEAR.ACC
*-------------------------------------------------------------------------
* Description: This routine is a Check rec routine to default the debit account number
*              from REDO.APAP.CLEAR.PARAM
*----------------------------------------------------------
* In parameter :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*--------------------------------------------
*   DATE              ODR                             DESCRIPTION
* 19-05-11          PACS00055026                  To default the clearing account
*                   PACS00055031
*                   PACS00056666
*                   PACS00055020
* 30-04-2013        PACS00266084 (arundev)        map UNIV.CLEAR.ACCT instead of CAT.ACH.ACCT
* 18-02-2014        PACS00344327 (vignesh)        USD CHEQUE ACCOUNT MUST BE OF THE SAME CCY
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER

    $INSERT I_F.REDO.APAP.CLEAR.PARAM
    $INSERT I_F.REDO.TELLER.PROCESS

    GOSUB OPEN.FILE
    GOSUB PROCESS
RETURN

*----------
OPEN.FILE:
*---------
*Opening Files

    FN.REDO.APAP.PARAM = 'F.REDO.APAP.CLEAR.PARAM'
    F.REDO.APAP.PARAM = ''
    CALL OPF(FN.REDO.APAP.PARAM,F.REDO.APAP.PARAM)

    FN.REDO.TELLER.PROCESS = 'F.REDO.TELLER.PROCESS'
    F.REDO.TELLER.PROCESS = ''
    CALL OPF(FN.REDO.TELLER.PROCESS,F.REDO.TELLER.PROCESS)

RETURN
*-------
PROCESS:
*-------
*Read the REDO.APAP.CLEAR.PARAM table and get the Account Number

    CALL CACHE.READ(FN.REDO.APAP.PARAM,'SYSTEM',R.REDO.APAP.PARAM,PARAM.ERR)

*PACS00266084-start
*CLR.ACC = R.REDO.APAP.PARAM<CLEAR.PARAM.CAT.ACH.ACCT>
    CLR.ACC = R.REDO.APAP.PARAM<CLEAR.PARAM.UNIV.CLEAR.ACCT>
*PACS00266084-end

* Fix for PACS00344327 [USD CHEQUE ACCOUNT MUST BE OF THE SAME CCY]

    LOC.REF.APPL = 'TELLER'
    LOC.REF.FLDS = 'L.TT.PROCESS'
    LOC.REF.POSS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FLDS,LOC.REF.POSS)

    Y.GET.RTP.ID = R.NEW(TT.TE.LOCAL.REF)<1,LOC.REF.POSS>
    CALL F.READ(FN.REDO.TELLER.PROCESS,Y.GET.RTP.ID,R.REDO.TELLER.PROCESS,F.REDO.TELLER.PROCESS,REDO.TELLER.PROCESS.ERR)
    Y.RTP.CURRENCY = R.REDO.TELLER.PROCESS<TEL.PRO.CURRENCY>
    Y.RPT.TYPE = R.REDO.TELLER.PROCESS<TEL.PRO.PAYMENT.TYPE>

    IF Y.RTP.CURRENCY EQ 'USD' AND Y.RPT.TYPE EQ 'CHEQUE' THEN
        CLR.ACC = R.REDO.APAP.PARAM<CLEAR.PARAM.UNIV.CLR.USAC>
    END

* End of Fix

    IF PGM.VERSION EQ ",SERVICE.CHQ.CREATE" THEN
        R.NEW(TT.TE.ACCOUNT.2) = CLR.ACC
    END ELSE
        R.NEW(TT.TE.ACCOUNT.1) = CLR.ACC
    END

RETURN

END
