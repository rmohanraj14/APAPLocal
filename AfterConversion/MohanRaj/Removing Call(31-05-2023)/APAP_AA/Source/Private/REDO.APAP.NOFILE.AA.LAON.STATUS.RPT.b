* @ValidationCode : MjoxNzcxNDU1NzgwOkNwMTI1MjoxNjg1NTI4NDQ3MDkwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 15:50:47
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
SUBROUTINE REDO.APAP.NOFILE.AA.LAON.STATUS.RPT(Y.OUT.ARRAY)
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.APAP.NOFILE.AA.LAON.STATUS.RPT
*--------------------------------------------------------------------------------------------------------
*Description       : This is a NO-FILE enquiry routine, the routine based on the selection criteria selects
*                    the records from AA.ARRANGEMENT and displays the processed records
*Linked With       : Enquiry REDO.APAP.NOF.LAON.STATUS.RPT
*In  Parameter     : N/A
*Out Parameter     : Y.OUT.ARRAY
*Files  Used       : AA.ARRANGEMENT             As              I               Mode
*                    ACCT.ACTIVITY              As              I               Mode
*                    AA.BILL.DETAILS            As              I               Mode
*                    CUSTOMER                   As              I               Mode
*                    COLLATERAL                 As              I               Mode
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date                 Who                  Reference                 Description
*     ------               -----               -------------              -------------
* 20 August 2010       Shiva Prasad Y       ODR-2010-03-0179 136         Initial Creation
* 29-MAR-2023          Conversion Tool      R22 Auto conversion   CONVERT to CHANGE, CHAR to CHARX, FM TO @FM, VM to @VM, SM to @SM, ++ to +=
* 29-Mar-2023          Harishvikram C       Manual R22 Conversion      Modified call routine format
*-----------------------------------------------------------------------------------

*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.INTEREST.ACCRUALS
*-------------------------------------------------------------------------------------------------------
**********
MAIN.PARA:
**********
* This is the para from where the execution of the code starts
    GOSUB INITIALISE  ;* PACS00313556 - 2014OCT28 - S/E
    GOSUB OPEN.PARA
    GOSUB PROCESS.PARA
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

    FN.AA.ARR.OVERDUE = 'F.AA.ARR.OVERDUE'
    F.AA.ARR.OVERDUE = ''
    CALL OPF(FN.AA.ARR.OVERDUE,F.AA.ARR.OVERDUE)

    FN.AA.ARR.CUSTOMER = 'F.AA.ARR.CUSTOMER'
    F.AA.ARR.CUSTOMER = ''
    CALL OPF(FN.AA.ARR.CUSTOMER,F.AA.ARR.CUSTOMER)

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT = ''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)
RETURN
*--------------------------------------------------------------------------------------------------------
*************
PROCESS.PARA:
*************
* This is the main processing para
    ENQ.ERROR = ''
    GOSUB CHECK.SELECTION
    IF ENQ.ERROR THEN
        RETURN
    END
    GOSUB GET.PROCESSED.IDS

    IF NOT(Y.PROCESSED.IDS) THEN
        RETURN
    END

    GOSUB GET.DETAILS
RETURN
*--------------------------------------------------------------------------------------------------------
****************
CHECK.SELECTION:
****************

    GOSUB GET.AA.ARRANGEMENT.SELECTION
    IF ENQ.ERROR THEN
        RETURN
    END
    GOSUB GET.OVERDUE.SELECTION
    IF ENQ.ERROR THEN
        RETURN
    END
    GOSUB GET.ACCOUNT.SELECTION
    IF ENQ.ERROR THEN
        RETURN
    END
    GOSUB GET.COLLATERAL.SELECTION
    IF ENQ.ERROR THEN
        RETURN
    END
    GOSUB GET.CUSTOMER.SELECTION

RETURN
*--------------------------------------------------------------------------------------------------------
*****************************
GET.AA.ARRANGEMENT.SELECTION:
*****************************

    Y.PROD.GROUP = ''
    Y.PRODUCT = ''

    LOCATE 'LOAN.PORT.TYPE' IN D.FIELDS<1> SETTING Y.PROD.TYPE.POS THEN
        Y.PROD.GROUP = D.RANGE.AND.VALUE<Y.PROD.TYPE.POS>
    END

    LOCATE 'PRODUCT.TYPE' IN D.FIELDS<1> SETTING Y.PROD.POS THEN
        Y.PRODUCT = D.RANGE.AND.VALUE<Y.PROD.POS>
    END

    SEL.CMD.ARR = 'SELECT ':FN.AA.ARRANGEMENT:' WITH ARR.STATUS NE "AUTH" AND WITH ARR.STATUS NE "UNAUTH"'

    IF Y.PROD.GROUP THEN
        SEL.CMD.ARR := ' AND WITH PRODUCT.GROUP EQ "':Y.PROD.GROUP:'"'
    END

    IF Y.PRODUCT THEN
        SEL.CMD.ARR := ' AND WITH PRODUCT EQ "':Y.PRODUCT:'"'
    END

    CALL EB.READLIST(SEL.CMD.ARR,SEL.LIST.ARR,'',NO.OF.REC.ARR,SEL.ERR.ARR)

    IF Y.PROD.GROUP AND NOT(SEL.LIST.ARR) THEN
        ENQ.ERROR = 'EB-INVALID.PROD.GROUP'
    END

    IF Y.PRODUCT AND NOT(SEL.LIST.ARR) THEN
        ENQ.ERROR = 'EB-INVALID.PROD.TYPE'
    END

RETURN
*--------------------------------------------------------------------------------------------------------
**********************
GET.OVERDUE.SELECTION:
**********************
    Y.LOAN.STATUS = ''
    Y.LOAN.COND = ''
    LOCATE 'LOAN.STATUS' IN D.FIELDS<1> SETTING Y.LOAN.STAT.POS THEN
        Y.LOAN.STATUS = D.RANGE.AND.VALUE<Y.LOAN.STAT.POS>

        CHANGE @SM TO ' ' IN Y.LOAN.STATUS ;*R22 Auto conversion
    END

    LOCATE 'LOAN.CONDITION' IN D.FIELDS<1> SETTING Y.LOAN.COND.POS THEN
        Y.LOAN.COND = D.RANGE.AND.VALUE<Y.LOAN.COND.POS>

        CHANGE @SM TO ' ' IN Y.LOAN.COND ;*R22 Auto conversion
    END

    IF NOT(Y.LOAN.STATUS) AND NOT(Y.LOAN.COND) THEN
        RETURN
    END
* PACS00313556 - 2014OCT28 - S
    GOSUB GET.LOAN.ST.EQUIV
    GOSUB GET.OVR.SELECTED.IDS
*    CALL REDO.APAP.GET.LATEST.OVERDUE.IDS(Y.LOAN.STATUS,Y.LOAN.COND,Y.OVR.IDS)
* PACS00313556 - 2014OCT28 - E
    SEL.LIST.OVR = Y.OVR.IDS
    IF Y.LOAN.STATUS AND NOT(SEL.LIST.OVR) THEN
        ENQ.ERROR = 'EB-INVALID.LN.STATUS'
    END
    IF Y.LOAN.COND AND NOT(SEL.LIST.OVR) THEN
        ENQ.ERROR = 'EB-INVALID.LOAN.COND'
    END

RETURN
*--------------------------------------------------------------------------------------------------------
*********************
GET.OVR.SELECTED.IDS:
*********************
    LOOP
        REMOVE AA.ARRANGEMENT.ID FROM SEL.LIST.ARR SETTING Y.SELOVR.POS
    WHILE AA.ARRANGEMENT.ID:Y.SELOVR.POS
        GOSUB CHECK.LDST.OVERD
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
****************
CHECK.LDST.OVERD:
****************
    ARR.ID       = AA.ARRANGEMENT.ID
    EFF.DATE     = TODAY
    PROP.CLASS   = 'OVERDUE'
    PROPERTY     = ''
    R.CONDITION  = ''
    ERR.MSG      = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual Converison - Modified CALL routine format

    Y.LN.STATUS = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.STATUS.1.POS>
    Y.LN.COND   = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.COND.POS>
    CHANGE @SM TO @FM IN Y.LN.STATUS
    CHANGE @VM TO @FM IN Y.LN.STATUS
    CHANGE @SM TO @FM IN Y.LN.COND
    CHANGE @VM TO @FM IN Y.LN.COND

    IF Y.LOAN.STATUS AND Y.LOAN.COND THEN
        GOSUB EVA.BOTH.STATCOND
    END
    IF Y.LOAN.STATUS AND NOT(Y.LOAN.COND) THEN
        GOSUB EVA.CRIT.STATUS
    END
    IF NOT(Y.LOAN.STATUS) AND Y.LOAN.COND THEN
        GOSUB EVA.CRIT.CONDIT
    END
RETURN
*--------------------------------------------------------------------------------------------------------
******************
GET.LOAN.ST.EQUIV:
******************
    Y.EQU.STATE = ''
    BEGIN CASE
        CASE Y.LOAN.STATUS EQ 'COBRANZA JUDICIAL'
            Y.EQU.STATE = Y.LOAN.STATUS
            Y.LOAN.STATUS = 'JudicialCollection'

        CASE Y.LOAN.STATUS EQ 'NORMAL'
            Y.EQU.STATE = Y.LOAN.STATUS
            Y.LOAN.STATUS = 'Normal'

        CASE Y.LOAN.STATUS EQ 'REESTRUCTURADO'
            Y.EQU.STATE = Y.LOAN.STATUS
            Y.LOAN.STATUS = 'Restructured'

        CASE Y.LOAN.STATUS EQ 'CASTIGADO'
            Y.EQU.STATE = Y.LOAN.STATUS
            Y.LOAN.STATUS = 'Write-off'

    END CASE
RETURN
*--------------------------------------------------------------------------------------------------------
******************
EVA.BOTH.STATCOND:
******************
    Y.FLG.STAT = '' ; Y.FLG.COND = ''
    LOCATE Y.LOAN.STATUS IN Y.LN.STATUS SETTING Y.STAT.POS THEN
        Y.FLG.STAT = 1
    END
    LOCATE Y.LOAN.COND IN Y.LN.COND SETTING Y.COND.POS THEN
        Y.FLG.COND = 1
    END
    IF Y.FLG.STAT AND Y.FLG.COND THEN
        Y.OVR.IDS<-1> = AA.ARRANGEMENT.ID
    END
RETURN
*--------------------------------------------------------------------------------------------------------
****************
EVA.CRIT.STATUS:
****************
    Y.FLG.STAT = '' ; Y.FLG.COND = ''
    LOCATE Y.LOAN.STATUS IN Y.LN.STATUS SETTING Y.STAT.POS THEN
        Y.FLG.STAT = 1
    END
    
    IF Y.FLG.STAT THEN
        Y.OVR.IDS<-1> = AA.ARRANGEMENT.ID
    END
RETURN
*--------------------------------------------------------------------------------------------------------
****************
EVA.CRIT.CONDIT:
****************
    Y.FLG.STAT = '' ; Y.FLG.COND = ''
    LOCATE Y.LOAN.COND IN Y.LN.COND SETTING Y.COND.POS THEN
        Y.FLG.COND = 1
    END

    IF Y.FLG.COND THEN
        Y.OVR.IDS<-1> = AA.ARRANGEMENT.ID
    END
RETURN
*--------------------------------------------------------------------------------------------------------
**********************
GET.ACCOUNT.SELECTION:
**********************
    LOCATE 'LOAN.ORG.AGENCY' IN D.FIELDS<1> SETTING Y.LOAN.ORG.POS THEN
        Y.ACC.CO.CODE = D.RANGE.AND.VALUE<Y.LOAN.ORG.POS>
    END ELSE
        RETURN
    END

    IF NOT(Y.ACC.CO.CODE) THEN
        RETURN
    END
    SEL.LIST.ACC = ''
    SEL.CMD.ACC = 'SELECT ':FN.AA.ARR.ACCOUNT:' WITH L.AA.AGNCY.CODE EQ ':Y.ACC.CO.CODE
    CALL EB.READLIST(SEL.CMD.ACC,SEL.LIST.ACC,'',NO.OF.REC.ACC,SEL.ERR.ACC)

    LOOP
        REMOVE AA.ACC.ID FROM SEL.LIST.ACC SETTING Y.ACC.POS
    WHILE AA.ACC.ID:Y.ACC.POS
        Y.ACC.IDS<-1> = FIELD(AA.ACC.ID,'-',1)
    REPEAT

    SEL.LIST.ACC = Y.ACC.IDS
    IF Y.ACC.CO.CODE AND NOT(SEL.LIST.ACC) THEN
        ENQ.ERROR = 'EB-INVALID.ORG.AGENCY'
    END
RETURN
*--------------------------------------------------------------------------------------------------------
*************************
GET.COLLATERAL.SELECTION:
*************************
    LOCATE 'GURANTEE.TYPE' IN D.FIELDS<1> SETTING Y.COL.POS THEN
        Y.COLLATERAL = D.RANGE.AND.VALUE<Y.COL.POS>
    END ELSE
        RETURN
    END

    IF NOT(Y.COLLATERAL) THEN
        RETURN
    END
    SEL.LIST.COL = ''
    SEL.CMD.COL = 'SELECT ':FN.AA.ARR.TERM.AMOUNT:' WITH L.AA.COL EQ ':Y.COLLATERAL
    CALL EB.READLIST(SEL.CMD.COL,SEL.LIST.COL,'',NO.OF.REC.COL,SEL.ERR.COL)

    LOOP
        REMOVE AA.TERM.ACC.ID FROM SEL.LIST.COL SETTING Y.COL.POS
    WHILE AA.TERM.ACC.ID:Y.COL.POS
        Y.TERM.ACC.IDS<-1> = FIELD(AA.TERM.ACC.ID,'-',1)
    REPEAT

    SEL.LIST.COL = Y.TERM.ACC.IDS
    IF Y.COLLATERAL AND NOT(SEL.LIST.COL) THEN
        ENQ.ERROR = 'EB-INVALID.GRNT.TYPE'
    END
RETURN
*--------------------------------------------------------------------------------------------------------
***********************
GET.CUSTOMER.SELECTION:
***********************
    LOCATE 'CAMPAIGN.TYPE' IN D.FIELDS<1> SETTING Y.CAMP.POS THEN
        Y.CAMP.TYPE = D.RANGE.AND.VALUE<Y.CAMP.POS>
    END ELSE
        RETURN
    END

    IF NOT(Y.CAMP.TYPE) THEN
        RETURN
    END
    SEL.LIST.CAMP = ''
    SEL.CMD.CAMP = 'SELECT ':FN.AA.ARR.CUSTOMER:' WITH L.AA.CAMP.TY EQ ':Y.CAMP.TYPE
    CALL EB.READLIST(SEL.CMD.CAMP,SEL.LIST.CAMP,'',NO.OF.REC.CAMP,SEL.ERR.CAMP)

    LOOP
        REMOVE AA.CUS.ID FROM SEL.LIST.CAMP SETTING Y.CUS.POS
    WHILE AA.CUS.ID:Y.CUS.POS
        Y.CUS.IDS<-1> = FIELD(AA.CUS.ID,'-',1)
    REPEAT

    SEL.LIST.CAMP = Y.CUS.IDS
    IF Y.CAMP.TYPE AND NOT(SEL.LIST.CAMP) THEN
        ENQ.ERROR = 'EB-INVALID.CAMP.TYPE'
    END
RETURN
*--------------------------------------------------------------------------------------------------------
******************
GET.PROCESSED.IDS:
******************
    Y.PROCESSED.IDS = SEL.LIST.ARR

    IF SEL.LIST.OVR THEN
        GOSUB GET.OVR.PROCESSED.IDS
    END

    IF NOT(Y.PROCESSED.IDS) THEN
        RETURN
    END

    IF SEL.LIST.ACC THEN
        GOSUB GET.ACC.PROCESSED.IDS
    END

    IF NOT(Y.PROCESSED.IDS) THEN
        RETURN
    END

    IF SEL.LIST.COL THEN
        GOSUB GET.COL.PROCESSED.IDS
    END

    IF NOT(Y.PROCESSED.IDS) THEN
        RETURN
    END

    IF SEL.LIST.CAMP THEN
        GOSUB GET.CAMP.PROCESSED.IDS
    END
RETURN
*--------------------------------------------------------------------------------------------------------
**********************
GET.OVR.PROCESSED.IDS:
**********************
    LOOP
        REMOVE Y.OVR.ID FROM SEL.LIST.OVR SETTING Y.OVR.POS
    WHILE Y.OVR.ID:Y.OVR.POS
        LOCATE Y.OVR.ID IN Y.PROCESSED.IDS SETTING Y.OVR.PRO.POS THEN
            Y.OVR.PROCESSED.IDS<-1> = Y.OVR.ID
        END
    REPEAT

    Y.PROCESSED.IDS = Y.OVR.PROCESSED.IDS

RETURN
*--------------------------------------------------------------------------------------------------------
**********************
GET.ACC.PROCESSED.IDS:
**********************
    LOOP
        REMOVE Y.ACC.ID FROM SEL.LIST.ACC SETTING Y.ACC.POS
    WHILE Y.ACC.ID:Y.ACC.POS
        LOCATE Y.ACC.ID IN Y.PROCESSED.IDS SETTING Y.ACC.PRO.POS THEN
            Y.ACC.PROCESSED.IDS<-1> = Y.ACC.ID
        END
    REPEAT

    Y.PROCESSED.IDS = Y.ACC.PROCESSED.IDS

RETURN
*--------------------------------------------------------------------------------------------------------
**********************
GET.COL.PROCESSED.IDS:
**********************
    LOOP
        REMOVE Y.COL.ID FROM SEL.LIST.COL SETTING Y.COL.POS
    WHILE Y.COL.ID:Y.COL.POS
        LOCATE Y.COL.ID IN Y.PROCESSED.IDS SETTING Y.COL.PRO.POS THEN
* PACS00313556 - S
            Y.COLL.NUM = ''
            GOSUB GET.COLL.AA.IDS
            IF Y.COLL.NUM GT 0 THEN
                Y.COL.PROCESSED.IDS<-1> = Y.COL.ID
            END
* PACS00313556 - E
        END
    REPEAT
    Y.PROCESSED.IDS = Y.COL.PROCESSED.IDS
RETURN
*--------------------------------------------------------------------------------------------------------
***************
GET.COLL.AA.IDS:
***************
    COL.ID.LINKED = ''
    APAP.AA.RedoColAaGetLinksCol(Y.COL.ID,COL.ID.LINKED);* R22 Manual conversion

    MMARK = CHARX(251) ;*R22 Auto conversion
*
    COL.ID.LINKED = CHANGE(COL.ID.LINKED, MMARK , @VM )
*
    Y.CL.VM     = '' ; Y.CL.VM = DCOUNT(COL.ID.LINKED,@VM)
    Y.CL        = 1
    LOOP
    WHILE Y.CL LE Y.CL.VM
        Y.CL.ID = '' ; Y.CL.ID = COL.ID.LINKED<1,Y.CL,1>
        IF Y.CL.ID NE "" THEN
            Y.COLL.NUM += 1
        END
        Y.CL += 1
    REPEAT
*
RETURN
*--------------------------------------------------------------------------------------------------------
***********************
GET.CAMP.PROCESSED.IDS:
***********************
    LOOP
        REMOVE Y.CAMP.ID FROM SEL.LIST.CAMP SETTING Y.CAMP.POS
    WHILE Y.CAMP.ID:Y.CAMP.POS
        LOCATE Y.CAMP.ID IN Y.PROCESSED.IDS SETTING Y.CAMP.PRO.POS THEN
            Y.CAMP.PROCESSED.IDS<-1> = Y.CAMP.ID
        END
    REPEAT

    Y.PROCESSED.IDS = Y.CAMP.PROCESSED.IDS

RETURN
*--------------------------------------------------------------------------------------------------------
***********
INITIALISE:
***********
    APPL.ARRAY = 'AA.ARR.OVERDUE'
    FLD.ARRAY  = 'L.LOAN.COND':@VM:'L.LOAN.STATUS.1'
    FLD.POS    = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
    LOC.L.LOAN.COND.POS     = FLD.POS<1,1>
    LOC.L.LOAN.STATUS.1.POS = FLD.POS<1,2>
*
    Y.LN.STATUS = ''
    Y.LN.COND   = ''
RETURN
*--------------------------------------------------------------------------------------------------------
************
GET.DETAILS:
************
 
    APAP.AA.redoApapNofileAaLaonStatusRptSplit1(Y.PROCESSED.IDS,Y.LOAN.STATUS,Y.LOAN.COND,Y.OUT.ARRAY);*Manual R22 Conversion
        
RETURN
*--------------------------------------------------------------------------------------------------------
END       ;* End of Prgram
