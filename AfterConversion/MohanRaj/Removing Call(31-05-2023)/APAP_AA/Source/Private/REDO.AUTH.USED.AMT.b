* @ValidationCode : Mjo0MjEwMjYxODA6Q3AxMjUyOjE2ODU1MjkwMzk1OTU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:00:39
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
SUBROUTINE REDO.AUTH.USED.AMT
*-------------------------------------------------------------------------------------------------------------------------
*DESCRIPTION : The routine is used to update the USED.AMOUNT and AVAILABLE AMOUNT field in CREDIT.LIMIT.MAINTENANCE table
*---------------------------------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.AUTH.USED.AMT
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE WHO REFERENCE DESCRIPTION
*19.07.2010 SUDHARSANAN S ODR-2009-10-0578 INITIAL CREATION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       FM TO @FM, VM to @VM, SM to @SM, ++ to+=
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   CALL routine format modified
*------------------------------------------------------
* -----------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COLLATERAL
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.FOREX
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.CREDIT.LIMIT.MAINTENANCE

    GOSUB INIT
    IF V$FUNCTION EQ 'A' AND APPLICATION EQ 'AA.ARR.TERM.AMOUNT' THEN
        GOSUB PROCESS
    END
    IF APPLICATION NE 'AA.ARR.TERM.AMOUNT' THEN
        GOSUB PROCESS
    END
RETURN
*---------
INIT:
*---------
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMT= ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)


    FN.CUSTOMER= 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.CREDIT.LIMIT.MAINTENANCE = 'F.CREDIT.LIMIT.MAINTENANCE'
    F.CREDIT.LIMIT.MAINTENANCE = ''
    CALL OPF(FN.CREDIT.LIMIT.MAINTENANCE,F.CREDIT.LIMIT.MAINTENANCE)

    FN.FOREX = 'F.FOREX'
    F.FOREX = ''
    CALL OPF(FN.FOREX,F.FOREX)

    FN.AA.ARRANGEMENT.ACTIVITY= 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.SEC.TRADE = 'F.SEC.TRADE'
    F.SEC.TRADE = ''
    CALL OPF(FN.SEC.TRADE,F.SEC.TRADE)

    CUST.ID=''
    VAR1 = ''
    VAR2 = ''
    VAR.AMOUNT = ''
    EFF.DATE=TODAY
    PROPERTY=''
    R.Condition=''
    R.CUS = ''
    ERR.MSG=''
    CALL CACHE.READ(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN,CRD.ERR)

    LOC.REF.APPLICATION="CUSTOMER"
    LOC.REF.FIELDS='L.CU.GRP.RIESGO'
    LOC.REF.POS=''
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.RISK.GROUP=LOC.REF.POS<1,1>


RETURN
*--------
PROCESS:
*--------
    GOSUB CHECK.APPLICATION
* Check if the customer having any risk group
    CALL F.READ(FN.CUSTOMER,CUST.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    VAR.MAIN.SECTOR = R.CUSTOMER<EB.CUS.SECTOR>
    VAR.RISK.GROUP = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.RISK.GROUP>
* Check the main customer is employee of the bank or not
    IF VAR.MAIN.SECTOR EQ 1002 THEN
        VAR1+=1
        LOCATE "EXECUTIVES.AND.EMP.GLOBAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS1 THEN
            R.CRD.LIM.MAIN<CRD.LIM.USED.AMOUNT,POS1> += VAR.AMOUNT
            R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS1> -= VAR.AMOUNT
        END
        CALL F.WRITE(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN)
        RETURN
    END ELSE
*Check relation customer of the main customer is employee of the bank or not
        REL.CUST = R.CUSTOMER<EB.CUS.REL.CUSTOMER>
        CHANGE @VM TO @FM IN REL.CUST
        REL.CUST.LIST = DCOUNT(REL.CUST,@FM)
        LOOP
            REMOVE REL.CUS.ID FROM REL.CUST SETTING REL.POS
        WHILE REL.CUS.ID:REL.POS
            CALL F.READ(FN.CUSTOMER,REL.CUS.ID,R.CUST,F.CUSTOMER,ERR)
            VAR.REL.SECTOR = R.CUST<EB.CUS.SECTOR>
            VAR.REL.RISK.GROUP = R.CUST<EB.CUS.LOCAL.REF,POS.RISK.GROUP>
            IF VAR.REL.SECTOR EQ 1002 THEN
                VAR1+=1
                IF VAR.REL.RISK.GROUP NE '' THEN
                    CUST.ID = REL.CUS.ID
                    GOSUB CHECK.RISK
                    RETURN
                END ELSE
                    LOCATE "EXECUTIVES.AND.EMP.INDIVIDUAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS2 THEN
                        R.CRD.LIM.MAIN<CRD.LIM.USED.AMOUNT,POS2> += VAR.AMOUNT
                        R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS2> -= VAR.AMOUNT
                    END
                    CALL F.WRITE(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN)
                    RETURN
                END
            END
        REPEAT
    END
    IF VAR1 EQ '' THEN
        LOCATE "RELATED.GLOBAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS3 THEN
            R.CRD.LIM.MAIN<CRD.LIM.USED.AMOUNT,POS3> += VAR.AMOUNT
            R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS3> -= VAR.AMOUNT
        END
        CALL F.WRITE(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN)
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------------------
CHECK.RISK:
*---------------------------------------------------------------------------------------------------------------------------
* Check if the customer having any risk group
    SEL.LIST = ''
    NOR = ''
    ERR = ''
    SEL.CMD = 'SSELECT ':FN.COLLATERAL:' WITH @ID LIKE ':CUST.ID:'...'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR)

    IF NOR EQ '' OR NOR EQ 0 THEN
        LOCATE "RISK.GROUP.LIMIT.WITHOUT.COLLATERAL" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS4 THEN
            R.CRD.LIM.MAIN<CRD.LIM.USED.AMOUNT,POS4> += VAR.AMOUNT
            R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS4> -= VAR.AMOUNT
        END
    END ELSE
        LOCATE "RISK.GROUP.LIMIT.WITH.COLLATERAL" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS5 THEN
            R.CRD.LIM.MAIN<CRD.LIM.USED.AMOUNT,POS5> += VAR.AMOUNT
            R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS5> -= VAR.AMOUNT
        END
    END
    CALL F.WRITE(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN)
RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
CHECK.APPLICATION:
*--------------------------------------------------------------------------------------------------------------------------------------
*To get the customer id and total disbursed amount based on the application

    BEGIN CASE

        CASE APPLICATION EQ 'AA.ARR.TERM.AMOUNT'
            ARR.ID = c_aalocArrId
            PROPERTY.CLASS = 'CUSTOMER'
            APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.CUS,ERR.MSG);* R22 Manual conversion
*CUST.ID = R.CUS<AA.CUS.PRIMARY.OWNER>
            CUST.ID = R.CUS<AA.CUS.CUSTOMER>;* R22 Manual conversion
            VAR.AMOUNT = R.NEW(AA.AMT.AMOUNT)


        CASE APPLICATION EQ 'MM.MONEY.MARKET'
            CUST.ID = R.NEW(MM.CUSTOMER.ID)
            VAR.AMOUNT = R.NEW(MM.PRINCIPAL)

        CASE APPLICATION EQ 'FOREX'
            CUST.ID = R.NEW(FX.COUNTERPARTY)
            VAR.AMOUNT = R.NEW(FX.OS.DEL.BUY.AMT)
            IF VAR.AMOUNT EQ '' THEN
                VAR.AMOUNT = R.NEW(FX.AMOUNT.BOUGHT)
            END

        CASE APPLICATION EQ 'SEC.TRADE'
            CUST.ID = R.NEW(SC.SBS.CUSTOMER.NO)
            VAR.AMOUNT = R.NEW(SC.SBS.CU.GROSS.AM.TRD)

    END CASE

RETURN
*--------------------------------------------------------------------------------------------------------------------------------
END
