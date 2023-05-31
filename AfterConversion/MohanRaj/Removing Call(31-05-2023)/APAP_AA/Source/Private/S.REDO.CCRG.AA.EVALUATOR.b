* @ValidationCode : MjotMTMyODkzNjkwOTpDcDEyNTI6MTY4NTUzMzk5MzEyNzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 17:23:13
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
$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE S.REDO.CCRG.AA.EVALUATOR(P.AA.ID, R.RCBTP, R.CUSTOMER, R.AA.ARR, P.RETURN)
*-----------------------------------------------------------------------------------
* Modification History:
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023        Conversion Tool     AUTO R22 CODE CONVERSION          FM TO @FM,VM TO@VM,SM TO @SM
* 29/03/2023         SURESH             MANUAL R22 CODE CONVERSION        Package Name added APAP.AA, CALL method format changed
*--------------------------------------------------------------------------------------------
* Company Name : APAP
* Developed By : Temenos Application Management
*--------------------------------------------------------------------------------------------
* Description:
* Allows to evaluate the data against REDO.CCRG.BALANCE.TYPE.PARAM. This routine
* is used with AA contracts.
* The routine returns:
* - The balance type
* - Other parties and their roles
* - If the contract is associated wiht a LIMIT, then the LIMIT.REF is returned
* - Category Code
*
*
* Linked With:
* REDO.CCRG.B.EXT Service Routine
* REDO.CCRG.PARAMETERS Parameter Application
* In Parameter:
* P.AA.ID Arrangement identifier
* R.RCBTP Record from REDO.CCRG.BALANCE.TYPE.PARAM corresponding to AA product
* R.CUSTOMER Customer Information
* Out Parameter:
* R.AA.ARR AA.Arrangement Record. If blank the routine get ones from AA.ARRANGEMENT
* P.RETURN Returned position:
* 1. Balance Types
* 2. Other party customers
* 3. Roles of the other party customers
* 4. Limit Reference
* 5. Category Code
* E (common) User Message in case of Error
*--------------------------------------------------------------------------------------------
* Modification Details:
*=====================
* 06/04/2011 - ODR-2011-03-0154
* First version. Risk Limit for Customer and Group Risk
* hpasquel@temenos.com
*REM Just for compile
*--------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.CUSTOMER
    $USING APAP.TAM
    $INSERT I_REDO.CCRG.CONSTANT.COMMON
*--------------------------------------------------------------------------------------------
*

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*
*--------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------
    P.VALUES = ''
*
* Get relation Code for the current customer
*
    P.VALUES<1,1> = K.CUS.RELATION.CODE
    Y.REL.CODE = CHANGE(R.CUSTOMER<EB.CUS.RELATION.CODE>,@VM,@SM) ;*AUTO R22 CODE CONVERSION

    P.VALUES<2,1> = Y.REL.CODE

*
* Get related record from ACCOUNT
*
    R.AA.ARR = ''
    YERR = ''
    CALL F.READ(FN.AA.ARRANGEMENT,P.AA.ID,R.AA.ARR,F.AA.ARRANGEMENT,YERR)
    IF R.AA.ARR EQ '' THEN
* May be the contract reached its maturity date
        E = K.REC.NOT.FOUND
        E<2> = P.AA.ID : @VM : FN.AA.ARRANGEMENT ;*AUTO R22 CODE CONVERSION

        RETURN
    END

    LOCATE 'ACCOUNT' IN R.AA.ARR<AA.ARR.LINKED.APPL,1> SETTING Y.POS THEN
        Y.ACCOUNT.ID = R.AA.ARR<AA.ARR.LINKED.APPL.ID,Y.POS>
    END ELSE
        E = "ST-REDO.CCRG.AA.ACCOUNT.ID.NOT.FOUND"
        E<2> = P.AA.ID
        RETURN
    END

    R.AC = ''
    YERR = ''
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.AC,F.ACCOUNT,YERR)
    IF R.AC EQ '' THEN
        E = K.REC.NOT.FOUND
        E<2> = P.AA.ID : @VM : FN.AA.ARRANGEMENT ;*AUTO R22 CODE CONVERSION

        RETURN
    END

*
* Set Category value
*
    P.VALUES<1,2> = K.CATEGORY
    P.VALUES<2,2> = R.AC<AC.CATEGORY>

*
* Get the list of related customers (other party and their roles)
*
    GOSUB GET.AA.CUSTOMER.LIST
    IF AA.ARR.CUSTOMER.LIST EQ '' THEN
        RETURN
    END


    Y.AA.CUS.ID = AA.ARR.CUSTOMER.LIST<1>
    R.AA.ARR.CUSTOMER = ''
    YERR = ''
    CALL F.READ(FN.AA.ARR.CUSTOMER,Y.AA.CUS.ID,R.AA.ARR.CUSTOMER,F.AA.ARR.CUSTOMER,YERR)

*
* Get type of campaing local field
*
    P.VALUES<1,3> = "AA.CAMP.TY"
    P.VALUES<2,3> = R.AA.ARR.CUSTOMER<AA.CUS.LOCAL.REF,L.AA.CAMP.TY>

*
* Evaluate conditions, and get balance type associated
*
    P.BAL.TYPES = ''
    APAP.TAM.sRedoCcrgEvalBalTypCon(R.RCBTP, P.VALUES, P.BAL.TYPES);* R22 Manual conversion

    P.RETURN<1> = P.BAL.TYPES ;* balance type associated with this AA
    P.RETURN<2> = R.AA.ARR.CUSTOMER<AA.CUS.OTHER.PARTY> ;* Other party customer list
    P.RETURN<3> = R.AA.ARR.CUSTOMER<AA.CUS.ROLE> ;* Other party roles
    P.RETURN<4> = '' ;* Limit.ref
    P.RETURN<5> = R.AC<AC.CATEGORY> ;* Category Code

*
* If the contract has an LIMIT associated, then it could be a "Linea Credito Interina"
*
    Y.LIM.REF = R.AC<AC.LIMIT.REF>
    IF P.RETURN<1> EQ '' AND Y.LIM.REF NE '' THEN
        Y.LIM.REF = FMT(Y.LIM.REF[".",1,1],"R%7") : "." : R.AC<AC.LIMIT.REF>[".",2,1]
        P.RETURN<4> = R.AC<AC.CUSTOMER> : "." : Y.LIM.REF
    END

RETURN

*--------------------------------------------------------------------------------------------
GET.AA.CUSTOMER.LIST:
*--------------------------------------------------------------------------------------------
    Y.SEL.CMD = ''
    Y.SEL.CMD := 'SELECT ':FN.AA.ARR.CUSTOMER
    Y.SEL.CMD := ' WITH ID.COMP.1 EQ ' : P.AA.ID
    Y.SEL.CMD := ' BY ID.COMP.1 BY.DSND ID.COMP.3'
    AA.ARR.CUSTOMER.LIST = ''
    Y.NO.OF.RECS = ''
    SYSTEM.RETURN.CODE = ''
    CALL EB.READLIST(Y.SEL.CMD,AA.ARR.CUSTOMER.LIST,'',Y.NO.OF.RECS,SYSTEM.RETURN.CODE)

RETURN
*--------------------------------------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------------------------------------

* If it was already open, then OPF is ommited
    F.AA.ARRANGEMENT = ''
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ARR.CUSTOMER = 'F.AA.ARR.CUSTOMER'
    F.AA.ARR.CUSTOMER = ''
    CALL OPF(FN.AA.ARR.CUSTOMER,F.AA.ARR.CUSTOMER)

*
* Get local Field to Type of Campaign
*
    IF NOT(L.AA.CAMP.TY) THEN
        L.AA.CAMP.TY = ''
        CALL GET.LOC.REF("AA.PRD.DES.CUSTOMER","L.AA.CAMP.TY",L.AA.CAMP.TY)

    END

*
* Check if the Local Field is presented
*
    IF NOT(L.AA.CAMP.TY) THEN
        E = K.LOCAL.FIELD.MISSED
        E<2> = "L.AA.CAMP.TY" : @VM : "AA.PRD.DES.CUSTOMER" ;*AUTO R22 CODE CONVERSION

        RETURN
    END

RETURN

*--------------------------------------------------------------------------------------------
INITIALISE:
*--------------------------------------------------------------------------------------------

    LOOP.CNT = 1
    MAX.LOOPS = 3
    PROCESS.GOAHEAD = @TRUE
    P.RETURN = ''

RETURN


*--------------------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*--------------------------------------------------------------------------------------------

    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF P.AA.ID EQ "" THEN
                    E = K.PARAMETER.IS.EMPTY : @FM : "P.AA.ID" : @VM : "S.REDO.CCRG.AA.EVALUATOR" ;*AUTO R22 CODE CONVERSION

                    PROCESS.GOAHEAD = @FALSE
                END
            CASE LOOP.CNT EQ 2
                IF R.RCBTP EQ "" THEN
                    E = K.PARAMETER.IS.EMPTY : @FM : "R.RCBTP" : @VM : "S.REDO.CCRG.AA.EVALUATOR" ;*AUTO R22 CODE CONVERSION

                    PROCESS.GOAHEAD = @FALSE
                END
            CASE LOOP.CNT EQ 3
                IF R.CUSTOMER EQ "" THEN
                    E = K.PARAMETER.IS.EMPTY : @FM : " R.CUSTOMER" : @VM : "S.REDO.CCRG.AA.EVALUATOR" ;*AUTO R22 CODE CONVERSION

                    PROCESS.GOAHEAD = @FALSE
                END
        END CASE

        LOOP.CNT +=1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------

END
