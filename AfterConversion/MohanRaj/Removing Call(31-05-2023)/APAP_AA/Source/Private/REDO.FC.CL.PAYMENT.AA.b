* @ValidationCode : MjoxMTY2MjE0NTE5OkNwMTI1MjoxNjg1NTMwMDM1ODQzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:17:15
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
SUBROUTINE REDO.FC.CL.PAYMENT.AA(PAY.AMOUNT, PAY.AA.ID)
* ============================================================================
*    - Gets the information related to the AA specified in input parameter
*    - REGISTER PAYMENTS FOR REDO.CREATE.ARRANGEMENT
* ============================================================================
*
* Subroutine Type : Subroutine to invoke payment processing in REDO.FC.CL.BALANCE
* Attached to     : Invoked by REDO.FC.CL.PROCESS
* Attached as     :
* Primary Purpose : Update Loan/Collateral Balances
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
*-----------------------------------------------------------------------------
* Modification History:
*
* Development for : APAP
* Development by  : btorresalbornoz@temenos.com
* Date            : June 2011
*
* Development by  : Luis Pazmino
* Date            : 19 Sept 2011
* Notes           : Error Handling in F.READ and delete CHECK.CONDITIONS
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION          VM TO @VM ,FM TO @FM and I++ to I=+1, Y to Y.VAR, CHAR to CHARX
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION        CALL method format changed
*
* ============================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL

    $INSERT I_F.REDO.FC.CL.BALANCE
    $INSERT I_F.CREATE.AA
    $USING APAP.REDOCHNLS
    $USING APAP.REDOSRTN
*************************************************************************
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

* ======
PROCESS:
* ======
* PACS00350509 - 2014OCT17 - S
    GOSUB AA.BAL
    Y.AFTER.REPAY.BAL = TOTAL.AMT
* PACS00350509 - 2014OCT17 - E
    CALL F.READU(FN.REDO.FC.CL.BALANCE, PAY.AA.ID, R.REDO.FC.CL.BALANCE, F.REDO.FC.CL.BALANCE, Y.ERR, Y.RETRY)
    IF R.REDO.FC.CL.BALANCE THEN
        PAY.AMOUNT.OG = R.REDO.FC.CL.BALANCE<FC.CL.AA.AMOUNT>
        PAY.AMOUNT.BALANCE = R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE>
        PAY.COLL.ID = R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID>
        Y.NEW.F = 1
        GOSUB GET.UTILAMT         ;* PACS00350509 - 2014NOV07 - S/E
    END ELSE
* PACS00350509 - 2014OCT17 - S
        GOSUB GET.AA.COIDS.MIG
* PACS00350509 - 2014OCT17 - E
    END

RETURN

* ==========
GET.UTILAMT:
* ==========
*
    Y.TMP.TOTAMT = TOTAL.AMT ; Y.FLG.COV = ''
    W.COUNT.C = DCOUNT(PAY.COLL.ID,@VM)
    Y.VAR=1 ; Y.CO.VMP = '' ; Y.TMP.CO.VMP = ''
    LOOP
    WHILE Y.VAR LE W.COUNT.C
*
        GOSUB GET.COID
        GOSUB CALC.INDV.UA
*
        Y.VAR += 1
    REPEAT
*
    PAY.AMOUNT.BALANCE -= PAY.AMOUNT
    PAY.AMOUNT.OG -= PAY.AMOUNT
*
    GOSUB REGISTRA
    GOSUB RETURN.SD
RETURN

* ===============
GET.AA.COIDS.MIG:
* ===============
*
    GOSUB GET.AA.LINKED.COIDS   ;* PACS00350509 - 2014SEP18 - S/E
    Y.CL.NUM = DCOUNT(Y.COL.ID.MIG<1>,@VM)
    Y.VAR = 1 ; Y.CO.NO = 0
    PAY.SD = '' ; PAY.COLL.ID = ''
    LOOP
    WHILE Y.VAR LE Y.CL.NUM
        Y.CL.ID = Y.COL.ID.MIG<1,Y.VAR>
        IF Y.CL.ID NE "" THEN
            GOSUB UPD.CO.AVAMT      ;* PACS00350509 - 2014AUG07 - S/E
            Y.CO.NO += 1
        END
        Y.VAR += 1
    REPEAT
RETURN

* ===========
CALC.INDV.UA:
* ===========
*
    IF TOTAL.AMT NE 0 THEN      ;* Pending Oustanding balance to be supported
        Y.TMP.CO.VMP += Y.CO.VMP
        Y.BEF.DISCNT  = Y.TMP.TOTAMT
        Y.TMP.TOTAMT -= Y.CO.VMP
    END
*
    IF Y.TMP.TOTAMT LT 0 AND Y.FLG.COV OR TOTAL.AMT EQ 0 THEN ;* No utilized amt for current CO. or AA in Payoff
        PAY.SD<1,Y.VAR> = 0
    END
*
    IF Y.TMP.TOTAMT GT 0 AND TOTAL.AMT NE 0 THEN    ;* Pending coll. amount to support outstanding AA balance
        PAY.SD<1,Y.VAR> = Y.CO.VMP    ;* Using maximum amount of co. record
        Y.CO.VMP = ''
    END
*
    IF Y.TMP.TOTAMT EQ 0 AND NOT(Y.FLG.COV) AND TOTAL.AMT NE 0 THEN     ;* Current collateral(s) amount(s) supporting outstanding AA balance
        PAY.SD<1,Y.VAR> = Y.CO.VMP
        Y.CO.VMP  = ''
        Y.FLG.COV = 1
    END
*
    IF Y.TMP.TOTAMT LT 0 AND NOT(Y.FLG.COV) AND TOTAL.AMT NE 0 THEN     ;* Current collateral(s) amount(s) supporting outstanding AA balance
        PAY.SD<1,Y.VAR> = Y.BEF.DISCNT          ;* Using remaining amount (pending Outstanding bal) of curr. co. record
        Y.FLG.COV = 1
    END
RETURN

* ==================
GET.AA.LINKED.COIDS:
* ==================
* Get all collateral linked to AA - TERM.AMOUNT
    APAP.AA.redoColAaGetLinksCol(PAY.AA.ID,COL.ID.LINKED);* R22 Manual conversion
    MMARK = CHARX(251) ; Y.COL.ID.MIG = CHANGE(COL.ID.LINKED, MMARK , @VM )
RETURN

* ======
REGISTRA:
* ======
    CALL F.READU(FN.REDO.FC.CL.BALANCE, PAY.AA.ID, R.REDO.FC.CL.BALANCE, F.REDO.FC.CL.BALANCE, Y.ERR, Y.RETRY)
    IF R.REDO.FC.CL.BALANCE THEN
        R.REDO.FC.CL.BALANCE<FC.CL.AA.AMOUNT>    =  PAY.AMOUNT.OG
        R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE>   =  PAY.AMOUNT.BALANCE
        R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL>    =  PAY.SD
        CALL F.WRITE(FN.REDO.FC.CL.BALANCE,PAY.AA.ID,R.REDO.FC.CL.BALANCE)
    END
RETURN

* ========
RETURN.SD:
* ========
* Updating available collateral balance for S-Multiple attached records
    Y.VAR = 1 ; W.CL.NUM = DCOUNT(PAY.COLL.ID,@VM) ; Y.CO.VMP = ''
    LOOP
    WHILE Y.VAR LE W.CL.NUM
        Y.CL.ID = PAY.COLL.ID<1,Y.VAR>
        GOSUB UPD.CO.AVAMT
        Y.VAR += 1
    REPEAT
RETURN

* =============
GET.AVAIL.AMTB:
* =============
* PACS00350509 - 2014OCT17 - S
    IF Y.NEW.F EQ "" THEN       ;* For migrated contracts
        GOSUB GET.AA.GUARAMT.MIG
    END ELSE
        X.COUNT.C = Y.VAR
        GOSUB GET.AA.GUARAMT.NEW
    END
* PACS00350509 - 2014OCT17 - E
    Y.AVAIL.AMT.BAL = Y.AFTER.REPAY.BAL - Y.CO.VMP  ;* Remaining balance to be covered by Collateral(s)
    IF Y.FLG.COVER EQ 1 AND Y.AVAIL.AMT.BAL LT 0 THEN         ;* Whether  current collateral(s) rec. processed are already covering Loan Outstanding bal
* PACS00350509 - 2014OCT17 - S
        GOSUB SEL.MAXP.LASTCO
* PACS00350509 - 2014OCT17 - E
    END
    IF Y.FLG.COVER EQ "" THEN
        GOSUB NOT.COVER.YET
    END
RETURN

* ============
NOT.COVER.YET:
* ============
*
    IF Y.AVAIL.AMT.BAL GT 0 THEN          ;* Not enough "Maximo a Prestar" amt. (from Collateral(s)) to cover the current Loan Outstanding balance
        Y.AVAIL.AMT.BAL = 0       ;*  Available amount from current CO record totally used
    END
*
    IF Y.AVAIL.AMT.BAL LT 0 THEN          ;* Current collateral is covering the current Loan Outstanding balance
        Y.FLG.COVER = 1
        Y.AVAIL.AMT.BAL = Y.CO.VMP - Y.AFTER.REPAY.BAL          ;* "Maximo a prestar" total, minus Current loan outstanding bal. is the remaining avail amt
    END
RETURN

* ==============
SEL.MAXP.LASTCO:
* ==============
* Get "max a prestar" or "Guaranteed amt" only for current collateral (newest attached one)
*
    IF Y.CO.CODE EQ '150' AND Y.NEW.F EQ "" THEN    ;* Migrated contract and DI product.
        Y.AVAIL.AMT.BAL = Y.AA.CO.BAL
    END

    IF Y.CO.CODE EQ '150' AND Y.NEW.F NE "" THEN    ;* New contract and DI product.
        Y.AVAIL.AMT.BAL = R.REDO.FC.CL.BALANCE<FC.CL.MG.ORIGINAL,Y.VAR>       ;* Summation of all Original amts (Guaranteed amts for NEW recs.) of CO records attached to Loan.
    END

    IF Y.CO.CODE NE '150' THEN  ;* DI product and New or Migrated contract.
        Y.AVAIL.AMT.BAL = R.COLLATERAL<COLL.LOCAL.REF,WPOSMP>
    END
RETURN

* ===========
UPD.CO.AVAMT:
* ===========
* Updating collateral available amount balance by record (L.COL.VAL.AVA)
    R.COLLATERAL = '' ; Y.ERR = ''
    CALL F.READU(FN.COLLATERAL, Y.CL.ID, R.COLLATERAL, F.COLLATERAL, Y.ERR, Y.RETRY)
    IF NOT(Y.ERR) THEN
*
        Y.CO.CODE = R.COLLATERAL<COLL.COLLATERAL.CODE>          ;* PACS00350509 - 2014SEP18 - S/E
*
        GOSUB GET.AVAIL.AMTB
        R.COLLATERAL<COLL.LOCAL.REF,WPOSLI> = Y.AVAIL.AMT.BAL
        CALL F.WRITE(FN.COLLATERAL,Y.CL.ID,R.COLLATERAL)
*
    END ELSE
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.COLLATERAL
        CALL STORE.END.ERROR
    END
RETURN

* =======
GET.COID:
* =======
*
    ERR.CO = '' ; R.COLLATERAL = ''
    CALL F.READ(FN.COLLATERAL,PAY.COLL.ID<1,Y.VAR>,R.COLLATERAL,F.COLLATERAL,ERR.CO)
    Y.CO.CODE = R.COLLATERAL<COLL.COLLATERAL.CODE>
* PACS00350509 - 2014OCT17 - S
    GOSUB GET.AA.GUARAMT.NEW
* PACS00350509 - 2014OCT17 - E
RETURN

* =================
GET.AA.GUARAMT.MIG:
* =================
*
    IF Y.CO.CODE EQ '150' THEN  ;* "Monto Garantizado" amt. value will be Collateral available amt. balance only for collateral "Internal Deposits" (150) type
        Y.ARR.CO.IDS    = Y.COL.ID.MIG<1>
        Y.ARR.CO.AVBALS = Y.COL.ID.MIG<4>
        Y.POS.COID  = ''
        CHANGE @VM TO @FM IN Y.ARR.CO.IDS
        LOCATE Y.CL.ID IN Y.ARR.CO.IDS SETTING Y.POS.COID THEN
            Y.AA.CO.BAL = FIELD(Y.ARR.CO.AVBALS,@VM,Y.POS.COID)
            Y.CO.VMP = Y.AA.CO.BAL  ;* PACS00415505 - S/E
        END
    END ELSE
        Y.CO.VMP = Y.CO.VMP + R.COLLATERAL<COLL.LOCAL.REF,WPOSMP>         ;* Summation of all "VMP" CO records attached to Loan
    END
RETURN

* =================
GET.AA.GUARAMT.NEW:
* =================
*
    IF Y.CO.CODE EQ '150' THEN  ;* "Monto Garantizado" amt. value will be Collateral available amt. balance only for collateral "Internal Deposits" (150) type
        Y.CO.VMP = Y.CO.VMP + R.REDO.FC.CL.BALANCE<FC.CL.MG.ORIGINAL,X.COUNT.C>     ;* Summation of all Original amts (Guaranteed amts for NEW recs.) of CO records attached to Loan.
    END ELSE
        Y.CO.VMP = Y.CO.VMP + R.COLLATERAL<COLL.LOCAL.REF,WPOSMP>         ;* Summation of all "VMP" CO records attached to Loan
    END
RETURN

* =====
AA.BAL:
* =====
* Getting current AA Outstanding Balance value
    TOTAL.AMT = ''
    APAP.REDOSRTN.redoSGetOutBalance(PAY.AA.ID,TOTAL.AMT);* R22 Manual conversion
RETURN

* =========
OPEN.FILES:
* =========
RETURN

* =========
INITIALISE:
* =========
* SE NECESITA RECIBIR LOS VALORES EN LAS VARIABLES DE DEBAJO
* PAY.AMOUNT = VALOR DE EL PAGO
* PAY.AA.ID =  ARRANGEMENT
    R.REDO.FC.CL.BALANCE = ''
    FN.REDO.FC.CL.BALANCE = "F.REDO.FC.CL.BALANCE"
    F.REDO.FC.CL.BALANCE = ""

    R.COLLATERAL = ""
    FN.COLLATERAL = "F.COLLATERAL"
    F.COLLATERAL = ""

    WCAMPO = "L.CO.FILE.DATE"
    WCAMPO<2> = "L.COL.VAL.AVA"
    WCAMPO<3> = "L.COL.LN.MX.VAL"         ;* PACS00352738 S/E
    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,ZPOS)
    WPOSL=ZPOS<1,1>
    WPOSLI=ZPOS<1,2>
    WPOSMP=ZPOS<1,3>  ;* PACS00352738 S/E
* PACS00350509 - S
    COL.ID.LINKED = ''
    Y.COL.ID.MIG  = ''
    PAY.AMOUNT.BALANCE = ''
    PAY.AMOUNT.OG = ''
* PACS00350509 - E
* PACS00350509 - 2014SEP18 - S
    Y.AVAIL.AMT.BAL = ''
    Y.AFTER.REPAY.BAL = ''
    Y.FLG.COVER = ''
    Y.CO.VMP = ''
    Y.ARR.CO.AVBALS = ''
    Y.AA.CO.BAL = ''
    Y.CO.CODE = ''
    Y.ARR.CO.IDS = ''
* PACS00350509 - 2014SEP18 - E
* PACS00350509 - 2014OCT29 - S
    Y.NEW.F             = ''
* PACS00350509 - 2014OCT29 - E
    Y.BEF.DISCNT        = ''
    Y.TMP.TOTAMT        = ''
    PAY.SD              = ''
    X.COUNT.C           = ''
RETURN

END
