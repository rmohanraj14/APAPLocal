* @ValidationCode : MjotOTE1Njc3OTg6Q3AxMjUyOjE2ODI2NzQ0NTYzNTE6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 28 Apr 2023 15:04:16
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
SUBROUTINE REDO.S.COL.GET.PAY.FREQ(P.IN.AA.ID,  P.IN.R.STATIC.MAPPING, P.IN.PROCESS.DATE, P.OUT.PAY.FREQ)
******************************************************************************
*
*    COLLECTOR - Interface
*    Allows to get the current Payment Frequency
* =============================================================================
*
*    First Release :  TAM
*    Developed for :  TAM
*    Developed by  :  APAP
*    Date          :  2010-11-15 C.1
*
*-----------------------------------------------------------------------------
*  HISTORY CHANGES:
*    2011-09-20 :  PACS00110378
*                  hpasquel@temenos.com
*    2011-11-30 :  PACS00169639
*                  hpasquel@temenos.com        To improve SELECT statements
*Modification history
*Date                Who               Reference                  Description
*06-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*06-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
*
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_REDO.COL.CUSTOMER.COMMON
*
*************************************************************************
*
    GOSUB INITIALISE
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
    idPropertyClass = "PAYMENT.SCHEDULE"
    GOSUB ARR.CONDITIONS
    IF returnError THEN
        E = returnError
        RETURN
    END
    R.AA.SCHEDULE = RAISE(returnConditions)
    IF R.AA.SCHEDULE EQ "" THEN
        E = yRecordNotFound
        E<2> = "PAYMENT.SCHEDULE" : @VM : P.IN.AA.ID
        RETURN
    END

    P.OUT.PAY.FREQ =  R.AA.SCHEDULE<AA.PS.PAYMENT.FREQ,1>     ;* JCB just take the first because all the property's frequencies are the same
    Y.MAP.VALUE = P.OUT.PAY.FREQ
* << PP
    GOSUB EXTRACT.FREQUENCY
* >>
    Y.MAP.TYPE  = "PAYMENT.FREQ"
    E = ""
    R.STATIC.MAPPING = ""
    CALL REDO.R.COL.GET.MAPPING(C.ID.STATIC.MAPPING, R.STATIC.MAPPING, 1, P.IN.R.STATIC.MAPPING, Y.MAP.TYPE, Y.MAP.VALUE)
    IF E THEN
        P.OUT.PAY.FREQ = ""
        RETURN
    END

    P.OUT.PAY.FREQ = Y.MAP.VALUE[1,20]

RETURN
*
*
* ---------
INITIALISE:
* ---------
*
    PROCESS.GOAHEAD = 1
*
*
RETURN
*
*
* ---------
EXTRACT.FREQUENCY:
* ---------
*  e0Y e1M e0W e9D e0F
*
    YEARS = Y.MAP.VALUE[" ",1,1]
    MONTHS = Y.MAP.VALUE[" ",2,1]
    WEEKS = Y.MAP.VALUE[" ",3,1]
    DAYS = Y.MAP.VALUE[" ",4,1]
    EB.FQU = Y.MAP.VALUE[" ",5,1]
    NO.FQU.VALUE = "e0"         ;* Indicates there is no value
    FREQUENCY = ''

    BEGIN CASE
        CASE YEARS[1,2] NE NO.FQU.VALUE
            FREQUENCY = YEARS         ;* e##Y
        CASE MONTHS[1,2] NE NO.FQU.VALUE
            FREQUENCY = MONTHS        ;* e##M
        CASE WEEKS[1,2] NE NO.FQU.VALUE
            FREQUENCY = WEEKS         ;* e##W
        CASE DAYS[1,2] NE NO.FQU.VALUE
            FREQUENCY = DAYS          ;* e##D
        CASE EB.FQU[1,2] NE NO.FQU.VALUE
            FREQUENCY = EB.FQU        ;* e##F
        CASE 1
            E = "Frequency " : Y.MAP.VALUE : " not in expected format"
            RETURN
    END CASE

    Y.MAP.VALUE = FREQUENCY[2,99]

RETURN
*
*-----------------------
CHECK.PRELIM.CONDITIONS:
*-----------------------
*
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
