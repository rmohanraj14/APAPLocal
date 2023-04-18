* @ValidationCode : MjotMTk1MDY2NjY2OkNwMTI1MjoxNjgxODEzODg1NTY2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:01:25
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
SUBROUTINE REDO.V.REINV.AZ.ACC.REF.FT
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.REINV.AZ.ACC.REF.FT
*--------------------------------------------------------------------------------
* Description:
*--------------------------------------------------------------------------------
*            This validation routine is be attached to the VERSION FUNDS.TRANSFER,REINV.WDL
* to populate DEBIT.ACCOUNT number and currency
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 14-06-2010      SUJITHA.S   ODR-2009-10-0332  INITIAL CREATION
* 05-04-2011      H GANESH    N.11-PACS00030247 Changes made
* 26.06.2011     RIYAS          PACS00072695     Changes made
* 22-AUG-2011     JEEVA T      PACS00103288       changes made (DRAFT.CHECK)
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER


    GOSUB INIT
    GOSUB GET.LOC.VALUES
    GOSUB PROCESS
*    GOSUB DRAFT.CHECK
RETURN

*---------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------

    FN.AZACCOUNT='F.AZ.ACCOUNT'
    F.AZACCOUNT=''
    R.AZACCOUNT=''
    CALL OPF(FN.AZACCOUNT,F.AZACCOUNT)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    R.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CUSTOMER='F.CUSTOMER'
    F.CUSTOMER=''
    R.CUSTOMER=''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    Y.VAL.DRAFT = ''

RETURN

*-----------------------------------------------------------------------------
DRAFT.CHECK:
*-----------------------------------------------------------------------------

    Y.VAL.DRAFT = R.NEW(FT.CREDIT.THEIR.REF)
    IF NOT(Y.VAL.DRAFT) THEN
        AF = FT.CREDIT.THEIR.REF
        ETEXT = 'AC-INP.MISS'
        CALL STORE.END.ERROR
    END
RETURN
*-----------------------------------------------------------------------------
GET.LOC.VALUES:
*----------------
* Get the Needed Local table position
*
    LOC.REF.APPL="FUNDS.TRANSFER":@FM:'ACCOUNT'
    LOC.REF.FIELDS='L.FT.REINV.AMT':@VM:'L.FT.ORG.DEPST':@VM:'BENEFIC.NAME':@FM:'L.AC.AV.BAL'
    LOC.REF.POS=" "
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.L.REIVSD.INT.POS     = LOC.REF.POS<1,1>
    Y.L.ORG.DP.AMT.POS     = LOC.REF.POS<1,2>
    POS.BENEFIC.NAME       = LOC.REF.POS<1,3>
    Y.L.AC.AV.BAL          = LOC.REF.POS<2,1>


RETURN
*--------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------

    Y.FT.ACC.REF=COMI
    IF COMI EQ '' THEN
        R.NEW(FT.DEBIT.ACCT.NO)  = ''
        R.NEW(FT.DEBIT.CURRENCY) = ''
        R.NEW(FT.LOCAL.REF)<1,Y.L.ORG.DP.AMT.POS> = ''
        R.NEW(FT.LOCAL.REF)<1,Y.L.REIVSD.INT.POS> = ''
*R.NEW(FT.DEBIT.VALUE.DATE)=''
*R.NEW(FT.CREDIT.VALUE.DATE)=''
        RETURN
    END
    CALL F.READ(FN.AZACCOUNT,Y.FT.ACC.REF,R.AZACCOUNT,F.AZACCOUNT,Y.ERR)
    Y.INT.LIQ.ACCT = R.AZACCOUNT<AZ.INTEREST.LIQU.ACCT>
    IF Y.INT.LIQ.ACCT THEN
        CALL F.READ(FN.ACCOUNT,Y.INT.LIQ.ACCT,R.ACCOUNT,F.ACCOUNT,Y.ERR)
        Y.FIN.INT.AMT = R.ACCOUNT<AC.LOCAL.REF,Y.L.AC.AV.BAL>
    END ELSE
        ETEXT = 'EB-REDO.REINV.INT.MISS'
        CALL STORE.END.ERROR
        RETURN
    END
    Y.FIN.DEP.AMT  = R.AZACCOUNT<AZ.PRINCIPAL>
    R.NEW(FT.DEBIT.ACCT.NO)  = Y.INT.LIQ.ACCT
    R.NEW(FT.DEBIT.CURRENCY) = R.AZACCOUNT<AZ.CURRENCY>
    R.NEW(FT.LOCAL.REF)<1,Y.L.ORG.DP.AMT.POS> = TRIMB(FMT(Y.FIN.DEP.AMT,'L2,#15'))
    R.NEW(FT.LOCAL.REF)<1,Y.L.REIVSD.INT.POS> = TRIMB(FMT(Y.FIN.INT.AMT,'L2,#15'))
*R.NEW(FT.DEBIT.VALUE.DATE)=TODAY
*R.NEW(FT.CREDIT.VALUE.DATE)=TODAY

    IF PGM.VERSION EQ ',CHQ.OTHERS.DEPOSIT' OR ',CHQ.NO.TAX.DEPOSITS' THEN
        FN.CUSTOMER = 'F.CUSTOMER'
        F.CUSTOMER = ''
        CALL OPF(FN.CUSTOMER,F.CUSTOMER)
        Y.CUS.ID = R.AZACCOUNT<AZ.CUSTOMER>
        CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
        Y.NAME1 = R.CUSTOMER<EB.CUS.NAME.1>
        Y.NAME2 = R.CUSTOMER<EB.CUS.NAME.2>
        CHANGE @VM TO ' ' IN Y.NAME1
        CHANGE @VM TO ' ' IN Y.NAME2

************************jeeva changes made ****************
        Y.L = LEN(Y.NAME1)
        Y.L1 =  LEN(Y.NAME2)
        Y.JOIN.NAME = Y.NAME1:' ':Y.NAME2
        Y.LEN.VAL = LEN(Y.JOIN.NAME)
        IF Y.LEN.VAL GT 65 THEN
            R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,1> = Y.JOIN.NAME[1,65]
            R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,2> = Y.JOIN.NAME[66,Y.LEN.VAL]
        END ELSE
            R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,1> = Y.JOIN.NAME
        END
******************************ends ***************************
*        R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,1>= Y.NAME1
*       R.NEW(FT.LOCAL.REF)<1,POS.BENEFIC.NAME,2>= Y.NAME2
    END

RETURN
END
