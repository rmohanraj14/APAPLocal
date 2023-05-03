* @ValidationCode : MjotOTg1MjI4ODA0OkNwMTI1MjoxNjgxNzI5NjcxNDQ5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:37:51
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
SUBROUTINE REDO.V.INP.OVR.TTLR
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This subroutine would show a override message, which would deliver
* the user a message if the option for the field, STOPPAYMENT.STATUS has been
* selected as Non-Confirmed or Confirmed
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who           Reference            Description
* 25-Nov-2009       SHANKAR RAJU                            Initial Creation
* 26-SEPT-2009       JEEVA T         PACS00134605          trim is used to remove leading zero's
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.TELLER
    $INSERT I_F.ACCOUNT
*$INSERT I_F.CHEQUES.STOPPED ;*Tus Start
    $INSERT I_F.CHEQUE.REGISTER.SUPPLEMENT ;*Tus End
    $INSERT I_F.REDO.CHEQUE.STOP.PARA
    $INSERT I_F.CHEQUE.TYPE.ACCOUNT

*------------------------------MAIN------------------------------------------

    GOSUB INIT
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------------

*------------------------------INIT------------------------------------------
INIT:

    FN.REDO.CHEQUE.STOP.PARA = 'F.REDO.CHEQUE.STOP.PARA'
    F.REDO.CHEQUE.STOP.PARA = ''

*FN.CHEQ.STOP = 'F.CHEQUES.STOPPED';*TUS start
*F.CHEQ.STOP = '';*TUS End


    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.REDO.CHEQUE.STOP.PARA,F.REDO.CHEQUE.STOP.PARA)
*CALL OPF(FN.CHEQ.STOP,F.CHEQ.STOP);*Tus (S/E)

RETURN
*----------------------------------------------------------------------------

*----------------------------------------------------------------------------
PROCESS:


    Y.CUS = ''
    Y.FLAG = 1
    CHEQUE.NO1=R.NEW(TT.TE.CHEQUE.NUMBER)
    Y.CHEQ.NUM = DCOUNT(CHEQUE.NO1,@VM)

    IF CHEQUE.NO1 NE '' THEN

        DEBT.AC.NO = R.NEW(TT.TE.ACCOUNT.1)
        CALL F.READ(FN.ACCOUNT,DEBT.AC.NO,R.ACCOUNT,F.ACCOUNT,Y.ERR)
        Y.CUS = R.ACCOUNT<AC.CUSTOMER>
        IF Y.CUS EQ '' THEN
            DEBT.AC.NO = R.NEW(TT.TE.ACCOUNT.2)
        END

        COUNTER.LOOP = 1
        LOOP
        WHILE COUNTER.LOOP LE Y.CHEQ.NUM

            FIRST.CHQ.NO=CHEQUE.NO1<1,COUNTER.LOOP>
            FIRST.CHQ.NO = TRIM(FIRST.CHQ.NO,'0','L')
*    Y.ID = DEBT.AC.NO:"*":FIRST.CHQ.NO ;*Tus Start
*    CALL F.READ(FN.CHEQ.STOP,Y.ID,R.CHEQ.STOP,F.CHEQ.STOP,Y.ERR.CH)
            FN.CHEQUE.REGISTER.SUPPLEMENT="F.CHEQUE.REGISTER.SUPPLEMENT"
            F.CHEQUE.REGISTER.SUPPLEMENT=""
            CALL OPF(FN.CHEQUE.REGISTER.SUPPLEMENT,F.CHEQUE.REGISTER.SUPPLEMENT)

            FN.CHEQUE.TYPE.ACCOUNT = "F.CHEQUE.TYPE.ACCOUNT"
            F.CHEQUE.TYPE.ACCOUNT = ""
            CALL OPF(FN.CHEQUE.TYPE.ACCOUNT,F.CHEQUE.TYPE.ACCOUNT)

            CALL F.READ (FN.CHEQUE.TYPE.ACCOUNT,DEBT.AC.NO, REC.CHEQUE.TYPE.ACCOUNT, F.CHEQUE.TYPE.ACCOUNT,CHQ.TYPE.ERR)
            CHQ.TYPE = REC.CHEQUE.TYPE.ACCOUNT<CHQ.TYP.CHEQUE.TYPE,1>
            Y.ID = CHQ.TYPE:".":DEBT.AC.NO:".":FIRST.CHQ.NO

            CALL F.READ(FN.CHEQUE.REGISTER.SUPPLEMENT,Y.ID,R.CHEQUE.REGISTER.SUPPLEMENT,F.CHEQUE.REGISTER.SUPPLEMENT,ERR.CH.STOPPED)
            CHQ.STATUS = R.CHEQUE.REGISTER.SUPPLEMENT<CC.CRS.STATUS>
            IF CHQ.STATUS EQ 'STOPPED' THEN
                Y.AMT.FRM = R.CHEQUE.REGISTER.SUPPLEMENT<CC.CRS.AMOUNT.FROM>
                Y.AMT.TO = R.CHEQUE.REGISTER.SUPPLEMENT<CC.CRS.AMOUNT.TO>
            END
*  Y.AMT.FRM = R.CHEQ.STOP<CHQ.STP.AMOUNT.FROM>
*  Y.AMT.TO = R.CHEQ.STOP<CHQ.STP.AMOUNT.TO>;*Tus End
            Y.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)
            CALL F.READ(FN.REDO.CHEQUE.STOP.PARA,Y.ID,R.REDO.CHEQUE.STOP.PARA,F.REDO.CHEQUE.STOP.PARA,Y.ERR)
            GOSUB OVER.DIS.CHECK
            COUNTER.LOOP += 1 ;*R22 Auto code conversion

        REPEAT
    END

RETURN
*-----------------------------------------------------------------------------------------------------
OVER.DIS.CHECK:

    IF R.REDO.CHEQUE.STOP.PARA THEN
        IF Y.AMT.FRM THEN
            IF Y.AMT.FRM GT Y.AMT THEN
                Y.FLAG = ''
            END
            IF Y.AMT.TO AND Y.AMT.TO LT Y.AMT THEN
                Y.FLAG = ''
            END
            IF Y.FLAG EQ '1' THEN
                Y.STATUS = R.REDO.CHEQUE.STOP.PARA<CHQ.STOP.STATUS>
                GOSUB DISPLAY.MESSAGE
            END

        END ELSE
            Y.STATUS = R.REDO.CHEQUE.STOP.PARA<CHQ.STOP.STATUS>
            GOSUB DISPLAY.MESSAGE
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------------
DISPLAY.ERROR:

    AF = TT.TE.CHEQUE.NUMBER
    AV = COUNTER.LOOP
    ETEXT='EB-DESC.CHEQUE.STATUS':@FM:FIRST.CHQ.NO
    CALL STORE.END.ERROR
    GOSUB END.ROU

RETURN
*----------------------------------------------------------------------------------------------------
DISPLAY.OVERRIDE:

    TEXT='STATUS.OF.CHEQUE':@FM:FIRST.CHQ.NO
    CALL STORE.OVERRIDE(CURR.NO+1)
    GOSUB END.ROU
RETURN
*---------------------------------------------------------------------------------------------------
DISPLAY.MESSAGE:

    CURR.NO = DCOUNT(R.NEW(TT.TE.OVERRIDE),@VM)
    IF Y.STATUS EQ 'NONCONFIRMED' THEN

        GOSUB DISPLAY.OVERRIDE

    END ELSE
        IF Y.STATUS EQ 'CONFIRMED' THEN

            GOSUB DISPLAY.ERROR
        END
    END
RETURN

*---------------------------------------------------------------------------------------------------
END.ROU:

END
*-----------------------------------------------------------------------------------------------------
