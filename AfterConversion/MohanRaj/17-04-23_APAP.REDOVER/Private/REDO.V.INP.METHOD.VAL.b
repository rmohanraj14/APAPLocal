* @ValidationCode : MjoxMDkyMDg1NjAyOkNwMTI1MjoxNjgxNzI5MzU1MDgyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:32:35
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
SUBROUTINE REDO.V.INP.METHOD.VAL
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.VAL.METHOD.VAL
*---------------------------------------------------------------------------------

*DESCRIPTION      :It is attached as valildation routine to the field ALL.IN.ONE.PRODUCT
*                  in the version AZ.ACCOUNT,REDO.MULTI.PROCESS to validate debit accout incase
*                  method of pay is FROM
*LINKED WITH       : AZ VERSIONS

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 14-JUN-2010        Prabhu.N       ODR-2009-10-0315    Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ENQUIRY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.PRODUCT.PARAMETER
    $INSERT I_F.MULTI.BRANCH.INTERNAL.ACCOUNT

    GOSUB INIT
    GOSUB PROCESS
    GOSUB END1
RETURN
*-------
INIT:
*--------

    FN.ENQUIRY = 'F.ENQUIRY'
    F.ENQUIRY = ''
    CALL OPF(FN.ENQUIRY,F.ENQUIRY)

    FN.MULTI.BRANCH.INTERNAL.ACCOUNT = 'F.MULTI.BRANCH.INTERNAL.ACCOUNT'
    F.MULTI.BRANCH.INTERNAL.ACCOUNT = ''
    CALL OPF(FN.MULTI.BRANCH.INTERNAL.ACCOUNT,F.MULTI.BRANCH.INTERNAL.ACCOUNT)

    FN.AZ.PRODUCT.PARAMETER = 'F.AZ.PRODUCT.PARAMETER'
    F.AZ.PRODUCT.PARAMETER= ''
    CALL OPF(FN.AZ.PRODUCT.PARAMETER,F.AZ.PRODUCT.PARAMETER)


    LREF.APPLICATION='AZ.ACCOUNT':@FM:'AZ.PRODUCT.PARAMETER':@FM:'ACCOUNT'
    LREF.FIELD='L.AZ.METHOD.PAY':@VM:'L.AZ.DEBIT.ACC':@VM:'L.AZ.AMOUNT':@VM:'L.TYPE.INT.PAY'::@VM:'L.AZ.IN.TRANSIT':@FM:'L.AZP.TRAN.DAYS':@FM:'L.AC.STATUS2'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APPLICATION,LREF.FIELD,LREF.POS)

    POS.METHOD.PAY = LREF.POS<1,1>
    POS.DEBIT.ACC = LREF.POS<1,2>
    POS.PAY.AMOUNT = LREF.POS<1,3>
    POS.INT.PAY.TYPE=LREF.POS<1,4>
    POS.L.AZ.IN.TRANSIT =LREF.POS<1,5>
    POS.L.AZP.TRAN.DAYS = LREF.POS<2,1>
    GET.ACCT.STATUS.POS = LREF.POS<3,1>

    VAR.METHOD.PAY.LIST=R.NEW(AZ.LOCAL.REF)<1,POS.METHOD.PAY>
    VAR.DEBIT.ACC.LIST=R.NEW(AZ.LOCAL.REF)<1,POS.DEBIT.ACC>
    VAR.PAY.AMOUNT=R.NEW(AZ.LOCAL.REF)<1,POS.PAY.AMOUNT>
    Y.INT.PAY.TYPE = R.NEW(AZ.LOCAL.REF)<1,POS.INT.PAY.TYPE>

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN
*------------
PROCESS:
*-----------
    IF Y.INT.PAY.TYPE EQ 'Reinvested' THEN
        IF R.NEW(AZ.REPAY.ACCOUNT) EQ '' THEN
            GOSUB CHECK.SOURCE.OF.FUND
            GOSUB CHECK.TRANS.DAYS
        END ELSE
            Y.DEBIT.ACC = R.NEW(AZ.REPAY.ACCOUNT)

            IF Y.DEBIT.ACC NE '' AND R.NEW(AZ.LOCAL.REF)<1,POS.METHOD.PAY,1> THEN
                AF = AZ.REPAY.ACCOUNT
                ETEXT='EB-REDO.REINV.PAY'
                CALL STORE.END.ERROR
                GOSUB END1
            END
        END
    END ELSE
        GOSUB CHECK.SOURCE.OF.FUND
        GOSUB CHECK.TRANS.DAYS
        GOSUB CHECK.INT.PAY.TYPE
    END
RETURN
*---------------------
CHECK.SOURCE.OF.FUND:
*---------------------

    Y.PRINCIPAL=R.NEW(AZ.PRINCIPAL)
    CHANGE @SM TO @FM IN VAR.METHOD.PAY.LIST
    CHANGE @SM TO @FM IN VAR.DEBIT.ACC.LIST
    CHANGE @SM TO @FM IN VAR.PAY.AMOUNT
    VAR.METHOD.PAY.LIST.SIZE=DCOUNT(VAR.METHOD.PAY.LIST,@FM)

    GOSUB GET.INT.ACC.DETAILS
    METHOD.CNT = 1
    LOOP
    WHILE METHOD.CNT LE VAR.METHOD.PAY.LIST.SIZE
        IF (VAR.METHOD.PAY.LIST<METHOD.CNT> EQ 'FROM.CUST.ACC' OR VAR.METHOD.PAY.LIST<METHOD.CNT> EQ 'FROM.INT.ACC' OR VAR.METHOD.PAY.LIST<METHOD.CNT> EQ 'FROM.NOST.ACC') AND VAR.DEBIT.ACC.LIST<METHOD.CNT> EQ '' THEN
            AF=AZ.LOCAL.REF
            AV=POS.DEBIT.ACC
            AS=METHOD.CNT
            ETEXT='EB-NO.DEBIT.ACCT'
            CALL STORE.END.ERROR
            GOSUB END1
        END
        IF (VAR.METHOD.PAY.LIST<METHOD.CNT> NE "FROM.CUST.ACC" AND VAR.METHOD.PAY.LIST<METHOD.CNT> NE "FROM.INT.ACC" AND VAR.METHOD.PAY.LIST<METHOD.CNT> NE "FROM.NOST.ACC") AND VAR.METHOD.PAY.LIST<METHOD.CNT> NE "" AND VAR.DEBIT.ACC.LIST<METHOD.CNT> NE "" THEN
            AF = AZ.LOCAL.REF
            AV = POS.DEBIT.ACC
            AS = METHOD.CNT
            ETEXT = 'EB-REDO.ACC.NOT.ALLOW'
            CALL STORE.END.ERROR
            GOSUB END1
        END
        IF VAR.METHOD.PAY.LIST<METHOD.CNT> EQ "FROM.CUST.ACC" AND VAR.DEBIT.ACC.LIST<METHOD.CNT> NE '' THEN
            VAR.ACCOUNT = VAR.DEBIT.ACC.LIST<METHOD.CNT>
            CALL F.READ(FN.ACCOUNT,VAR.ACCOUNT,R.AZ.DEBIT.ACC,F.ACCOUNT,ACC.ERR)
            GET.ACCT.STATUS.VAL = R.AZ.DEBIT.ACC<AC.LOCAL.REF,GET.ACCT.STATUS.POS>

            IF GET.ACCT.STATUS.VAL EQ 'DECEASED' THEN
                AF = AZ.LOCAL.REF
                AV = POS.DEBIT.ACC
                AS = METHOD.CNT
                ETEXT = "EB-REDO.AC.DECEASED"
                CALL STORE.END.ERROR
            END
        END

        IF VAR.METHOD.PAY.LIST<METHOD.CNT> EQ 'FROM.INT.ACC' THEN
            GOSUB CHECK.INT.ACC
        END
        METHOD.CNT += 1
    REPEAT
    IF VAR.METHOD.PAY.LIST.SIZE GT 1 THEN
        Y.CNT = 1
        LOOP
        WHILE Y.CNT LE VAR.METHOD.PAY.LIST.SIZE
            IF VAR.PAY.AMOUNT<Y.CNT> EQ '' THEN
                AF=AZ.LOCAL.REF
                AV=POS.PAY.AMOUNT
                AS=Y.CNT
                ETEXT='EB-AMOUNT.MANDATORY'
                CALL STORE.END.ERROR
                GOSUB END1
            END
            GOSUB CHECK.METHOD.PAY
            Y.CNT += 1
        REPEAT
    END

RETURN
*--------------------------------------------------
CHECK.METHOD.PAY:
*----------------------------------------------------
    C.AMT = 1
    LOOP
    WHILE C.AMT LE VAR.METHOD.PAY.LIST.SIZE
        IF C.AMT NE Y.CNT THEN
            IF VAR.METHOD.PAY.LIST<Y.CNT> EQ VAR.METHOD.PAY.LIST<C.AMT> AND VAR.DEBIT.ACC.LIST<Y.CNT> EQ VAR.DEBIT.ACC.LIST<C.AMT> THEN
                AF=AZ.LOCAL.REF
                AV=POS.METHOD.PAY
                AS=C.AMT
                ETEXT ='EB-TYPE.MORE.THEN.ONCE.ENTER'
                CALL STORE.END.ERROR
                GOSUB END1
            END
        END
        C.AMT += 1
    REPEAT

RETURN
*-------------------------------------------------------
CHECK.INT.PAY.TYPE:
*-------------------------------------------------------
    Y.INT.PAY.TYPE = R.NEW(AZ.LOCAL.REF)<1,POS.INT.PAY.TYPE>
    IF Y.INT.PAY.TYPE EQ 'Credit.To.Account' THEN
        IF R.NEW(AZ.INTEREST.LIQU.ACCT) EQ '' THEN
            AF=AZ.INTEREST.LIQU.ACCT
            ETEXT='EB-REDO.INT.LIQ.MAND'
            CALL STORE.END.ERROR
            GOSUB END1
        END
    END
    IF R.NEW(AZ.INTEREST.LIQU.ACCT) NE '' THEN
        Y.LIQ.ACCT = R.NEW(AZ.INTEREST.LIQU.ACCT)
        CALL F.READ(FN.ACCOUNT,Y.LIQ.ACCT,R.ACCOUNT,F.ACCOUNT,LIQ.ACCT.ERR)
        Y.LIQ.ACCT.CUST = R.ACCOUNT<AC.CUSTOMER>
        IF Y.LIQ.ACCT.CUST THEN
            IF Y.INT.PAY.TYPE NE 'Credit.To.Account' THEN
                AF=AZ.LOCAL.REF
                AV=POS.INT.PAY.TYPE
                ETEXT='EB-REDO.INT.PAY'
                CALL STORE.END.ERROR
                GOSUB END1
            END
        END
    END
RETURN
*------------------
CHECK.TRANS.DAYS:
*------------------
    CALL CACHE.READ(FN.AZ.PRODUCT.PARAMETER,R.NEW(AZ.ALL.IN.ONE.PRODUCT),R.APP,APP.ERR)
    Y.TRANS.DAYS = R.APP<AZ.APP.LOCAL.REF,POS.L.AZP.TRAN.DAYS>

    R.NEW(AZ.LOCAL.REF)<1,POS.L.AZ.IN.TRANSIT> = ''

    LOCATE 'CHEQUE.DEPOSIT' IN VAR.METHOD.PAY.LIST SETTING POS1 THEN
        IF Y.TRANS.DAYS GT 0 THEN
            R.NEW(AZ.LOCAL.REF)<1,POS.L.AZ.IN.TRANSIT> = 'YES'
        END
    END

RETURN
*-------------------------------------------------------
GET.INT.ACC.DETAILS:
*-------------------------------------------------------
    Y.INT.ACC.ID = ''
    Y.ENQUIRY.ID = 'REDO.ENQ.PAY.LIST.ACC'
    Y.VERSION.NAME = ''

    CALL CACHE.READ(FN.ENQUIRY, Y.ENQUIRY.ID, R.ENQ, EN.ERR) ;*R22 Auto Code conversion
    FINDSTR 'VERSION' IN  R.ENQ<ENQ.FIXED.SELECTION> SETTING POS.FM,POS.VM THEN
        Y.VERSION.NAME = FIELD(R.ENQ<ENQ.FIXED.SELECTION,POS.VM>,' ',3)
    END
    IF Y.VERSION.NAME THEN
        CALL CACHE.READ(FN.MULTI.BRANCH.INTERNAL.ACCOUNT,'SYSTEM',R.MULTI.BRANCH,MULTI.ERR)
        LOCATE Y.VERSION.NAME IN R.MULTI.BRANCH<REDO.BR.ACCT.VERSION,1> SETTING VER.POS THEN
            Y.INT.ACC.ID = R.MULTI.BRANCH<REDO.BR.ACCT.ACCOUNT,VER.POS>
        END
    END

RETURN
*--------------------------------------------------------------
CHECK.INT.ACC:
*--------------------------------------------------------------
    IF Y.INT.ACC.ID THEN
        IF VAR.DEBIT.ACC.LIST<METHOD.CNT> NE Y.INT.ACC.ID THEN
            AF=AZ.LOCAL.REF
            AV=POS.DEBIT.ACC
            AS=METHOD.CNT
            ETEXT = 'EB-REDO.MISS.INT.ACC'
            CALL STORE.END.ERROR
            GOSUB END1
        END

    END
RETURN
*-----
END1:
*-----

END
