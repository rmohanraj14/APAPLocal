* @ValidationCode : MjoxODcxNDQyNzM2OkNwMTI1MjoxNjgxMzgyNDkzMDIwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:11:33
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
SUBROUTINE REDO.V.BA.ORG.FT.TXN

*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Edwin Charles D
* Program Name  : REDO.V.BA.ORG.FT.TXN
*-------------------------------------------------------------------------
* Description: This routine is auth routine to process FT from REDO.FT.TT.TRANSACTION
*
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
* DATE         Name              ODR / HD REF              DESCRIPTION
* 14-06-17     Edwin Charles D   R15 Ugrade                Initial creation
* 24-08-17     Edwin Charles D   R15 Ugrade                BENEFIC NAME issue
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.APAP.H.INSURANCE.DETAILS

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:
*----
    Y.VERSION.NAME = APPLICATION:PGM.VERSION
    Y.APPLICATION = APPLICATION
    Y.OFS.BDY     = ''
RETURN

PROCESS:
*-------

    IF APPLICATION EQ 'REDO.FT.TT.TRANSACTION' THEN

        OFSVERSION = ''
        Y.TRANSACTION.TYPE      = R.NEW(FT.TN.TRANSACTION.TYPE)
        Y.DEBIT.ACCT.NO         = R.NEW(FT.TN.DEBIT.ACCT.NO)
        Y.DEBIT.CURRENCY        = R.NEW(FT.TN.DEBIT.CURRENCY)
        Y.DEBIT.VALUE.DATE      = R.NEW(FT.TN.DEBIT.VALUE.DATE)
        Y.DEBIT.THEIR.REF       = R.NEW(FT.TN.DEBIT.THEIR.REF)
        Y.CREDIT.ACCT.NO        = R.NEW(FT.TN.CREDIT.ACCT.NO)
        Y.CREDIT.AMOUNT         = R.NEW(FT.TN.CREDIT.AMOUNT)
        Y.DEBIT.AMOUNT          = R.NEW(FT.TN.DEBIT.AMOUNT)
        Y.CREDIT.CURRENCY       = R.NEW(FT.TN.CREDIT.CURRENCY)
        Y.CREDIT.VALUE.DATE     = R.NEW(FT.TN.CREDIT.VALUE.DATE)
        Y.L.LOAN.COND           = R.NEW(FT.TN.L.LOAN.COND)
        Y.L.LOAN.STATUS.1       = R.NEW(FT.TN.L.LOAN.STATUS.1)
        Y.L.INITIAL.ID          = R.NEW(FT.TN.L.INITIAL.ID)
        Y.CREDIT.THEIR.REF      = ID.NEW

        Y.ACTUAL.VERSION = '' ; Y.NEXT.VERSION = ''; Y.VERSION = '' ; Y.N.VERSION = ''
        Y.ACTUAL.VERSION = R.NEW(FT.TN.L.ACTUAL.VERSIO)
        Y.VERSION = FIELD(Y.ACTUAL.VERSION,',',2)
        Y.NEXT.VERSION   = R.NEW(FT.TN.L.NEXT.VERSION)
        Y.N.VERSION   = FIELD(Y.NEXT.VERSION,',',2)
        REP.CHAR = '?'
        IF Y.VERSION THEN
            Y.L.ACTUAL.VERSIO = 'FUNDS.TRANSFER':REP.CHAR:Y.VERSION
        END
        IF Y.N.VERSION THEN
            Y.L.NEXT.VERSION  = 'FUNDS.TRANSFER':REP.CHAR:Y.N.VERSION
        END

        Y.OFS.BDY = 'TRANSACTION.TYPE::=':Y.TRANSACTION.TYPE:',DEBIT.ACCT.NO::=':Y.DEBIT.ACCT.NO:',DEBIT.AMOUNT::=':Y.DEBIT.AMOUNT:',DEBIT.CURRENCY::=':Y.DEBIT.CURRENCY:',DEBIT.VALUE.DATE::=':Y.DEBIT.VALUE.DATE:',DEBIT.THEIR.REF::=':Y.DEBIT.THEIR.REF:',CREDIT.ACCT.NO::=':Y.CREDIT.ACCT.NO:',CREDIT.AMOUNT::=':Y.CREDIT.AMOUNT:',CREDIT.CURRENCY::=':Y.CREDIT.CURRENCY:',CREDIT.VALUE.DATE::=':Y.CREDIT.VALUE.DATE:',CREDIT.THEIR.REF::=':Y.CREDIT.THEIR.REF
        Y.OFS.BDY :=',L.ACTUAL.VERSIO::=':Y.L.ACTUAL.VERSIO:',L.NEXT.VERSION::=':Y.L.NEXT.VERSION:',L.LOAN.COND::=':Y.L.LOAN.COND:',L.LOAN.STATUS.1::=':Y.L.LOAN.STATUS.1:',L.INITIAL.ID::=':Y.L.INITIAL.ID

        BEGIN CASE
            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.OTI' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.OTI'
                Y.PROCESSING.DATE    = R.NEW(FT.TN.PROCESSING.DATE)
                Y.L.FT.CUSTOMER      = R.NEW(FT.TN.L.FT.CUSTOMER)
                Y.L.FT.COMPANY       = R.NEW(FT.TN.L.FT.COMPANY)
                Y.BENEFIC.NAME       = R.NEW(FT.TN.BENEFIC.NAME)
                Y.DOC.NUM            = R.NEW(FT.TN.L.FT.DOC.NUM)
                Y.PAYMENT.DETAILS    = R.NEW(FT.TN.PAYMENT.DETAILS)
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.BENEFIC.NAME = Y.BENEFIC.NAME[1,45]
                Y.OFS.BDY :=',PROCESSING.DATE::=':Y.PROCESSING.DATE:',L.FT.CUSTOMER::=':Y.L.FT.CUSTOMER:',L.FT.COMPANY::=':Y.L.FT.COMPANY:',BENEFIC.NAME::=':Y.BENEFIC.NAME:',L.FT.DOC.NUM::=':Y.DOC.NUM:',PAYMENT.DETAILS::=':Y.PAYMENT.DETAILS

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.CHEQUE' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.CHEQUE'

                Y.PROCESSING.DATE = R.NEW(FT.TN.PROCESSING.DATE)
                Y.L.FT.CUSTOMER   = R.NEW(FT.TN.L.FT.CUSTOMER)
                Y.L.FT.LEGAL.ID   = R.NEW(FT.TN.FT.LEGAL.ID)
                Y.L.FT.COMPANY    = R.NEW(FT.TN.L.FT.COMPANY)
                Y.BENEFIC.NAME    = R.NEW(FT.TN.BENEFIC.NAME)
                Y.L.FT.CONCEPT    = R.NEW(FT.TN.L.FT.CONCEPT)
                Y.PAYMENT.DETAILS = R.NEW(FT.TN.PAYMENT.DETAILS)
                Y.BENEFIC.NAME    = Y.BENEFIC.NAME[1,45]
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',PROCESSING.DATE::=':Y.PROCESSING.DATE:',L.FT.CUSTOMER::=':Y.L.FT.CUSTOMER:',L.FT.LEGAL.ID::=':Y.L.FT.LEGAL.ID:',L.FT.COMPANY::=':Y.L.FT.COMPANY:',BENEFIC.NAME::=':Y.BENEFIC.NAME:',L.FT.CONCEPT::=':Y.L.FT.CONCEPT:',PAYMENT.DETAILS::=':Y.PAYMENT.DETAILS

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.ACDP' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.ACDP'

                Y.L.FT.COMPANY        = R.NEW(FT.TN.L.FT.COMPANY)
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.FT.COMPANY::=':Y.L.FT.COMPANY

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.CASH' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.CASH'

                Y.L.FT.CUSTOMER      = R.NEW(FT.TN.L.FT.CUSTOMER)
                Y.L.FT.COMPANY       = R.NEW(FT.TN.L.FT.COMPANY)
                Y.BENEFIC.NAME       = R.NEW(FT.TN.BENEFIC.NAME)
                Y.DOC.NUM            = R.NEW(FT.TN.L.FT.DOC.NUM)
                Y.L.COMMENTS         = R.NEW(FT.TN.L.COMMENTS)
                Y.BENEFIC.NAME       = Y.BENEFIC.NAME[1,45]
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.FT.CUSTOMER::=':Y.L.FT.CUSTOMER:',L.FT.COMPANY::=':Y.L.FT.COMPANY:',BENEFIC.NAME::=':Y.BENEFIC.NAME:',L.FT.DOC.NUM::=':Y.DOC.NUM:',L.COMMENTS::=':Y.L.COMMENTS

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.MULTI.AA.ACCRAP.DISB' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.MULTI.AA.ACCRAP.PDISB'

                Y.L.NCF.REQUIRED     = R.NEW(FT.TN.L.NCF.REQUIRED)
                Y.L.NO.OF.INSTAL     = R.NEW(FT.TN.L.NO.OF.INSTAL)
                Y.L.ADV.INS.CNT      = R.NEW(FT.TN.L.ADV.INS.CNT)
                Y.L.NCF.NUMBER       = R.NEW(FT.TN.NCF.NUMBER)
                Y.L.TT.TAX.CODE      = R.NEW(FT.TN.L.TT.TAX.CODE)
                Y.L.TT.WV.TAX        = R.NEW(FT.TN.L.TT.WV.TAX)
                Y.L.TT.TAX.AMT       = R.NEW(FT.TN.L.TT.TAX.AMT)
                Y.L.NCF.TAX.NUM      = R.NEW(FT.TN.L.NCF.TAX.NUM)
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.NCF.REQUIRED::=':Y.L.NCF.REQUIRED:',L.NO.OF.INSTAL::=':Y.L.NO.OF.INSTAL:',L.ADV.INS.CNT::=':Y.L.ADV.INS.CNT:',L.NCF.NUMBER::=':Y.L.NCF.NUMBER:',L.TT.TAX.CODE::=':Y.L.TT.TAX.CODE:',L.TT.WV.TAX::=':Y.L.TT.WV.TAX:',L.TT.TAX.AMT::=':Y.L.TT.TAX.AMT:',L.NCF.TAX.NUM::=':Y.L.NCF.TAX.NUM

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.LTCC' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.LTCC'

                Y.CLIENT.NME.1 = R.NEW(FT.TN.L.FT.CLIENT.NME)
                Y.BAL.IN.LCY   = R.NEW(FT.TN.L.FT.BAL.IN.LCY)
                Y.BAL.IN.USD   = R.NEW(FT.TN.L.FT.BAL.IN.USD)
                Y.MINPAY.LCY   = R.NEW(FT.TN.L.FT.MINPAY.LCY)
                Y.MINPAY.USD   = R.NEW(FT.TN.L.FT.MINPAY.USD)
                Y.PAY.DUE.DT   = R.NEW(FT.TN.L.FT.PAY.DUE.DT)
                Y.CR.CRD.STS   = R.NEW(FT.TN.L.FT.CR.CRD.STS)
                Y.AC.STATUS    = R.NEW(FT.TN.L.FT.AC.STATUS)
                Y.DOC.NUM      = R.NEW(FT.TN.L.FT.DOC.NUM)
                Y.DOC.DESC     = R.NEW(FT.TN.L.FT.DOC.DESC)
                Y.MSG.DESC     = R.NEW(FT.TN.L.FT.MSG.DESC)
                Y.MSG.CODE     = R.NEW(FT.TN.L.FT.MSG.CODE)
                Y.CR.CARD.NO   = R.NEW(FT.TN.L.FT.CR.CARD.NO)
                Y.L.SUN.SEQ.NO = R.NEW(FT.TN.L.SUN.SEQ.NO)
                Y.ORDERING.CUST    = R.NEW(FT.TN.ORDERING.CUST)
                Y.FT.SN.PAYMTHD   = R.NEW(FT.TN.L.FT.SN.PAYMTHD)
                Y.L.FT.CLIENT.COD  = R.NEW(FT.TN.FT.CLIENT.COD)
                Y.CLIENT.NME       = Y.CLIENT.NME.1[1,31]
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',ORDERING.CUST::=':Y.ORDERING.CUST:',L.FT.SN.PAYMTHD::=':Y.FT.SN.PAYMTHD:',L.FT.CLIENT.COD::=':Y.L.FT.CLIENT.COD:',L.FT.CLIENT.NME::=':Y.CLIENT.NME:',L.FT.BAL.IN.LCY::=':Y.BAL.IN.LCY:',L.FT.BAL.IN.USD::=':Y.BAL.IN.USD:',L.FT.MINPAY.LCY::=':Y.MINPAY.LCY:',L.FT.MINPAY.USD::=':Y.MINPAY.USD:',L.FT.PAY.DUE.DT::=':Y.PAY.DUE.DT:',L.FT.CR.CRD.STS::=':Y.CR.CRD.STS:',L.FT.AC.STATUS::=':Y.AC.STATUS:',L.FT.DOC.NUM::=':Y.DOC.NUM:',L.FT.DOC.DESC::=':Y.DOC.DESC:',L.FT.MSG.DESC::=':Y.MSG.DESC:',L.FT.MSG.CODE::=':Y.MSG.CODE:',L.FT.CR.CARD.NO::=':Y.CR.CARD.NO:',L.SUN.SEQ.NO::=':Y.L.SUN.SEQ.NO

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.IB.ACH' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.IB.ACH'

                Y.L.FT.CUSTOMER      = R.NEW(FT.TN.L.FT.CUSTOMER)
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.FT.CUSTOMER::=':Y.L.FT.CUSTOMER

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.MULTI.AA.ACPOAP.DISB' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.MULTI.AA.PART.ACPOAP.DISB'

                Y.L.PRINC.AMT.DUE    = R.NEW(FT.TN.PRINC.AMT.DUE)
                Y.L.INT.AMT.DUE      = R.NEW(FT.TN.INT.AMT.DUE)
                Y.ORDERING.CUST      = R.NEW(FT.TN.ORDERING.CUST)
                Y.L.NCF.REQUIRED     = R.NEW(FT.TN.L.NCF.REQUIRED)
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.PRINC.AMT.DUE::=':Y.L.PRINC.AMT.DUE:',L.INT.AMT.DUE::=':Y.L.INT.AMT.DUE:',ORDERING.CUST::=':Y.ORDERING.CUST:',L.NCF.REQUIRED::=':Y.L.NCF.REQUIRED

            CASE Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.INTERBRANCH.ACH' OR Y.VERSION.NAME EQ 'REDO.FT.TT.TRANSACTION,REDO.AA.PART.INTERBRANCH.ACH'

                Y.L.FT.CUSTOMER    = R.NEW(FT.TN.L.FT.CUSTOMER)
                Y.BENEFIC.NAME     = R.NEW(FT.TN.BENEFIC.NAME)
                Y.MSG.DESC         = R.NEW(FT.TN.L.FT.MSG.DESC)
                Y.L.FT.ACH.B.ACC   = R.NEW(FT.TN.L.FT.ACH.B.ACC)
                Y.L.FT.CMPNY.ID    = R.NEW(FT.TN.L.FT.CMPNY.ID)
                Y.BENEFIC.NAME     = Y.BENEFIC.NAME[1,45]
                OFSVERSION = "FUNDS.TRANSFER,":Y.VERSION
                Y.OFS.BDY :=',L.FT.CUSTOMER::=':Y.L.FT.CUSTOMER:',BENEFIC.NAME::=':Y.BENEFIC.NAME:',L.FT.MSG.DESC::=':Y.MSG.DESC:',L.FT.ACH.B.ACC::=':Y.L.FT.ACH.B.ACC:',L.FT.CMPNY.ID::=':Y.L.FT.CMPNY.ID

            CASE 1

        END CASE

        IF OFSVERSION THEN
            GOSUB POST.FT.TXN
            GOSUB POST.INS.AUTH
        END

    END

RETURN

POST.FT.TXN:
*-----------

    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)

    Y.USR = OPERATOR
    CALL F.READ(FN.USER,Y.USR,R.USR,F.USER,ERR.US)
    OFS.USERNAME = R.USR<EB.USE.SIGN.ON.NAME>
    OFS.PASSWORD = R.USR<EB.USE.PASSWORD>
    Y.OFS.MSG = ''
    Y.OFS.MSG = OFSVERSION:'/I/PROCESS,':OFS.USERNAME:'/':OFS.PASSWORD:'/':ID.COMPANY:',,':Y.OFS.BDY

    ofsRequest = Y.OFS.MSG
    CALL ofs.addLocalRequest(ofsRequest,'add',error)
    MSG.OUT = ofsRequest

RETURN


POST.INS.AUTH:
*----------

    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)

    Y.USR = OPERATOR
    CALL F.READ(FN.USER,Y.USR,R.USR,F.USER,ERR.US)
    OFS.USERNAME = R.USR<EB.USE.SIGN.ON.NAME>
    OFS.PASSWORD = R.USR<EB.USE.PASSWORD>
    Y.OFS.VERSION = "APAP.H.INSURANCE.DETAILS,REDO.AUTORIZACION"

    FN.APAP.INS.NAU = "F.APAP.H.INSURANCE.DETAILS$NAU"
    F.APAP.INS.NAU = ""
    CALL OPF(FN.APAP.INS.NAU,F.APAP.INS.NAU)
    Y.AR.ID = FIELD(Y.L.INITIAL.ID,".",1)


    SEL.CMD = "SELECT ":FN.APAP.INS.NAU:" WITH ASSOCIATED.LOAN EQ ":Y.AR.ID

    CALL EB.READLIST(SEL.CMD,SEL.LIST,"",NO.OF.REC,ERR.REC)
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE NO.OF.REC
        Y.AP.IN.ID = SEL.LIST<Y.CNT>
        Y.OFS.MSG = ""
        Y.OFS.MSG = Y.OFS.VERSION:'/A/PROCESS,':OFS.USERNAME:'/':OFS.PASSWORD:'/':ID.COMPANY:',':Y.AP.IN.ID

        ofsRequest = Y.OFS.MSG
        CALL ofs.addLocalRequest(ofsRequest,'add',error)
        MSG.OUT = ofsRequest
        Y.CNT += 1 ;*R22 Auto Code conversion
    REPEAT

RETURN

END
