* @ValidationCode : Mjo3OTkzNDg2MjU6Q3AxMjUyOjE2ODEzMDI2NzUzMjA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:01:15
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
SUBROUTINE REDO.V.AUTH.COLL.MVMT.DETS
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.V.AUTH.COLL.MVMT.DETS
*--------------------------------------------------------------------------------------------------------
*Description       :
*
*Linked With       : Enquiry REDO.APAP.NOF.LAON.STATUS.RPT
*In  Parameter     : N/A
*Out Parameter     : N/A
*Files  Used       : AA.ARRANGEMENT
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date                 Who                        Reference                   Description
*     ------               -----                      -------------                -------------
* 15 FEB 2011          Ganesh R                       PACS00180415                 UPDATE collateral and AA details for Report 163.
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.REDO.MVMT.COLLATERAL
*-------------------------------------------------------------------------------------------------------
**********
MAIN.PARA:
**********
* This is the para from where the execution of the code starts
    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB OPEN.PARA
        GOSUB PROCESS.PARA
    END
    IF APPLICATION EQ 'COLLATERAL' THEN
        GOSUB OPEN.PARA
        GOSUB UPDATE.DETAILS
    END

RETURN
*--------------------------------------------------------------------------------------------------------
**********
OPEN.PARA:
**********
* In this para of the code, file variables are initialised and opened

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.AA.ARR.ACCOUNT = ''
    CALL OPF(FN.AA.ARR.ACCOUNT,F.AA.ARR.ACCOUNT)

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT = ''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.REDO.MVMT.COLLATERAL = 'F.REDO.MVMT.COLLATERAL'
    F.REDO.MVMT.COLLATERAL  = ''
    CALL OPF(FN.REDO.MVMT.COLLATERAL,F.REDO.MVMT.COLLATERAL)

    FN.REDO.MVMT.LIST = 'F.REDO.MVMT.LIST'
    F.REDO.MVMT.LIST  = ''
    CALL OPF(FN.REDO.MVMT.LIST,F.REDO.MVMT.LIST)

    Y.TERM.ACC.IDS = '' ; BALANCE.TO.CHECK = '' ; Y.AMOUNT = '' ; Y.OUTSTANDING.BAL = '' ; Y.LOAN.NUMBER = ''
    Y.DISBUR.DATE = ''  ; Y.DISBUR.DATE1 = '' ; Y.PRO.TYP = '' ; Y.GTEE.DOC = '' ; Y.PRE.LOA.NO = ''
    Y.DISBURS.AMT = '' ; Y.DESC = ''

RETURN

*--------------------------------------------------------------------------------------------------------
*************
PROCESS.PARA:
*************
* This is the main processing para

    GOSUB FIND.MULTI.LOCAL.REF
    GOSUB GET.AA.DETAILS
    GOSUB FINAL.WRITE

RETURN
*--------------------------------------------------------------------------------------------------------
***********************
GET.AA.DETAILS:
***********************

    GOSUB GET.AA.ARR.TERM.AMOUNT
    IF Y.CONT.FLAG THEN
        GOSUB GET.AA.ARR.ACCOUNT
    END
    Y.DISBURS.AMT = Y.AMOUNT

RETURN

***********************
GET.AA.ARR.TERM.AMOUNT:
***********************
    Y.CONT.FLAG    = ''
    Y.TERM.ACC.IDS = ''
    Y.AMOUNT       = ''

    ARR.AMT.ID      = c_aalocArrId
    EFF.AMT.DATE    = TODAY
    PROP.AMT.CLASS  = 'TERM.AMOUNT'
    PROPERTY.AMT    = ''
    R.AMT.CONDITION = ''
    ERR.AMT.MSG     = ''
    CALL REDO.CRR.GET.CONDITIONS(ARR.AMT.ID,EFF.AMT.DATE,PROP.AMT.CLASS,PROPERTY.AMT,R.AMT.CONDITION,ERR.AMT.MSG)
    Y.AMT.COLL.ID = R.AMT.CONDITION<AA.AMT.LOCAL.REF,L.AA.COL.POS>
    IF NOT(Y.AMT.COLL.ID) THEN
        RETURN
    END
    Y.COLLATERAL.ID = c_aalocArrId:'.':Y.AMT.COLL.ID
    CALL F.READ(FN.COLLATERAL,Y.AMT.COLL.ID,R.COLLATERAL,F.COLLATERAL,COLLATERAL.ER)
    IF R.COLLATERAL THEN
        Y.CONT.FLAG = 1
    END ELSE
        RETURN
    END
    IF Y.CONT.FLAG THEN
        LOCATE FIELD(ARR.AMT.ID,'-',1) IN Y.TERM.ACC.IDS SETTING Y.AA.POS THEN
            Y.AMOUNT<Y.AA.POS> += R.AMT.CONDITION<AA.AMT.AMOUNT>
        END ELSE
            Y.TERM.ACC.IDS<-1> = FIELD(ARR.AMT.ID,'-',1)
            Y.AMOUNT<-1> = R.AMT.CONDITION<AA.AMT.AMOUNT>
        END
    END

RETURN

*********************
GET.AA.ARR.ACCOUNT:
*********************
    Y.LOAN.NUMBER = '' ; Y.DISBUR.DATE1 = '' ; Y.PRO.TYP = '' ; Y.GTEE.DOC = '' ; Y.PRE.LOA.NO = ''

    LOOP
        REMOVE SEL.AA.ID FROM Y.TERM.ACC.IDS SETTING Y.AA.POS
    WHILE SEL.AA.ID:Y.AA.POS
        ARR.ID      = SEL.AA.ID
        EFF.DATE    = TODAY
        PROP.CLASS  = 'ACCOUNT'
        PROPERTY    = ''
        R.CONDITION = ''
        ERR.MSG     = ''

        CALL REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.AA.ARR.ACCOUNT,ERR.MSG)

        IF SEL.AA.ID THEN
            Y.LOAN.NUMBER<-1> = SEL.AA.ID
        END ELSE
            Y.LOAN.NUMBER<-1> = ''
        END

        IF R.AA.ARR.ACCOUNT<AA.AC.ACCOUNT.TITLE.1> THEN
            Y.PRO.TYP<-1> = R.AA.ARR.ACCOUNT<AA.AC.ACCOUNT.TITLE.1>
        END ELSE
            Y.PRO.TYP<-1> = ''
        END

        IF R.AA.ARR.ACCOUNT<AA.AC.LOCAL.REF,L.AA.LOAN.DOC.POS> THEN
            Y.GTEE.DOC<-1> = R.AA.ARR.ACCOUNT<AA.AC.LOCAL.REF,L.AA.LOAN.DOC.POS>
        END ELSE
            Y.GTEE.DOC<-1> = ''
        END

        IF R.AA.ARR.ACCOUNT<AA.AC.ALT.ID> THEN
            Y.PRE.LOA.NO<-1> = R.AA.ARR.ACCOUNT<AA.AC.ALT.ID>
        END ELSE
            Y.PRE.LOA.NO<-1> = ''
        END

        CALL F.READ(FN.AA.ACCOUNT.DETAILS,SEL.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.AA.ERR)
        IF R.AA.ACCOUNT.DETAILS<AA.AD.START.DATE> THEN
            Y.DISBUR.DATE1<-1> = R.AA.ACCOUNT.DETAILS<AA.AD.START.DATE>
        END ELSE
            Y.DISBUR.DATE1<-1> = ''
        END

        CALL F.READ(FN.AA.ARRANGEMENT,SEL.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARRANGEMENT.ERR)
        Y.LINK.APP = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>
        Y.LINK.APP.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
        Y.BALANCE.TO.CHECK.ARRAY = 'CURACCOUNT':@VM:'DUEACCOUNT':@VM:'GRCACCOUNT':@VM:'DELACCOUNT':@VM:'NABACCOUNT'

        GOSUB BALANCE.CHECK

    REPEAT
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------------
**************
BALANCE.CHECK:
**************
    Y.OUTSTANDING.BAL1 = ''
    LOOP
        REMOVE BALANCE.TO.CHECK FROM Y.BALANCE.TO.CHECK.ARRAY SETTING Y.BAL.CHECK.POS
    WHILE BALANCE.TO.CHECK:Y.BAL.CHECK.POS
        DATE.OPTIONS = ''
        EFFECTIVE.DATE = TODAY
        DATE.OPTIONS<4>  = 'ECB'
        BALANCE.AMOUNT = ""
        CALL AA.GET.PERIOD.BALANCES(Y.LINK.APP.ID, BALANCE.TO.CHECK, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")
        Y.OUTSTANDING.BAL1 = Y.OUTSTANDING.BAL1 + BAL.DETAILS<IC.ACT.BALANCE>
    REPEAT

    IF Y.OUTSTANDING.BAL1 THEN
        Y.OUTSTANDING.BAL<-1> = Y.OUTSTANDING.BAL1
    END ELSE
        Y.OUTSTANDING.BAL<-1> = ''
    END

RETURN
*-------------------------------------------------------------------------------------------------------------------------------------------
*********************
FIND.MULTI.LOCAL.REF:
*********************

    APPL.ARRAY ='COLLATERAL':@FM:'AA.ARR.ACCOUNT':@FM:'AA.ARR.TERM.AMOUNT'
    FLD.ARRAY  ='L.AC.LK.COL.ID':@VM:'L.CO.MVMT.TYPE':@VM:'L.CO.REASN.MVMT':@VM:'L.CO.LOC.STATUS':@VM:'L.CO.RES.MVMT':@FM:'L.AA.LOAN.DOC':@FM:'L.AA.COL'
    FLD.POS    = ''

    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
    L.AA.CREDIT.POS     = FLD.POS<1,1>
    L.AA.COL.MVMT.POS   = FLD.POS<1,2>
    L.AA.COL.REAS.POS   = FLD.POS<1,3>
    L.AA.COL.LOC.STAT   = FLD.POS<1,4>
    L.AA.COL.RES.POS    = FLD.POS<1,5>
    L.AA.LOAN.DOC.POS   = FLD.POS<2,1>
    L.AA.COL.POS        = FLD.POS<3,1>

RETURN
*-------------------------------------------------------------------------------------------------------------------------------------------
***************
UPDATE.DETAILS:
***************
    GOSUB FIND.MULTI.LOCAL.REF
    Y.CREDIT.NUM = R.NEW(COLL.LOCAL.REF)<1,L.AA.CREDIT.POS>
    IF Y.CREDIT.NUM THEN
        CALL F.READ(FN.REDO.MVMT.LIST,ID.NEW,R.REDO.MVMT.LIST,F.REDO.MVMT.LIST,COL.ERR)
        IF R.REDO.MVMT.LIST THEN
            Y.MVMT.CNT = DCOUNT(R.REDO.MVMT.LIST,@FM)
            LOOP
                REMOVE Y.MVMT.ID FROM R.REDO.MVMT.LIST SETTING Y.MVMT.POS
            WHILE Y.MVMT.INIT LE Y.MVMT.CNT
                Y.COLLATERAL.ID = Y.MVMT.ID:'.':ID.NEW
                CALL F.READ(FN.REDO.MVMT.COLLATERAL,Y.COLLATERAL.ID,R.REDO.MVMT.COLLATERAL,F.REDO.MVMT.COLLATERAL,COLL.ERR)
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.VAL.DATE>      = R.NEW(COLL.VALUE.DATE)
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.MVMT.TYPE>     = R.NEW(COLL.LOCAL.REF)<1,L.AA.COL.MVMT.POS>
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.REAS.MVMT>     = R.NEW(COLL.LOCAL.REF)<1,L.AA.COL.REAS.POS>
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.LOC.STAT>      = R.NEW(COLL.LOCAL.REF)<1,L.AA.COL.LOC.STAT>
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.COL.CODE>      = R.NEW(COLL.COLLATERAL.CODE)
                R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.RESP.MVMT>     = R.NEW(COLL.LOCAL.REF)<1,L.AA.COL.RES.POS>
                CALL F.WRITE(FN.REDO.MVMT.COLLATERAL,Y.COLLATERAL.ID,R.REDO.MVMT.COLLATERAL)
                Y.MVMT.INIT += 1
            REPEAT
        END
    END
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------
************
FINAL.WRITE:
************
    CALL F.READ(FN.REDO.MVMT.COLLATERAL,Y.COLLATERAL.ID,R.REDO.MVMT.COLLATERAL,F.REDO.MVMT.COLLATERAL,COLL.ERR)
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.VAL.DATE>    = R.COLLATERAL<COLL.VALUE.DATE>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.MVMT.TYPE>   = R.COLLATERAL<COLL.LOCAL.REF><1,L.AA.COL.MVMT.POS>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.REAS.MVMT>   = R.COLLATERAL<COLL.LOCAL.REF><1,L.AA.COL.REAS.POS>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.LOC.STAT>    = R.COLLATERAL<COLL.LOCAL.REF><1,L.AA.COL.LOC.STAT>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.COL.CODE>    = R.COLLATERAL<COLL.COLLATERAL.CODE>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COL.RESP.MVMT>   = R.COLLATERAL<COLL.LOCAL.REF><1,L.AA.COL.RES.POS>
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.COLL.ID>         = Y.AMT.COLL.ID
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.L.GTEE.DOC>      = Y.GTEE.DOC
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.LOAN.NUMBER>     = Y.LOAN.NUMBER
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.PRE.LOA.NO>      = Y.PRE.LOA.NO
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.PRO.TYPE>        = Y.PRO.TYP
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.DISBURSE.DATE>   = Y.DISBUR.DATE1
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.DISBURSE.AMT>    = Y.DISBURS.AMT
    R.REDO.MVMT.COLLATERAL<REDO.MVMT.OUTSTANDING.BAL> = Y.OUTSTANDING.BAL

    CALL F.WRITE(FN.REDO.MVMT.COLLATERAL,Y.COLLATERAL.ID,R.REDO.MVMT.COLLATERAL)
    CALL F.READ(FN.REDO.MVMT.LIST,Y.AMT.COLL.ID,R.REDO.MVMT.LIST,F.REDO.MVMT.LIST,REDO.MVMT.ERR)
    IF R.REDO.MVMT.LIST THEN
        LOCATE c_aalocArrId IN R.REDO.MVMT.LIST SETTING ARR.POS ELSE
            R.REDO.MVMT.LIST<-1> = c_aalocArrId
        END
    END ELSE
        R.REDO.MVMT.LIST<-1> = c_aalocArrId
    END
    CALL F.WRITE(FN.REDO.MVMT.LIST,Y.AMT.COLL.ID,R.REDO.MVMT.LIST)
RETURN
END
*----------------------------------------------------------------------------------------------------------------------------------------------
