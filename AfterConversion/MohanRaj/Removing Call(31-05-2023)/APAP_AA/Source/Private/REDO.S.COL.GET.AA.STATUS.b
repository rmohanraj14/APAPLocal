* @ValidationCode : Mjo1OTAxMTMxNDI6Q3AxMjUyOjE2ODM3MDAzMjU0MTk6SVRTUzotMTotMTotNjU6MTpmYWxzZTpOL0E6REVWXzIwMjEwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 12:02:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -65
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202108.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.S.COL.GET.AA.STATUS(P.IN.AA.ID,  P.IN.PROCESS.DATE, P.OUT.AA.STATUS, P.OUT.COBRO.JUDICIAL)
******************************************************************************
*
*    COLLECTOR - Interface
*    Allows to get the AA STATUS and COBRO.JUDICIAL
*    Fields :
*             TMPCREDITO>TMPCREDITOCOBROJUDICIAL
*             TMPCREDITO>TMPCREDITOESTADOCONTRATO
* =============================================================================
*
*    First Release :  TAM
*    Developed for :  TAM
*    Developed by  :  APAP
*    Date          :  2010-11-15 C.1
*
*=======================================================================
*
*
*  DATE            WHO                     GAP               DESCRIPTION
* 28-APR-2011      H GANESH                CR009             Change the Vetting value of local field.
* 30-NOV-2011      hpasquel@temenos.com                      To improve SELECT statements
* 04-JUN-2018      Gopala Krishnan R       PACS00677689      Fix Modification

*=======================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
*
    $INSERT I_REDO.COL.CUSTOMER.COMMON
*
*************************************************************************
*
    COM /REDO.S.COL.GAA.ST/Y.AA.OVE.L.LOAN.STATUS.1,Y.AA.OVE.L.LOAN.COND        ;*PACS00169639

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
    Y.TMPCREDITOESTADOCONTRATO = ""
*>>PACS00169639
    idPropertyClass = "OVERDUE"
    GOSUB ARR.CONDITIONS
    IF returnError THEN
        E = returnError
        RETURN
    END
    R.AA.OVERDUE = RAISE(returnConditions)
*<<PACS00169639

*      R.AA.OVERDUE<AA.OD.LOCAL.REF>
    Y.LOAN.STATUS = R.AA.OVERDUE<AA.OD.LOCAL.REF,Y.AA.OVE.L.LOAN.STATUS.1>
    Y.LOAN.COND   = R.AA.OVERDUE<AA.OD.LOCAL.REF,Y.AA.OVE.L.LOAN.COND>

*TMPCREDITOESTADOCONTRATO
    BEGIN CASE
        CASE Y.LOAN.STATUS EQ "JudicialCollection"
            Y.TMPCREDITOESTADOCONTRATO = "4"
        CASE Y.LOAN.STATUS EQ "Restructured"
            Y.TMPCREDITOESTADOCONTRATO = "3"
            LOCATE "Legal" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN       ;*PACS00677689
                Y.TMPCREDITOESTADOCONTRATO = "1"
            END
        CASE Y.LOAN.STATUS EQ "Write-off"
            Y.TMPCREDITOESTADOCONTRATO = "2"
        CASE Y.LOAN.STATUS EQ "" OR Y.LOAN.STATUS EQ "Normal"   ;* This field is used as CONSOLD.KEY
            IF Y.LOAN.COND EQ "" THEN
                Y.TMPCREDITOESTADOCONTRATO = "0"
            END ELSE
                Y.TMPCREDITOESTADOCONTRATO = "0"
                LOCATE "Legal" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN   ;*PACS00677689
                    Y.TMPCREDITOESTADOCONTRATO = "1"
                END ELSE
                    LOCATE "Restructured" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN  ;*PACS00677689
                        Y.TMPCREDITOESTADOCONTRATO = "3"
                    END
                END
            END
        CASE 1
            E = yNonMappingValue
            E<2> = Y.LOAN.STATUS : "-" : Y.LOAN.COND : @VM : "STATUS AND COND"
            RETURN
    END CASE

    Y.TMPCREDITOESTADOCONTRATO = Y.TMPCREDITOESTADOCONTRATO[1,10]

* TMPCREDITOCOBROJUDICIAL
    BEGIN CASE
        CASE Y.LOAN.STATUS EQ "JudicialCollection"
            Y.TMPCREDITOCOBROJUDICIAL = "1"
        CASE Y.LOAN.STATUS EQ "Restructured"
            LOCATE "Legal" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN
                Y.TMPCREDITOCOBROJUDICIAL = "1"
            END ELSE
                Y.TMPCREDITOCOBROJUDICIAL = "0"
            END
        CASE Y.LOAN.STATUS EQ "Write-off"
            LOCATE "Legal" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN
                Y.TMPCREDITOCOBROJUDICIAL = "1"
            END ELSE
                Y.TMPCREDITOCOBROJUDICIAL = "0"
            END
        CASE Y.LOAN.STATUS EQ "" OR Y.LOAN.STATUS EQ "Normal"   ;* This field is used as CONSOLD.KEY
            LOCATE "Legal" IN Y.LOAN.COND<1,1,1> SETTING Y.POS THEN
                Y.TMPCREDITOCOBROJUDICIAL = "1"
            END ELSE
                Y.TMPCREDITOCOBROJUDICIAL = "0"
            END
        CASE 1
            E = yNonMappingValue
            E<2> = Y.LOAN.STATUS : "-" : Y.LOAN.COND : @VM : "STATUS AND COND"
            RETURN
    END CASE


    Y.TMPCREDITOCOBROJUDICIAL = Y.TMPCREDITOCOBROJUDICIAL[1,1]

    P.OUT.AA.STATUS  = Y.TMPCREDITOESTADOCONTRATO
    P.OUT.COBRO.JUDICIAL = Y.TMPCREDITOCOBROJUDICIAL

RETURN
*
*
* ---------
INITIALISE:
* ---------
*
    PROCESS.GOAHEAD = 1

    IF Y.AA.OVE.L.LOAN.STATUS.1 THEN    ;*PACS00169639
        RETURN
    END

* Local Fields for AA.OVERDUE
    Y.LOC.REF.AA.OVERDUE   = "AA.PRD.DES.OVERDUE"
    Y.LOC.REF.AA.OVERDUE.FIELDS = "L.LOAN.STATUS.1":@VM:"L.LOAN.COND"
    CALL MULTI.GET.LOC.REF(Y.LOC.REF.AA.OVERDUE, Y.LOC.REF.AA.OVERDUE.FIELDS, LOC.REF.POS)
    Y.AA.OVE.L.LOAN.STATUS.1 = LOC.REF.POS<1,1>
    Y.AA.OVE.L.LOAN.COND     = LOC.REF.POS<1,2>
    IF NOT(Y.AA.OVE.L.LOAN.STATUS.1) THEN
        E = yLocalRefFieldNotDef
        E<2> = "L.LOAN.STATUS.1" : @VM : Y.LOC.REF.AA.OVERDUE
        PROCESS.GOAHEAD = 0
        RETURN
    END
    IF NOT(Y.AA.OVE.L.LOAN.COND) THEN
        E = yLocalRefFieldNotDef
        E<2> = "L.LOAN.COND": @VM : Y.LOC.REF.AA.OVERDUE
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
*-------------------------------------------------------------------------------
END
