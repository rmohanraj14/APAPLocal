* @ValidationCode : MjotMTc1MDc4NTkxNTpDcDEyNTI6MTY4MTcyOTMxNzM5Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:31:57
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
SUBROUTINE REDO.V.INP.METHOD.OF.PAY
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine will update the local field depending upon the value of TRANSACTION.CODE. This routine will be attach to the Version
* LLER,REDO.BILL.PAYMNT

* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : @ID
* CALLED BY :
*
* Revision History:
*------------------------------------------------------------------------------------------
* Date who Reference Description
* 11-Jan-2010 Ganesh R ODR2009100480 Initial Creation
* 26-Oct-2010 Chandra Prakash ODR-2009-09-0080 Modification - C.19 Interface
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.TRANS.CODE.PARAM
    $INSERT I_F.TRANSACTION
    $INSERT I_F.TELLER.TRANSACTION

    IF VAL.TEXT NE "" THEN
        RETURN
    END

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

*---*
INIT:
*---*
*--------------------------*
*Initialising the Variables
*--------------------------*
    LOC.REF.APPLICATION='TELLER'
    LOC.REF.FIELDS='L.TT.MET.OF.PAY'
    LOC.REF.POS=''

RETURN

*--------*
OPEN.FILES:
*--------*
    FN.REDO.TRANS.PARAM='F.REDO.TRANS.CODE.PARAM'
    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    FN.TRANSACTION = 'F.TRANSACTION'
RETURN
*--------*
PROCESS:
*--------*
*------------------*
*Updating the Fields
*------------------*

    REC.ID='SYSTEM'
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    L.TT.MET.OF.PAY.POS=LOC.REF.POS<1,1>
    T.CODE=COMI
    CALL CACHE.READ(FN.REDO.TRANS.PARAM,REC.ID,R.REDO.TRANS.PARAM,REC.ERR)

    LOCATE COMI IN R.REDO.TRANS.PARAM<REDO.TS.TRANS.CODE,1> SETTING POS ELSE
        POS = ''
    END
    IF POS THEN
        VAL.TYPE = R.REDO.TRANS.PARAM<REDO.TS.TRAN.TYPE><1,POS>
        R.NEW(TT.TE.LOCAL.REF)<1,L.TT.MET.OF.PAY.POS> = VAL.TYPE
        GOSUB GET.ACCOUNTS
    END

RETURN
*------------
GET.ACCOUNTS:
*------------
    R.TELLER.TRANSACTION = ''
    TELLER.TRANSACTION.ERR = ''

    CALL CACHE.READ(FN.TELLER.TRANSACTION,T.CODE,R.TELLER.TRANSACTION,TELLER.TRANSACTION.ERR)
    TRANSACTION.CODE.1 = R.TELLER.TRANSACTION<TT.TR.TRANSACTION.CODE.1>
    R.TRANSACTION.REC = ""
    TRANSACTION.ERR = ""

    CALL CACHE.READ(FN.TRANSACTION,TRANSACTION.CODE.1,R.TRANSACTION.REC,TRANSACTION.ERR)

    IF R.TRANSACTION.REC<AC.TRA.DEBIT.CREDIT.IND> EQ "CREDIT" THEN
        R.NEW(TT.TE.ACCOUNT.1) = R.REDO.TRANS.PARAM<REDO.TS.CR.ACCT.NO,POS>
        R.NEW(TT.TE.ACCOUNT.2) = R.REDO.TRANS.PARAM<REDO.TS.DR.ACCT.NO,POS>
    END ELSE
        R.NEW(TT.TE.ACCOUNT.2) = R.REDO.TRANS.PARAM<REDO.TS.CR.ACCT.NO,POS>
        R.NEW(TT.TE.ACCOUNT.1) = R.REDO.TRANS.PARAM<REDO.TS.DR.ACCT.NO,POS>
    END

RETURN
END
