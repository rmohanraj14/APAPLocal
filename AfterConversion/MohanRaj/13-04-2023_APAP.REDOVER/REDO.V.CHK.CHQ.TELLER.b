* @ValidationCode : MjoxNzYyNzM4NTQwOkNwMTI1MjoxNjgxMzgzMjY1ODIwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:24:25
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
SUBROUTINE REDO.V.CHK.CHQ.TELLER
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION :   This routine will be executed at check Record Routine for the Following
* versions of  TELLER,REVERSE.CERTIFIED.CHEQUES
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.CHK.CHQ.TELLER
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 16.03.2010  SUDHARSANAN S     ODR-2009-10-0319  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_TT.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.ID
    $INSERT I_F.CERTIFIED.CHEQUE.STOCK

    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
INIT:
    FN.TELLER='F.TELLER'
    F.TELLER=''
    CALL OPF(FN.TELLER,F.TELLER)
    FN.TELLER.HIS='F.TELLER$HIS'
    F.TELLER.HIS=''
    CALL OPF(FN.TELLER.HIS,F.TELLER.HIS)
    FN.TELLER.ID='F.TELLER.ID'
    F.TELLER.ID=''
    CALL OPF(FN.TELLER.ID,F.TELLER.ID)
    FN.CERTIFIED.CHEQUE.STOCK='F.CERTIFIED.CHEQUE.STOCK'
    F.CERTIFIED.CHEQUE.STOCK=''
    CALL OPF(FN.CERTIFIED.CHEQUE.STOCK,F.CERTIFIED.CHEQUE.STOCK)
    LREF.APP='TELLER'
    LREF.FIELD='BENEFICIARY.NAM':@VM:'CERT.CHEQUE.NO':@VM:'WAIVE.TAX':@VM:'TAX.AMOUNT'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
    BEN.POS=LREF.POS<1,1>
    CHEQ.POS=LREF.POS<1,2>
    WAIVE.POS= LREF.POS<1,3>
    TAX.POS= LREF.POS<1,4>
RETURN
*-----------------------------------------------------------------------------------
PROCESS:
    Y.CHEQ.NO=R.NEW(TT.TE.LOCAL.REF)<1,CHEQ.POS>
    R.CERT.CHEQ.STO=''
    CALL F.READ(FN.CERTIFIED.CHEQUE.STOCK,Y.CHEQ.NO,R.CERT.CHEQ.STO,F.CERTIFIED.CHEQUE.STOCK,STO.ERR)
    Y.TRANS.REF = R.CERT.CHEQ.STO<CERT.STO.TRANS.REF>
    R.TELLER=''
    CALL F.READ(FN.TELLER,Y.TRANS.REF,R.TELLER,F.TELLER,TELL.ERR)
    IF R.TELLER THEN
        GOSUB REV.TRANS
    END ELSE
        R.TELLER=''
        CALL EB.READ.HISTORY.REC(F.TELLER.HIS,Y.TRANS.REF,R.TELLER,TELLER.ERR)
        GOSUB REV.TRANS
    END
RETURN
*------------------------------------------------------------------------------------------
REV.TRANS:
    SEL.TELLER.ID='SSELECT ':FN.TELLER.ID:' WITH STATUS EQ OPEN AND USER EQ ':OPERATOR
    CALL EB.READLIST(SEL.TELLER.ID,SEL.TELLER.LIST,'',NOR.TELLER,TELLER.ERR)
    Y.TELLER.ID = SEL.TELLER.LIST<1>
    R.NEW(TT.TE.TELLER.ID.1) = Y.TELLER.ID
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1>= R.TELLER<TT.TE.AMOUNT.LOCAL.1,1>
    R.NEW(TT.TE.ACCOUNT.1)<1,1> = R.TELLER<TT.TE.ACCOUNT.1,1>
    R.NEW(TT.TE.ACCOUNT.2) = R.TELLER<TT.TE.ACCOUNT.2>
    CNT.NARR=DCOUNT(R.TELLER<TT.TE.NARRATIVE.1>,@VM)
    FOR VAR.NARR=1 TO CNT.NARR
        R.NEW(TT.TE.NARRATIVE.1)<1,VAR.NARR> = R.TELLER<TT.TE.NARRATIVE.1,VAR.NARR>
    NEXT VAR.NARR
    R.NEW(TT.TE.CURRENCY.1) = R.TELLER<TT.TE.CURRENCY.1>
    R.NEW(TT.TE.CURRENCY.2) = R.TELLER<TT.TE.CURRENCY.2>
    R.NEW(TT.TE.CUSTOMER.2) = R.TELLER<TT.TE.CUSTOMER.2>
    R.NEW(TT.TE.CUSTOMER.1) = R.TELLER<TT.TE.CUSTOMER.1>
    R.NEW(TT.TE.TELLER.ID.2) = Y.TELLER.ID
    CNT.CHEQ=DCOUNT(R.TELLER<TT.TE.CHEQUE.NUMBER>,@VM)
    FOR VAR.CHEQ=1 TO CNT.CHEQ
        R.NEW(TT.TE.CHEQUE.NUMBER)<1,VAR.CHEQ> = R.TELLER<TT.TE.CHEQUE.NUMBER,VAR.CHEQ>
    NEXT VAR.CHEQ
    CNT.CHARGE=DCOUNT(R.TELLER<TT.TE.CHRG.AMT.LOCAL>,@VM)
    FOR VAR.CHARGE=1 TO CNT.CHARGE
        R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,VAR.CHARGE> = R.TELLER<TT.TE.CHRG.AMT.LOCAL,VAR.CHARGE>
    NEXT VAR.CHARGE
    R.NEW(TT.TE.WAIVE.CHARGES) = R.TELLER<TT.TE.WAIVE.CHARGES>
    R.NEW(TT.TE.LOCAL.REF)<1,BEN.POS> = R.TELLER<TT.TE.LOCAL.REF,BEN.POS>
    R.NEW(TT.TE.LOCAL.REF)<1,WAIVE.POS>= R.TELLER<TT.TE.LOCAL.REF,WAIVE.POS>
    R.NEW(TT.TE.LOCAL.REF)<1,TAX.POS> = R.TELLER<TT.TE.LOCAL.REF,TAX.POS>
RETURN
*------------------------------------------------------------------------------------------------------
END
