* @ValidationCode : MjoxNzkwMTY2NTI4OkNwMTI1MjoxNjg1NTI5OTgzNDI0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:16:23
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
$PACKAGE APAP.AA
SUBROUTINE REDO.E.NOF.AA.HIST.PAYM.DET(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Bank name: APAP
* Decription: The loan payment history will be reflected in the Enquiry report REDO.AA.HIST.PAYM.DET.
* Developed By: V.P.Ashokkumar
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.ACTIVITY
    $INSERT I_F.AA.PROPERTY
    $USING APAP.TAM
    GOSUB INIT
    GOSUB LOCATE.VAL
    GOSUB PROCESS
RETURN

INIT:
*****
    FINY.PRIN.BL = '0'; FINY.INT.BL = '0'; FINY.OT.BL = '0'
    FINY.INS.BL = '0'; ENQ.DATA = ''; FIN.YMORA.BL = '0'
    FIN.YINSUR.BL = '0'
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'; F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    FN.ACCOUNT = 'F.ACCOUNT'; F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    FN.ACCOUNT.HST = 'F.ACCOUNT$HIS'; F.ACCOUNT.HST = ''
    CALL OPF(FN.ACCOUNT.HST,F.ACCOUNT.HST)
    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'; F.AA.ACTIVITY.HISTORY  = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)
    FN.AAA = 'F.AA.ARRANGEMENT.ACTIVITY'; F.AAA  = ''
    CALL OPF(FN.AAA,F.AAA)
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'; F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'; F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
    FN.AA.ACTIVITY = 'F.AA.ACTIVITY'; F.AA.ACTIVITY = ''
    CALL OPF(FN.AA.ACTIVITY,F.AA.ACTIVITY)
    FN.AA.ACT.BAL = 'F.AA.ACTIVITY.BALANCES'; F.AA.ACT.BAL = ''
    CALL OPF(FN.AA.ACT.BAL,F.AA.ACT.BAL)
RETURN

LOCATE.VAL:
***********
    LOCATE "ARRANGEMENT.ID" IN D.FIELDS SETTING CUS.POS THEN
        Y.ARR.ID = D.RANGE.AND.VALUE<CUS.POS>
    END

    Y.START.DATE = ''; Y.END.DATE = ''
    LOCATE "DATE.RANGE" IN D.FIELDS SETTING Y.FECHA.POS THEN
        Y.DATES = D.RANGE.AND.VALUE<Y.FECHA.POS>
        Y.DATE.OPERAND = D.LOGICAL.OPERANDS<Y.FECHA.POS>
        Y.START.DATE = FIELD(Y.DATES, @SM, 1)
        Y.END.DATE = FIELD(Y.DATES, @SM, 2)
        IF NOT(Y.START.DATE) OR NOT(Y.END.DATE) THEN
            ENQ.ERROR = 'AZ-ENTER.BOTH.DATES'
            GOSUB PROGRAM.EXT
        END
        IF Y.START.DATE GT Y.END.DATE THEN
            ENQ.ERROR = 'AZ-ST.DATE.GT.END.DATE'
            GOSUB PROGRAM.EXT
        END
    END
RETURN

PROCESS:
********
    GOSUB READ.ARRANGEMENT
    IF NOT(R.AA.ARRANGEMENT) THEN
        GOSUB READ.ACCOUNT
        YACCT.ID = Y.ARR.ID
        IF NOT(R.ACCOUNT) THEN
            E = 'AA-INVALID.AA.LOAN.ID'
            GOSUB PROGRAM.EXT
        END
    END
    IF NOT(R.AA.ARRANGEMENT) THEN
        GOSUB READ.ARRANGEMENT
    END
    ERR.AA.ACCOUNT.DETAILS = ''; R.AA.ACCOUNT.DETAILS = ''; YAAD.REFID = ''; YAAD.BILL = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ERR.AA.ACCOUNT.DETAILS)
    YAAD.REFID = R.AA.ACCOUNT.DETAILS<AA.AD.ACTIVITY.REF>
    YAAD.BILL = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>

    ERR.AA.ACTIVITY.HISTORY = ''; R.AA.ACTIVITY.HISTORY = ''; YACT.RECS = ''; YACT.IDR = ''
    YTOT.AMT = 0
    CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.ARR.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,ERR.AA.ACTIVITY.HISTORY)
    YACT.RECS = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>
    YACT.IDR = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY.REF>
    CHANGE @SM TO @FM IN YACT.IDR
    CHANGE @VM TO @FM IN YACT.IDR
    YCNT = DCOUNT(YACT.IDR,@FM)

    BAL.ERR = ''; R.AA.ACT.BAL = '' ; YACT.REF.BAL = ''
    CALL F.READ(FN.AA.ACT.BAL,Y.ARR.ID,R.AA.ACT.BAL,F.AA.ACT.BAL,BAL.ERR)
    YACT.REF.BAL = R.AA.ACT.BAL<AA.ACT.BAL.ACTIVITY.REF>
    YTMP.CNT = 0
    LOOP
        REMOVE YACT.ID FROM YACT.IDR SETTING AA.POSN
    WHILE YACT.ID:AA.POSN
        YACT.ID = YACT.IDR<YCNT>
        ERR.AAA = ''; R.AAA = ''; YORG.AMT = ''; YCO.CODE = ''; YEFF.DATE = ''; YACT.RSTVAL = ''
        YPAGO.TOT = ''; Y.PRIN.BL = ''; Y.INT.BL = ''; Y.OT.BL = ''; Y.INS.BL = ''
        YACTIVITY = ''; YMORA.BL = ''; YINSUR.BL = ''; PAGO.DTE = ''; YSTMT.NOS = ''
        CALL F.READ(FN.AAA,YACT.ID,R.AAA,F.AAA,ERR.AAA)
        YORG.AMT  = R.AAA<AA.ARR.ACT.ORIG.TXN.AMT>
        YCO.CODE = R.AAA<AA.ARR.ACT.CO.CODE>[8,2]
        YEFF.DATE = R.AAA<AA.ARR.ACT.EFFECTIVE.DATE>
        YACTIVITY = R.AAA<AA.ARR.ACT.ACTIVITY>
        YFIELD.VALUE = R.AAA<AA.ARR.ACT.FIELD.VALUE>
        YSTMT.NOS = R.AAA<AA.ARR.ACT.STMT.NOS>
        PAGO.DTE = OCONV(ICONV(YEFF.DATE,'D'),'D')
        AA.ACTIVITY.ERR = ''; R.AA.ACTIVITY = ''; YDESC = ''; YACT.2NDVAL = ''
        YACT.2NDVAL = FIELD(YACTIVITY,'-',2)
        YACT.RSTVAL = FIELD(YACTIVITY,'-',2,99)
        CALL CACHE.READ(FN.AA.ACTIVITY, YACTIVITY, R.AA.ACTIVITY, AA.ACTIVITY.ERR) ;* AUTO R22 CODE CONVERSION - F.READ TO CACHE.READ
        YDESC = R.AA.ACTIVITY<AA.ACT.DESCRIPTION,LNGG>
        IF NOT(YDESC) THEN
            YDESC = R.AA.ACTIVITY<AA.ACT.DESCRIPTION,1>
        END

        IF YACTIVITY EQ 'LENDING-TAKEOVER-ARRANGEMENT' THEN
            Y.COMMITED.AMT = 0; Y.DISBURSE.DATE = ''; YMIG.STAT = ''
            APAP.TAM.redoGetDisbursementDetails(Y.ARR.ID,R.DISB.DETAILS,Y.COMMITED.AMT,Y.PEND.DISB);*R22 Manual conversion
            Y.DISBURSE.AMT = R.DISB.DETAILS<3>
            Y.DISBURSE.DATE= R.DISB.DETAILS<1>
            YMIG.STAT = R.DISB.DETAILS<4>
            YCNT -= 1 ;* AUTO R22 CODE CONVERSION
            CONTINUE
        END

        IF (YORG.AMT EQ '' OR YORG.AMT EQ 0) AND YFIELD.VALUE EQ '' AND NOT(YSTMT.NOS) THEN
            YCNT -= 1 ;* AUTO R22 CODE CONVERSION
            CONTINUE
        END

        YAAD.BILLID = ''; YAAD.BILLDTE = ''; YAAD.SETSTAT = ''; YTP.FLG = 0
        LOCATE YACT.ID IN YAAD.REFID<1,1> SETTING Y.POSN THEN
            YAAD.BILLID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,Y.POSN>
            YAAD.BILLDTE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.DATE,Y.POSN>
            YAAD.SETSTAT = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS,Y.POSN>
        END
        IF YAAD.BILLID THEN
            GOSUB GET.AA.BILL.DET
        END

        IF NOT(YAAD.BILLID) THEN
            GOSUB CAL.AMT
        END
        YTOT.AMT -= Y.PRIN.BL ;* AUTO R22 CODE CONVERSION
        YPAGO.TOT = Y.PRIN.BL + Y.INT.BL + Y.OT.BL + Y.INS.BL + YMORA.BL + YINSUR.BL
        IF YEFF.DATE GE Y.START.DATE AND YEFF.DATE LE Y.END.DATE THEN
            GOSUB ARRAY.FORM
        END
        YCNT -= 1  ;* AUTO R22 CODE CONVERSION
    REPEAT

    IF ENQ.DATA NE '' THEN
        ENQ.DATA<-1> = ' TOTALES ***':FIN.YPAGO.TOT:'*':FINY.PRIN.BL:'*':FINY.INT.BL:'*':FINY.OT.BL:'*':FIN.YMORA.BL:'*':FIN.YINSUR.BL:'*':FINY.INS.BL:'*'
    END
RETURN

ARRAY.FORM:
**********
    IF (Y.PRIN.BL AND Y.PRIN.BL NE 0) OR (Y.INT.BL AND Y.INT.BL NE 0) OR (Y.OT.BL AND Y.OT.BL NE 0) OR (Y.INS.BL AND Y.INS.BL NE 0) OR (YMORA.BL AND YMORA.BL NE 0) OR (YINSUR.BL AND YINSUR.BL NE 0) THEN
        YTMP.CNT += 1  ;* AUTO R22 CODE CONVERSION
        IF YTMP.CNT EQ 1 THEN
            GOSUB GET.OUT.DETAIL
        END
        IF RIGHT(YACTIVITY,15) EQ 'MANT.SALD.CUOTA' AND YTP.FLG NE 1 THEN
            RETURN
        END
        IF YACTIVITY NE 'LENDING-DISBURSE-COMMITMENT' AND YACTIVITY NE 'LENDING-APPLYPAYMENT-RP.CARGOS.DES' THEN
            ENQ.DATA<-1> = PAGO.DTE:'*':YCO.CODE:'*':YDESC:'*':YPAGO.TOT:'*':Y.PRIN.BL:'*':Y.INT.BL:'*':Y.OT.BL:'*':YMORA.BL:'*':YINSUR.BL:'*':Y.INS.BL:'*':YTOT.AMT
;* AUTO R22 CODE CONVERSION - START
            FIN.YPAGO.TOT += YPAGO.TOT
            FINY.PRIN.BL += Y.PRIN.BL
            FINY.INT.BL += Y.INT.BL
            FINY.OT.BL += Y.OT.BL
            FINY.INS.BL += Y.INS.BL
            FIN.YMORA.BL += YMORA.BL
            FIN.YINSUR.BL += YINSUR.BL
;* AUTO R22 CODE CONVERSION - END
        END
    END
RETURN

GET.OUT.DETAIL:
***************
    BAL.OUTSTANDING = ''; BAL.OUTSTAND = 0
    BALANCE.NAME.VAL =  'CURACCOUNT':@FM:'DUEACCOUNT':@FM:'DE1ACCOUNT':@FM:'DE3ACCOUNT':@FM:'DELACCOUNT':@FM:'NABACCOUNT'
    LOOP
        REMOVE BALANCE.NAME FROM BALANCE.NAME.VAL SETTING B.POSN
    WHILE BALANCE.NAME:B.POSN
        VALUE.TRADE = ''; BAL.DETS = ''; ERR.PROCESS = ''
        VALUE.TRADE<4> = 'ECB'
        VALUE.TRADE<4,2> = 'END'
        Y.DISBURSE.DATE = YEFF.DATE
        CALL AA.GET.PERIOD.BALANCES(YACCT.ID, BALANCE.NAME, VALUE.TRADE, Y.DISBURSE.DATE, Y.DISBURSE.DATE, "", BAL.DETS, ERR.PROCESS)
        BAL.OUTSTANDING += BAL.DETS<4>
*        IF BALANCE.NAME NE 'CURACCOUNT' AND BALANCE.NAME NE 'DUEACCOUNT' THEN
        IF BALANCE.NAME NE 'DUEACCOUNT' THEN
            BAL.OUTSTAND -= BAL.DETS<2>
            BAL.OUTSTAND += ABS(BAL.DETS<3>)
        END
    REPEAT
    YTOT.AMT = ABS(BAL.OUTSTANDING) + ABS(BAL.OUTSTAND)
    IF (BAL.OUTSTAND NE 0 AND BAL.OUTSTAND) THEN

        YTOT.AMT -= Y.PRIN.BL ;* AUTO R22 CODE CONVERSION
    END
RETURN

CAL.AMT:
********
    POS.AAA = ''
    LOCATE YACT.ID IN YACT.REF.BAL<1,1> SETTING POS.AAA THEN
        Y.PROPS = R.AA.ACT.BAL<AA.ACT.BAL.PROPERTY,POS.AAA>
        Y.PROPS.AMTS = R.AA.ACT.BAL<AA.ACT.BAL.PROPERTY.AMT,POS.AAA>
        Y.PR.CNT = DCOUNT(Y.PROPS,@SM) ; FLP = 1
        GOSUB CAL.AMT.SUB
    END
RETURN

CAL.AMT.SUB:
************
    LOOP
    WHILE FLP LE Y.PR.CNT
        Y.PR.CL = Y.PROPS<1,1,FLP>
        Y.PR.CL = FIELD(Y.PR.CL,'.',1)
        IF YMIG.STAT EQ 'MIGRATE' AND (Y.PR.CL[1,10] EQ 'COMMITMENT' OR YACT.2NDVAL EQ 'CAPTURE.BALANCE') THEN
            FLP +=1
            CONTINUE
        END
        IF Y.PR.CL[1,10] EQ 'COMMITMENT' THEN
            FLP +=1
            CONTINUE
        END
        IF YACT.RSTVAL EQ 'ADJUST.BALANCE-MANT.SALD.CUOTA' THEN
            IF Y.PR.CL EQ 'PRINCIPALINT' THEN
                FLP += 1
                CONTINUE
            END ELSE
                YTP.FLG = 1
            END
        END

        GOSUB CASE.SS
        FLP += 1
    REPEAT
RETURN
CASE.SS:
*********
    BEGIN CASE
        CASE Y.PR.CL EQ 'ACCOUNT'
            Y.PRIN.BL += Y.PROPS.AMTS<1,1,FLP>
        CASE Y.PR.CL EQ 'PRINCIPALINT'
            Y.INT.BL += Y.PROPS.AMTS<1,1,FLP>
        CASE Y.PR.CL EQ 'PENALTINT'
            Y.OT.BL += Y.PROPS.AMTS<1,1,FLP>
        CASE Y.PR.CL EQ 'PRMORA'
            YMORA.BL += Y.PROPS.AMTS<1,1,FLP>
        CASE Y.PR.CL[1,3] EQ 'SEG'
            YINSUR.BL += Y.PROPS.AMTS<1,1,FLP>
        CASE 1
            Y.INS.BL += Y.PROPS.AMTS<1,1,FLP>
    END CASE
RETURN

GET.AA.BILL.DET:
****************
    R.AA.BILL.DETAILS = ''; Y.ERR.BILL = ''; Y.PROP.CNT = 0
    CALL F.READ(FN.AA.BILL.DETAILS,YAAD.BILLID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,Y.ERR.BILL)
    Y.TOT.BILL.AMT = R.AA.BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>
    Y.TOT.PROPERTY = R.AA.BILL.DETAILS<AA.BD.PROPERTY>
    Y.PROP.CNT = DCOUNT(Y.TOT.PROPERTY,@VM)
    LOOP
    UNTIL Y.PROP.CNT LE 0
        YADJ.AMT = ''; YPROD.ID = ''; YPAID.AMT = 0; YADJ.REF = ''
        YPROPERTY = R.AA.BILL.DETAILS<AA.BD.PROPERTY,Y.PROP.CNT>
        YPROD.ID = R.AA.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,Y.PROP.CNT>
        YADJ.AMT = R.AA.BILL.DETAILS<AA.BD.ADJUST.AMT,Y.PROP.CNT>
        YADJ.REF = R.AA.BILL.DETAILS<AA.BD.ADJUST.REF,Y.PROP.CNT>
        IF YAAD.SETSTAT NE 'UNPAID' THEN
            YPAID.AMT = YPROD.ID + YADJ.AMT
        END ELSE
            YPAID.AMT = YADJ.AMT
            FINDSTR YACT.ID IN YADJ.REF<1> SETTING AD.POSN,SM.POSN,VM.POSN THEN
                YPAID.AMT = R.AA.BILL.DETAILS<AA.BD.ADJUST.AMT,Y.PROP.CNT,VM.POSN>
            END ELSE
                Y.PROP.CNT -= 1  ;* AUTO R22 CODE CONVERSION
                CONTINUE
            END
        END

        BEGIN CASE
            CASE YPROPERTY EQ 'ACCOUNT'
                Y.PRIN.BL += YPAID.AMT
            CASE YPROPERTY EQ 'PRINCIPALINT'
                Y.INT.BL += YPAID.AMT
            CASE YPROPERTY EQ 'PENALTINT'
                Y.OT.BL += YPAID.AMT
            CASE YPROPERTY EQ 'PRMORA'
                YMORA.BL += YPAID.AMT
            CASE YPROPERTY[1,3] EQ 'SEG'
                YINSUR.BL += YPAID.AMT
            CASE 1
                Y.INS.BL += YPAID.AMT
        END CASE
        Y.PROP.CNT -= 1  ;* AUTO R22 CODE CONVERSION
    REPEAT
RETURN

READ.ACCOUNT:
*************
    ERR.ACCOUNT = ''; R.ACCOUNT = ''; ACCOUNT.HIS.ERR = ''
    CALL F.READ(FN.ACCOUNT,Y.ARR.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    IF NOT(R.ACCOUNT) THEN
        Y.ARR.ID.HST = Y.ARR.ID
        CALL EB.READ.HISTORY.REC(F.ACCOUNT.HST,Y.ARR.ID.HST,R.ACCOUNT,ACCOUNT.HIS.ERR)
    END
    Y.ARR.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
RETURN

READ.ARRANGEMENT:
*****************
    ERR.AA.ARRANGEMENT = ''; R.AA.ARRANGEMENT = ''
    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AA.ARRANGEMENT)
    Y.LINKED.APPL = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>
    Y.LINKED.APPL.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    LOCATE "ACCOUNT" IN Y.LINKED.APPL<1,1> SETTING Y.LINK.POS THEN
        YACCT.ID =Y.LINKED.APPL.ID<Y.LINK.POS>
    END
RETURN

PROGRAM.EXT:
************
END
