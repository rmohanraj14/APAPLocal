* @ValidationCode : MjoyNzkzMDQyMDM6Q3AxMjUyOjE2ODM2OTg0MTk1MDg6SVRTUzotMTotMTo2MjQ6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 624
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : AA.DETAILS.XXX where XXX stands for the property classes

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To return the appropriate arrangement condition for the property

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version

* Author          : vhariharane@temenos.com
************************************************************
*MODIFICATION HISTORY :
*

* 17-Dec-2008 - BG_100021274
*               Changes made to remove the SORT as it does not go
*               well with the date sequence.
*
* 05-Jan-2009 - BG_100021514
*               SELECT criteria should be refined to pass SIM.REF
*               as String within quotes

* Date                  Who                               Reference                    Description
* ----                  ----                                ----                               ----
* 29-March-2023          Ajith Kumar          R22 Auto Code Conversio                     Package Name added APAP.AA
* 29-March-2023       Conversion Tool                        R22 Auto Code Conversion                   SM to @SM , = change into EQ , FM to @FM

*
* 30-Jan-2009 - CI_10060271
*               Usage of quotes changed in SELECT since it
*               did not go well with MS-SQL.
*
* 19/04/09 -  BG_100023284
*             "SELECT" has been changed to "SSELECT".
*
* 05/05/09 - CI_10062628
*            Ref : HD0911423
*            For Simulation, revise the Selection command to exclude
*            records that were DELETEd by Sim action.
*
* 27/10/10 - CI_10071836
*            Ref : HD1043593
*            For arrangement conditions, stop removing SELECT and
*            instead build the id by looking into the dated xref.
*
*            Superceded - pass Sim Mode to AA.GET.ARRANGEMENT.PROPERTIES
*
* 05/03/11 - CI_10072797
*            Ref: HD1100696
*            For future dated arrangement set date as Arrangement start date
*            instead of setting TODAY
*
*
*************************************************************
$PACKAGE APAP.AA   ;*R22 Manual Code Conversion
SUBROUTINE E.AA.BUILD.ARR.COND(ENQ.DATA)
************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PROPERTY.CLASS
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ENQUIRY
    $INSERT I_F.AA.SIMULATION.RUNNER
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT

****************************

    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
****************************
INITIALISE:
****************************

    SIM.FLG = ''
    NAU.FLG = ''
    DATE.RECORD = ''
    RET.ID = ''
    RET.ERR = ''
    ARR.RECORD = ''
    PROPERTY.LIST = ''
    EXIT.FLG = ''

    FILE.VERSION = ENQ.DATA<DCOUNT(ENQ.DATA,@FM)> ;*R22 Auto code Conversion
    LOCATE "ID.COMP.1" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
        ARR.ID = ENQ.DATA<4,ARR.POS>
    END

    FN.AA.ARR ="F.AA.ARRANGEMENT"
    FV.AA.ARR = ""
    CALL OPF(FN.AA.ARR,FV.AA.ARR)
    CALL F.READ(FN.AA.ARR, ARR.ID, R.ARR, FV.AA.ARR, RET.ERR)

    IF R.ARR<AA.ARR.START.DATE> GT TODAY THEN
        CMP.DATE = R.ARR<AA.ARR.START.DATE>
    END ELSE
        CMP.DATE = TODAY
    END

    BEGIN CASE
        CASE ENQ$SIM.REF AND INDEX(FILE.VERSION,"SIM",1)
            SIM.FLG = 1
            FN.AA.SIM = "F.":R.ENQ<2>:"$SIM"
            FV.AA.SIM = ''
            CALL OPF(FN.AA.SIM,FV.AA.SIM)
            SIM.REF = ENQ$SIM.REF
            CALL F.READ("F.AA.SIMULATION.RUNNER", SIM.REF, R.SIM, F.AA.SIM, RET.ERR)
            CMP.DATE = R.SIM<AA.SIM.SIM.END.DATE>     ;*For Simulation compare with End Date
        CASE INDEX(FILE.VERSION,"NAU",1)
            NAU.FLG = 1
            FN.AA.NAU = "F.":R.ENQ<2>:"$NAU"
            FV.AA.NAU = ''
            CALL OPF(FN.AA.NAU,FV.AA.NAU)
            SIM.REF = ''
    END CASE
*
    FN.AA = "F.":R.ENQ<2>
    FV.AA = ''
    CALL OPF(FN.AA,FV.AA)
    LIV.FLG = 1
*
    PROP.CLS = R.ENQ<2>['.',3,99]
    PROP.CLS = PROP.CLS['$',1,1]
*
RETURN
**********************
PROCESS:
**********************
*
    ARR.INFO = ARR.ID
    BEGIN CASE
        CASE SIM.FLG
            SIM.UPDATED = ''
            CALL SIM.READ(SIM.REF, 'F.AA.ARRANGEMENT.DATED.XREF', ARR.ID, DATE.RECORD, '', SIM.UPDATED, RET.ERR)
            ARR.INFO<6> = SIM.UPDATED       ;*If Sim Flag is required or not
        CASE 1
            CALL F.READ('F.AA.ARRANGEMENT.DATED.XREF', ARR.ID, DATE.RECORD, '', RET.ERR)
    END CASE
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, CMP.DATE, ARR.RECORD, PROPERTY.LIST)
    CALL AA.GET.PROPERTY.CLASS(PROPERTY.LIST, PROPERTY.CLS.LIST)
    REQD.PROP.LIST = ''
    LOOP
        LOCATE PROP.CLS IN PROPERTY.CLS.LIST<1,1> SETTING PROP.CLS.POS THEN
            REQD.PROP.LIST<1,-1> = PROPERTY.LIST<1,PROP.CLS.POS>
            PROPERTY.CLS.LIST<1,PROP.CLS.POS> = ''
        END ELSE
            EXIT.FLG = 1
        END
    UNTIL EXIT.FLG
    REPEAT

    IF NAU.FLG THEN
        FIELD.POS = 3
    END ELSE
        FIELD.POS = 2
    END

    LOOP
        REMOVE PROPERTY FROM REQD.PROP.LIST SETTING PR.POS
    WHILE PROPERTY
        LOCATE PROPERTY IN DATE.RECORD<1, 1> SETTING PROPERTY.POS THEN
        END

        GOSUB FIND.DATE       ;* Get it

        ID.TO.ADD = ARR.ID:AA$SEP:PROPERTY:AA$SEP:LOC.DATE
        IF RET.ID THEN
            RET.ID = RET.ID:' ':ID.TO.ADD
        END ELSE
            RET.ID = ID.TO.ADD
        END
    REPEAT

* Building the Selection Criteria and supplying the values

    ENQ.DATA<2,1> = "@ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = RET.ID

RETURN
****************************
FIND.DATE:
****************************
** If we are processing an arrangement the proeprty records will contain
** a sequence number. Each different version of the dated property will
** increment the sequence number for the date, for the first record there
** is not sequence number
** So when locating for the latest date check to see if a date is supplied with
** a sequence number, if not add a high sequence number so that the locate by DR
** returns the latest record
** For exmaple we will store 20070718.2 sm 20070718.1 sm 20070718 sm 20070716
** Looking for 20070717 should return 20070716
** looking for the latest 20070718 should return 20070718.2. If we don't add
** a sequence of .999 we would get 20070716
*
    ID.DATE = CMP.DATE
    IF NOT(INDEX(ID.DATE,".",1)) THEN
        SEARCH.DATE = ID.DATE:".999"
    END ELSE
        SEARCH.DATE = ID.DATE
    END

    LOCATE SEARCH.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING POS THEN          ;*  Locate to get the exact / nearest date...
        CHECK.DELETE = DATE.RECORD<6, PROPERTY.POS, POS>    ;* If that date having delete option then delete that date from dated xref.
        IF CHECK.DELETE THEN
            DEL DATE.RECORD<FIELD.POS, PROPERTY.POS, POS>
        END
    END

    LOCATE SEARCH.DATE IN DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING DATE.POS THEN     ;* Locate to get the exact / nearest date...
        NULL
    END
    LOC.DATE = DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>         ;* Return the date for the position
    NO.AUTH.DATES = DCOUNT(DATE.RECORD<FIELD.POS,PROPERTY.POS>,@SM) ;*R22 Auto Code Conversion

    IF FIELD.POS EQ 2 AND (DATE.POS NE NO.AUTH.DATES) THEN   ;* If authorised record date is picked and that is not the last date  ;*R22 Auto Code Conversion

        GOSUB CHECK.RNAU.DATES          ;* Check if the same date has been reversed
    END

RETURN

*** </region>

*** <region name= Check for RNAU dates>
*** <desc> </desc>
****************************
CHECK.RNAU.DATES:
****************************

* Imagine a scenario like this:
* 04-Jan - IssueBill
* Today : 10-Jan
* When a backdated change interest is done effective 03-Jan, and authorised. When the rate change is reversed now, then the IB should replay effective
* the old rate(before the 03-Jan rate) even though AUTH dates for 03-Jan still exists. Hence ignoring the 03Jan rate when reversal dates exist

    EXIT.FLAG = ''

    IF DATE.RECORD<4,PROPERTY.POS> THEN ;* First check if there are any reversals at all
        TEMP.DATE.RECORD = DATE.RECORD
        LOOP
        UNTIL EXIT.FLAG
            LOCATE LOC.DATE IN DATE.RECORD<4,PROPERTY.POS,1> BY 'DR' SETTING REV.POS THEN ;* Is this date found in the reversal line
                DEL TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>         ;* Delete the date from AUTH record so that it is not picked
                LOCATE SEARCH.DATE IN TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, 1> BY 'DR' SETTING DATE.POS THEN        ;* Locate to get the exact / nearest date...
                    NULL
                END
                LOC.DATE = TEMP.DATE.RECORD<FIELD.POS, PROPERTY.POS, DATE.POS>  ;* This is the date prior to the reversed date. Take that.
                IF LOC.DATE EQ '' THEN   ;* Incase of NULL, dont try to locate. It might go on a indefinite loop. Dont ever allow that!
                    EXIT.FLAG = 1       ;* Escape chute!!
                END
            END ELSE
                EXIT.FLAG = 1 ;* Normal exit. We have found the last authorized date
            END
        REPEAT

    END

RETURN
*** </region>
****************************
END
