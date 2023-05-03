* @ValidationCode : MjotMTI1NDIxNTM5NzpDcDEyNTI6MTY4MTgxMzI4NTA5ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:51:25
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
SUBROUTINE REDO.V.REINV.AZ.ACC.REF.TT
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.REINV.AZ.ACC.REF.TT
*--------------------------------------------------------------------------------
* Description:
*--------------------------------------------------------------------------------
*          This validation routine should be attached to the VERSION TELLER,REINV.WDL to populate
* ACCOUNT.1 field and currency
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 14-06-2010      SUJITHA.S   ODR-2009-10-0332  INITIAL CREATION
* 05-04-2011      H GANESH    N.11-PACS00030247 Changes made
* 26.06.2011     RIYAS          PACS00072695     Changes made
*23-AUG-2011     JEEVA T        PACS00072695     Changes made
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    IF Condition Added,FM TO @FM,VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.CHEQUE.PROCESS
    $INSERT I_F.REDO.APAP.REINV.CHQ.AMT
    $INSERT I_System
    $INSERT I_REDO.TELLER.PROCESS.COMMON

    GOSUB INIT
    GOSUB GET.LOC.VALUES
    GOSUB PROCESS
    GOSUB UPD.CHECK
RETURN

*--------------------------------------------------------------------------------
INIT:
*--------------------------------------------------------------------------------

    FN.AZACCOUNT='F.AZ.ACCOUNT'
    F.AZACCOUNT=''
    R.AZACCOUNT=''
    CALL OPF(FN.AZACCOUNT,F.AZACCOUNT)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    R.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN
*-----------------------------------------------------------------------------
GET.LOC.VALUES:
*----------------
* Get the Needed Local table position
*
    LOC.REF.APPL='TELLER':@FM:'ACCOUNT'
    LOC.REF.FIELDS='L.TT.ORG.DEPST':@VM:'L.TT.REINV.AMT':@FM:'L.AC.AV.BAL'
    LOC.REF.POS=" "
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.L.TT.ORG.DEPST.POS = LOC.REF.POS<1,1>
    Y.L.TT.REINV.AMT.POS = LOC.REF.POS<1,2>
    Y.L.AC.AV.BAL        = LOC.REF.POS<2,1>

RETURN
*--------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------


    Y.TT.ACC.REF = COMI
    IF COMI EQ '' THEN
        R.NEW(TT.TE.ACCOUNT.1)=''
        R.NEW(TT.TE.CURRENCY.1)=''
        R.NEW(TT.TE.LOCAL.REF)<1,Y.L.TT.ORG.DEPST.POS>=''
        R.NEW(TT.TE.LOCAL.REF)<1,Y.L.TT.REINV.AMT.POS>=''
*R.NEW(TT.TE.VALUE.DATE.1)=''
*R.NEW(TT.TE.VALUE.DATE.2)=''
        RETURN
    END

    CALL F.READ(FN.AZACCOUNT,Y.TT.ACC.REF,R.AZACCOUNT,F.AZACCOUNT,Y.ERR)
    Y.INT.LIQ.ACCT=R.AZACCOUNT<AZ.INTEREST.LIQU.ACCT>
    IF Y.INT.LIQ.ACCT THEN
        CALL F.READ(FN.ACCOUNT,Y.INT.LIQ.ACCT,R.ACCOUNT,F.ACCOUNT,Y.ERR)
        Y.FIN.INT.AMT = R.ACCOUNT<AC.LOCAL.REF,Y.L.AC.AV.BAL>

    END ELSE
        ETEXT = 'EB-REDO.REINV.INT.MISS'
        CALL STORE.END.ERROR
        RETURN
    END
    Y.FIN.DEP.AMT = R.AZACCOUNT<AZ.PRINCIPAL>
    R.NEW(TT.TE.ACCOUNT.1)=Y.INT.LIQ.ACCT
    R.NEW(TT.TE.CURRENCY.1)=R.AZACCOUNT<AZ.CURRENCY>
    R.NEW(TT.TE.LOCAL.REF)<1,Y.L.TT.ORG.DEPST.POS> = Y.FIN.DEP.AMT
    R.NEW(TT.TE.LOCAL.REF)<1,Y.L.TT.REINV.AMT.POS> = Y.FIN.INT.AMT
*R.NEW(TT.TE.VALUE.DATE.1)=TODAY
*R.NEW(TT.TE.VALUE.DATE.2)=TODAY

RETURN

*--------------------------------------------------------------------------------
UPD.CHECK:
*--------------------------------------------------------------------------------
    FN.REDO.CHEQUE.PROCESS = 'F.REDO.CHEQUE.PROCESS'
    F.REDO.CHEQUE.PROCESS = ''
    CALL OPF(FN.REDO.CHEQUE.PROCESS,F.REDO.CHEQUE.PROCESS)
    R.REDO.CHEQUE.PROCESS = ''
    Y.DATA = ""
    Y.DATA = System.getVariable("CURRENT.ID")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.DATA = ""
    END ;*R22 Auto code conversion-END

    Y.REDO.CHEQUE.PROCESS.ID=FIELD(Y.DATA,"*",1)
    CALL F.READ(FN.REDO.CHEQUE.PROCESS,Y.REDO.CHEQUE.PROCESS.ID,R.REDO.CHEQUE.PROCESS,F.REDO.CHEQUE.PROCESS,Y.ERR)
    R.REDO.CHEQUE.PROCESS<CHQ.PRO.STATUS> = 'PROCESSED'
    CALL F.WRITE(FN.REDO.CHEQUE.PROCESS,Y.REDO.CHEQUE.PROCESS.ID,R.REDO.CHEQUE.PROCESS)
    Y.DEBIT.AMOUNT = R.NEW(TT.TE.AMOUNT.LOCAL.1)
    FN.REDO.APAP.REINV.CHQ.AMT = 'F.REDO.APAP.REINV.CHQ.AMT'
    F.REDO.APAP.REINV.CHQ.AMT = ''
    R.REDO.APAP.REINV.CHQ.AMT = ''
    CALL OPF(FN.REDO.APAP.REINV.CHQ.AMT,F.REDO.APAP.REINV.CHQ.AMT)
    CALL F.READ(FN.REDO.APAP.REINV.CHQ.AMT,Y.INT.LIQ.ACCT,R.REDO.APAP.REINV.CHQ.AMT,F.REDO.APAP.REINV.CHQ.AMT,ACC.ERR)
    Y.TABLE.AMOUNT = R.REDO.APAP.REINV.CHQ.AMT<REDO.CHQ.AMOUNT>
    CHANGE @VM TO @FM IN Y.TABLE.AMOUNT
    Y.DEBIT.AMT = FIELD(Y.DEBIT.AMOUNT,'.',1)
    Y.PROCESS.ID = R.REDO.APAP.REINV.CHQ.AMT<REDO.CHQ.PROCESS.ID>
    LOCATE Y.REDO.CHEQUE.PROCESS.ID IN Y.PROCESS.ID SETTING Y.POS THEN
        R.REDO.APAP.REINV.CHQ.AMT<REDO.CHQ.STATUS,Y.POS> = 'PROCESSED'
    END
    CALL F.WRITE(FN.REDO.APAP.REINV.CHQ.AMT,Y.INT.LIQ.ACCT,R.REDO.APAP.REINV.CHQ.AMT)
RETURN
END
