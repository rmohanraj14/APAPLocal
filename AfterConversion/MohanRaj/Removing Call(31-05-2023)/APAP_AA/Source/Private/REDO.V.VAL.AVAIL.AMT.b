* @ValidationCode : MjotODkzNTEzNDI3OkNwMTI1MjoxNjg1NTMzNzcxNTA2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:19:31
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
SUBROUTINE REDO.V.VAL.AVAIL.AMT
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :SUDHARSANAN S
*Program Name :REDO.V.VAL.AVAIL.AMT
*---------------------------------------------------------------------------------

*DESCRIPTION :Raising an Override Message by checking the Committment amount is greter than
* Available amount in CREDIT.LIMIT.MAINTENANCE application
*LINKED WITH : NA
* ----------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE WHO REFERENCE DESCRIPTION
*06.07.2010 SUDHARSANAN S ODR-2009-10-0578 INITIAL CREATION
*
* 15/07/2011 Ravikiran AV PACS00034161 Get the customer ID from AAA record
** 30-03-2023       Conversion Tool                 R22 Auto Conversion            FM TO @FM, VM to @VM, SM to @SM
** 30-03-2023           Skanda                      R22 Manual Conversion          CALL method format changed
* ----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COLLATERAL
    $INSERT I_F.CREDIT.LIMIT.MAINTENANCE
    $USING APAP.TAM

    GOSUB INIT
    IF V$FUNCTION NE 'A' THEN
        GOSUB PROCESS
    END
RETURN

*-----*
INIT:
*-----*
*intilaise the variables

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMT= ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.CUSTOMER= 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CREDIT.LIMIT.MAINTENANCE = 'F.CREDIT.LIMIT.MAINTENANCE'
    F.CREDIT.LIMIT.MAINTENANCE = ''
    CALL OPF(FN.CREDIT.LIMIT.MAINTENANCE,F.CREDIT.LIMIT.MAINTENANCE)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    CALL CACHE.READ(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN,CRD.ERR)

    LOC.REF.APPLICATION="CUSTOMER"
    LOC.REF.FIELDS='L.CU.GRP.RIESGO'
    LOC.REF.POS=''
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.RISK.GROUP=LOC.REF.POS<1,1>

    ARR.ID=c_aalocArrId
    EFF.DATE=TODAY
    PROPERTY=''
    R.Condition=''
    R.TERM.AMT = ''
    ERR.MSG=''
    VAR1 = ''
    VAR2 = ''
    AVAIL.AMT = ''
RETURN

*--------*
PROCESS:
*--------*

    PROP.CLASS='CUSTOMER'
    APAP.TAM.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG);* R22 Manual conversion

*CUST.ID = R.Condition<AA.CUS.PRIMARY.OWNER>
    CUST.ID = R.Condition<AA.CUS.CUSTOMER>;* R22 Manual conversion

*PACS00034161

* CUST.ID = c_aalocArrangementRec<AA.ARR.ACT.CUSTOMER> ;* Get the Customer from AAA record

    CALL F.READ(FN.CUSTOMER,CUST.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    COMMITMENT.AMT = R.NEW(AA.AMT.AMOUNT)
    VAR.MAIN.SECTOR = R.CUSTOMER<EB.CUS.SECTOR>
    VAR.RISK.GROUP = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.RISK.GROUP>

    IF VAR.MAIN.SECTOR EQ 1002 THEN
        GOSUB CHECK.EMP.GLOBAL
        RETURN
    END ELSE
        GOSUB CHECK.EMP.IND
    END
    GOSUB CHECK.REL.GLOBAL
RETURN
*------------------------------------------------------------------------------------------
CHECK.COM.AMT:
*----------------------------------------------------------------------------------------------
*Checks the value and raise the Override
* IF COMMITMENT.AMT GE AVAIL.AMT THEN
* CURR.NO=''
* CURR.NO=DCOUNT(R.NEW(AA.AMT.OVERRIDE),VM) + 1
* TEXT='AA.LIM.AMT.EXCED.AVAIL.AMT'
* CALL STORE.OVERRIDE(CURR.NO)
* END
RETURN
*---------------------------------------------------------------------------------------------------
CHECK.EMP.GLOBAL:
*-------------------------------------------------------------------------------------------
* Checks the main customer is employee of the bank or not
    VAR1+=1
    LOCATE "EXECUTIVES.AND.EMP.GLOBAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS1 THEN
        AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS1>
    END
    GOSUB CHECK.COM.AMT
RETURN
*------------------------------------------------------------------------------------------------
CHECK.EMP.IND:
*-------------------------------------------------------------------------------------------------
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
            VAR2+=1
            VAR1+=1
            IF VAR.REL.RISK.GROUP NE '' THEN
                GOSUB CHECK.RISK
                RETURN
            END
        END
    REPEAT
    IF VAR2 THEN
        LOCATE "EXECUTIVES.AND.EMP.INDIVIDUAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS2 THEN
            AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS2>
        END
        GOSUB CHECK.COM.AMT
    END
RETURN
*------------------------------------------------------------------------------------------------
CHECK.REL.GLOBAL:
*------------------------------------------------------------------------------------------------
*Checks if the customer is not belonging to any other groups
    IF VAR1 EQ '' THEN
        LOCATE "RELATED.GLOBAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS3 THEN
            AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS3>
        END
        GOSUB CHECK.COM.AMT
    END
RETURN
*------------------------------------------------------------------------------------------------
CHECK.RISK:
*------------------------------------------------------------------------------------------
* Check if the customer having any risk group
    SEL.LIST = ''
    NOR = ''
    ERR = ''
    SEL.CMD = 'SSELECT ':FN.COLLATERAL:' WITH @ID LIKE ':REL.CUS.ID:'...'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR)
    IF NOR EQ '' OR NOR EQ 0 THEN
        LOCATE "RISK.GROUP.LIMIT.WITHOUT.COLLATERAL" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS4 THEN
            AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS4>
        END
    END ELSE
        LOCATE "RISK.GROUP.LIMIT.WITH.COLLATERAL" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING POS5 THEN
            AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,POS5>
        END
    END
    GOSUB CHECK.COM.AMT
RETURN
*---------------------------------------------------------------------------------------------
END
