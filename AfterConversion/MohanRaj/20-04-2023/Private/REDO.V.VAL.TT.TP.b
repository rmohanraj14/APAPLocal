* @ValidationCode : MjotNjgyMzU3MzIxOkNwMTI1MjoxNjgxOTgyNzA4MjQxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 14:55:08
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
SUBROUTINE REDO.V.VAL.TT.TP
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is a input routine which check calls the funtion JEE
*
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
*-----------------------------------------------------------------------------------------
*   Date               who              Reference            Description
* 12-Oct-2010        Naveenkumar        ODR2009100480        Initial Creation
* 26-Oct-2010        Chandra Prakash T  ODR-2009-09-0080     Modification - C.19 Interface
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion    CALL method format modified
*-----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_GTS.COMMON
    $INSERT I_F.EB.ERROR
    $INSERT I_F.REDO.THIRDPRTY.PARAMETER
    $INSERT I_F.REDO.TRANS.CODE.PARAM
    $INSERT JBC.h


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
    LOC.REF.APPLICATION = 'TELLER'
    LOC.REF.FIELDS      = 'L.TT.CMPNY.ID':@VM:'L.TT.MSD':@VM:'L.COMMENTS':@VM:'L.TT.PARTY.NAME'
    LOC.REF.POS         = ''
    Y.INTERFACE.REQ     = ""
RETURN
*---------
OPEN.FILES:
*---------*
    FN.RTP              = 'F.REDO.THIRDPRTY.PARAMETER'
    FN.REDO.TRANS.CODE.PARAM  = "F.REDO.TRANS.CODE.PARAM"
    FN.EB.ERROR='F.EB.ERROR'
    F.EB.ERROR=''
    CALL OPF(FN.EB.ERROR,F.EB.ERROR)
RETURN
*--------*
PROCESS:
*--------*

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    Y.TT.CMPNY.ID.POS   = LOC.REF.POS<1,1>
    Y.TT.MSD.POS        = LOC.REF.POS<1,2>
    Y.TT.COMMENTS       = LOC.REF.POS<1,3>
    Y.PTY.NAME.POS      = LOC.REF.POS<1,4>
    Y.ID                = R.NEW(TT.TE.LOCAL.REF)<1,Y.TT.CMPNY.ID.POS>

    R.REDO.TRANS.CODE.PARAM = ''
    REDO.TRANS.CODE.PARAM.ERR = ''
    CALL CACHE.READ(FN.REDO.TRANS.CODE.PARAM,"SYSTEM",R.REDO.TRANS.CODE.PARAM,REDO.TRANS.CODE.PARAM.ERR)
    ACTIVATION.KEY = R.REDO.TRANS.CODE.PARAM<REDO.TS.ACTIVATION.KEY>
    Y.DELIMITER    = R.REDO.TRANS.CODE.PARAM<REDO.TS.DELIMITER>
    CALL CACHE.READ(FN.RTP,Y.ID,R.RTP,REDO.ERR)
    Y.COMP.ID       = R.RTP<REDO.TP.COMP.NAME>
    Y.INTERFACE.REQ = R.RTP<REDO.TP.INTERFACE.REQ>
    Y.METHOD.LIST   = R.RTP<REDO.TP.METHOD.DESC>
    Y.METHOD.NAMES  = R.RTP<REDO.TP.METHOD.NAME>
    Y.TT.BILL.NUM.VALUE=COMI
    CHANGE @VM TO @FM IN Y.METHOD.LIST
    CHANGE @VM TO @FM IN Y.METHOD.NAMES
    IF Y.INTERFACE.REQ EQ "Y" THEN
        LOCATE "getBalanceByNumber" IN Y.METHOD.LIST SETTING METHOD.POS THEN
            GOSUB PROCESS.EXEC
        END
    END
RETURN
*------------
PROCESS.EXEC:
*------------

    Y.METHOD=Y.METHOD.NAMES<METHOD.POS>
    BEGIN CASE
*--------------------------------------------------------------------------------------------------
*This case is to get the due from the orange company
*--------------------------------------------------------------------------------------------------
        CASE Y.METHOD EQ "getBalanceByNumber"
            EJB_ARGUMENT             = Y.METHOD:Y.DELIMITER:Y.TT.BILL.NUM.VALUE
            Y.RESPONSE               = CALLJEE(ACTIVATION.KEY,EJB_ARGUMENT)
            Y.AMT.POS                = 4
            GOSUB HANDLE.PROCESS
*----------------------------------------------------------------------------------------------------
*This case is to get the due from CODETEL company
*----------------------------------------------------------------------------------------------------

        CASE Y.METHOD EQ  "ENQUIRY_CLIENT_POST_PAYMENT"
            Y.STATUS              = R.RTP<REDO.TP.PHONE.STATUS>
            Y.INTERFACE.USER.NAME = R.RTP<REDO.TP.INTERFACE.USER>
            Y.INTERFACE.PASS      = R.RTP<REDO.TP.INTERFACE.PASS>
            EJB_ARGUMENT=Y.METHOD:Y.DELIMITER:Y.STATUS:Y.DELIMITER:Y.TT.BILL.NUM.VALUE:Y.DELIMITER:Y.INTERFACE.USER.NAME:Y.DELIMITER:Y.INTERFACE.PASS
            Y.RESPONSE  = CALLJEE(ACTIVATION.KEY,EJB_ARGUMENT)
            Y.AMT.POS                = 5
            CHANGE Y.DELIMITER TO @FM IN EJB_ARGUMENT
            IF EJB_ARGUMENT<1> EQ 'SUCCESS' THEN
                EJB_ARGUMENT<Y.AMT.POS>=EJB_ARGUMENT<Y.AMT.POS>+EJB_ARGUMENT<6>
            END
            GOSUB HANDLE.PROCESS
            IF EJB_ARGUMENT<1> EQ 'SUCCESS' THEN
                R.NEW(TT.TE.LOCAL.REF)<1,Y.TT.MSD.POS>=EJB_ARGUMENT<3>
                R.NEW(TT.TE.LOCAL.REF)<1,Y.PTY.NAME.POS>=EJB_ARGUMENT<4>
            END

*---------------------------------------------------------------------------------------------------
*This is to get the due from generic interface
*--------------------------------------------------------------------------------------------------
        CASE Y.METHOD EQ "GetBalance"

            EJB_ARGUMENT=Y.METHOD:Y.DELIMITER:Y.COMP.ID:Y.DELIMITER:Y.TT.BILL.NUM.VALUE
            Y.RESPONSE         = CALLJEE(ACTIVATION.KEY,EJB_ARGUMENT)
            Y.AMT.POS          = 3
            GOSUB HANDLE.PROCESS
    END CASE
RETURN
*--------------
HANDLE.PROCESS:
*--------------
    CHANGE Y.DELIMITER TO @FM IN EJB_ARGUMENT
    IF EJB_ARGUMENT<1> EQ 'SUCCESS' THEN
        IF PGM.VERSION EQ ',REDO.BILL.PAYMNT.CASH' OR PGM.VERSION EQ ',REDO.BILL.PAYMNT' THEN
            R.NEW(TT.TE.AMOUNT.LOCAL.1)=EJB_ARGUMENT<Y.AMT.POS>
        END ELSE
            VAR.AMOUNT =  EJB_ARGUMENT<Y.AMT.POS>
            R.NEW(TT.TE.LOCAL.REF)<1,Y.TT.COMMENTS> = VAR.AMOUNT
        END
    END ELSE
        GOSUB HANDLE.FAIL
    END
RETURN
*------------
HANDLE.FAIL:
*------------
    IF EJB_ARGUMENT<1> EQ 'FAIL' THEN
        ETEXT="EB-INVALID.DATA"
        CALL STORE.END.ERROR
    END
    ELSE

        Y.RESPONSE.MSG = EJB_ARGUMENT[1,4]
        IF Y.RESPONSE.MSG EQ 'FAIL' OR Y.RESPONSE THEN
            Y.MESSAGE=EJB_ARGUMENT<1>
            IF Y.RESPONSE THEN
                CALL CACHE.READ(FN.EB.ERROR, "EB-TP.CON.FAIL.CODE", R.EB.ERROR, ERR) ;*R22 Auto code conversion
                Y.RESP.ERR=R.EB.ERROR<EB.ERR.ERROR.MSG>:' ':Y.RESPONSE
            END
            ELSE
                Y.RESP.ERR =FIELDS(Y.MESSAGE,':',2)
            END
            INT.CODE = 'TPI001'
            INT.TYPE = 'ONLINE'
            BAT.NO = ''
            BAT.TOT = ''
            INFO.OR = ''
            INFO.DE = ''
            ID.PROC = ID.NEW
            MON.TP = '03'
            DESC = Y.RESP.ERR
            REC.CON = ''
            EX.USER = ''
            EX.PC = ''
            CALL APAP.REDO.CHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC) ;* R22 Manual Conversion - CALL method format modified
            ETEXT = "EB-TP.CONNECT.FAIL"
            CALL STORE.END.ERROR
        END
    END
RETURN
END
