* @ValidationCode : MjotMTkzOTI4MTQyMzpDcDEyNTI6MTY4MzUzMTA5MzQwMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 08 May 2023 13:01:33
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.COL.GET.PAY.TYPE(P.IN.AA.ID,  P.IN.R.STATIC.MAPPING, P.IN.PROCESS.DATE, P.OUT.PAY.TYPE)
******************************************************************************
*
*    COLLECTOR - Interface
*    Allows to get the Payment Type
* =============================================================================
*
*    First Release :  TAM
*    Developed for :  TAM
*    Developed by  :  APAP
*    Date          :  2010-11-15 C.1
*Modification history
*Date                Who               Reference                  Description
*06-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*06-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*
*=======================================================================
*    2011-11-30 :  PACS00169639
*                  hpasquel@temenos.com        To improve SELECT statements
*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_REDO.COL.CUSTOMER.COMMON
*
*************************************************************************
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
* ======
PROCESS:
* ======
*
*

* << PACS00169639
    idPropertyClass = "PAYMENT.SCHEDULE"
    GOSUB ARR.CONDITIONS
    IF returnError THEN
        E = returnError
        RETURN
    END
    R.AA.SCHEDULE = RAISE(returnConditions)

    Y.AA.ACT.CLASS =  R.AA.SCHEDULE<1>    ;* ? I_F.AA.PAYMENT.SCHEDULE has a DESCRIPTION field as first positions (bug to check)

    Y.IS.APPLYPAYMENT    = Y.AA.ACT.CLASS["-",1,2] EQ 'LENDING-APPLYPAYMENT'
    Y.IS.CR.ARRANGEMENT  = Y.AA.ACT.CLASS["-",1,3] EQ 'LENDING-CREDIT-ARRANGEMENT'
    Y.IS.PAYOFF          = Y.AA.ACT.CLASS["-",1,3] EQ 'LENDING-SETTLE-PAYOFF'

    IF NOT(Y.IS.APPLYPAYMENT) AND NOT(Y.IS.CR.ARRANGEMENT) AND NOT(Y.IS.PAYOFF)  THEN
        RETURN
    END
* >> PACS00169639

    Y.MAP.VALUE = ""
    P.OUT.PAY.TYPE =  R.AA.SCHEDULE<AA.PS.LOCAL.REF,Y.AA.PS.L.AA.PAY.METHD>
    IF P.OUT.PAY.TYPE EQ "" THEN
        RETURN
    END

    Y.MAP.VALUE = P.OUT.PAY.TYPE
    Y.MAP.TYPE  = "PAYMENT.TYPE"
    E = ""
    CALL REDO.R.COL.GET.MAPPING(C.ID.STATIC.MAPPING, P.IN.R.STATIC.MAPPING, 1, P.IN.R.STATIC.MAPPING, Y.MAP.TYPE, Y.MAP.VALUE)
    IF E THEN
        P.OUT.PAY.TYPE = ""
        RETURN
    END

    P.OUT.PAY.TYPE = Y.MAP.VALUE[1,1]

RETURN
*
*
* ---------
INITIALISE:
* ---------
*
    PROCESS.GOAHEAD = 1

* Local Fields for AA.ARR.PAYMENT.SCHEDULE
    Y.LOC.REF.AA.PAY.SCH   = "AA.PRD.DES.PAYMENT.SCHEDULE"
    Y.LOC.REF.AA.PAY.SCH.FIELDS = "L.AA.PAY.METHD"
    CALL MULTI.GET.LOC.REF(Y.LOC.REF.AA.PAY.SCH, Y.LOC.REF.AA.PAY.SCH.FIELDS, LOC.REF.POS)
    Y.AA.PS.L.AA.PAY.METHD = LOC.REF.POS<1,1>
    IF NOT(Y.AA.PS.L.AA.PAY.METHD) THEN
        E = yLocalRefFieldNotDef
        E<2> = "L.AA.PAY.METHD" : @VM : Y.LOC.REF.AA.PAY.SCH ;* R22 Auto code conversion
        PROCESS.GOAHEAD = 0
        RETURN
    END

*
*
RETURN
*
*
* ---------
OPEN.FILES:
* ---------
*
*
RETURN
*
*-----------------------
CHECK.PRELIM.CONDITIONS:
*-----------------------
*
    LOOP.CNT  = 1   ;   MAX.LOOPS = 1
RETURN
*
*-----------------------------------------------------------------------------
ARR.CONDITIONS:
*-----------------------------------------------------------------------------
    ArrangementID = P.IN.AA.ID ; idProperty = ''; effectiveDate = P.IN.PROCESS.DATE; returnIds = ''; R.CONDITION =''; returnConditions = ''; returnError = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
RETURN
*-----------------------------------------------------------------------------
END
