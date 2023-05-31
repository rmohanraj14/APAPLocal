$PACKAGE APAP.AA ;*R22 Manual Code Conversion 
SUBROUTINE REDO.AA.DEFAULT.FREQUENCY
*
*----------------------------------------------------------------------------------------------------------------------
* Description:
*
* This routine is attached as a PRE routine to LENDING-NEW-ARRANGEMENT
*
* API Details:
* Activity: LENDING-NEW-ARRANGEMENT
* Property: PAYMENT.SCHEDULE
* Action  : UPDATE
*
* This routine is used to populate the PAYMENT & DUE frequencies if the Arrangement Effective date is on 29th or 30th
* of the month
*
*-----------------------------------------------------------------------------------------------------------------------
*
* Modification History :
*   Date            Who                   Reference               Description
*  ------          -----                ------------             -------------
* 23 Feb 2012    Ravikiran AV            PACS00175270           Initial Creation
* 03 Dec 2012    Marimuthu S             PACS00236403
* 10 JUL 2017    Edwin Charles D         R15 Upgrade
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023     Conversion Tool                       R22 Auto Code Conversion             SM to @SM , VM to@ VM , F.READ to CACHE.READ 
* ----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------------------------
* All File INSERTS done here

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.PAYMENT.TYPE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
*------------------------------------------------------------------------------------------------------------------
* Main Logic of the routine
*
MAIN.LOGIC:

    IF c_aalocActivityStatus EQ 'UNAUTH' ELSE
        RETURN
    END

    GOSUB INIT

    GOSUB FREQ.DATE.VALIDATION
 
    GOSUB PROCESS

RETURN
*------------------------------------------------------------------------------------------------------------------
* Variable Initialisation Done here
*
INIT:

    FN.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT  = ''
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT)

    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT  = ''
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)

    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT,c_aalocArrId,R.RCA.ID,F.REDO.CREATE.ARRANGEMENT.ID.ARRANGEMENT,RCA.ERR)

    Y.RCA.ID = FIELD(R.RCA.ID<1>,"*",2)

    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,Y.RCA.ID,R.RCA,F.REDO.CREATE.ARRANGEMENT,RCA.ERR)

    AA.ACT.EFF.DATE = c_aalocAccountDetails<AA.AD.VALUE.DATE>

    FN.AA.PAYMENT.TYPE = 'F.AA.PAYMENT.TYPE'
    F.AA.PAYMENT.TYPE  = ''
    CALL OPF(FN.AA.PAYMENT.TYPE,F.AA.PAYMENT.TYPE)

*AA.ACT.EFF.DATE = c_aalocActivityEffDate
    MATBUILD R.PAYMENT.SCHEDULE FROM R.NEW
    LOC.REF.APPLICATION   = "AA.PAYMENT.TYPE"
    LOC.REF.FIELDS        = 'L.AA.PAY.TYPE'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.BALOON.TYPE = LOC.REF.POS<1,1>


RETURN
*------------------------------------------------------------------------------------------------------------------
*
*
FREQ.DATE.VALIDATION:

    START.DATE = R.PAYMENT.SCHEDULE<AA.PS.START.DATE>
    START.DATE.CNT = DCOUNT(R.PAYMENT.SCHEDULE<AA.PS.START.DATE>,@FM);*R22 Auto Code Conversion

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Business Logic of the routine
*
PROCESS:

    IF R.RCA THEN   ;* If day mentioned in FC then take that else effective of activity
        Y.PAY.DATE = R.RCA<REDO.FC.PAYMT.DAY>
        IF Y.PAY.DATE THEN
            DAY = Y.PAY.DATE
            D.DY = FMT(DAY,'R%2')
        END ELSE
            DAY = AA.ACT.EFF.DATE[7,2]
            D.DY = DAY
        END
    END ELSE
        DAY = AA.ACT.EFF.DATE[7,2]
        D.DY = DAY
    END

    DAY = TRIM(DAY,'0','L')
    GOSUB CHECK.START.DATE
    GOSUB GET.PAY.TYPE.COUNT
    GOSUB POPULATE.PAY.FREQ
    GOSUB POPULATE.END.DATE

    MATPARSE R.NEW FROM R.PAYMENT.SCHEDULE

RETURN
*------------------------------------------------------------------------------------------------------------------
* Check START.DATE is available for the first Payment Type
*
CHECK.START.DATE:

* Consider only the first Payment Type, since if multiple payment types are present user has to select NONE for FREQ.BASE.DATE

    IF R.PAYMENT.SCHEDULE<AA.PS.START.DATE,1> THEN          ;* If Start Date present in the schedule then default the freq to that day

        START.DATE = R.PAYMENT.SCHEDULE<AA.PS.START.DATE,PAY.TYPE>
        DAY = START.DATE[7,2]
        DAY = TRIM(DAY,'0','L')

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Get the No. of Payment types used
*
GET.PAY.TYPE.COUNT:

    PAY.TYPE.CNT = DCOUNT(R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.TYPE>,@VM)

RETURN
*------------------------------------------------------------------------------------------------------------------
* Populate the Payment Frequency
*
POPULATE.PAY.FREQ:

    PAY.TYPE = ''
    LOOP
    WHILE PAY.TYPE.CNT GT 0 DO
        PAY.TYPE += 1
        ACT.FREQ = R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.FREQ,PAY.TYPE>
        Y.FREQ = ACT.FREQ
*    YEAR.MONTH.FREQ = LEFT(ACT.FREQ,12)
        YEAR.MONTH.FREQ = FIELD(ACT.FREQ,"W",1)   ;* PACS00803937
        YEAR.MONTH.FREQ = YEAR.MONTH.FREQ:"W":" " ;* PACS00803937
        DEFINED.FREQ = RIGHT(ACT.FREQ,5)
        Y.ON.DAY = ''
        GOSUB CHECK.ALREADY.DEFAULT     ;* Check whether On day has been defaulted.
        FINAL.FREQ = YEAR.MONTH.FREQ:'o':DAY:DEFINED.FREQ

        IF Y.ON.DAY ELSE
            R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.FREQ,PAY.TYPE> = FINAL.FREQ
        END
        GOSUB GET.PROP.COUNT
        GOSUB POPULATE.DUE.FREQ

        PAY.TYPE.CNT -= 1
    REPEAT

RETURN
*-----------------------------------------------------------
CHECK.ALREADY.DEFAULT:
*-----------------------------------------------------------

    Y.DAY.TYPE = FIELD(Y.FREQ," ",4,1)
    Y.ON.DAY   = Y.DAY.TYPE[2,LEN(Y.DAY.TYPE)-2]

RETURN
*------------------------------------------------------------------------------------------------------------------
* Get the property Count used
*
GET.PROP.COUNT:

    PROP.CNT = DCOUNT(R.PAYMENT.SCHEDULE<AA.PS.DUE.FREQ,PAY.TYPE>,@SM) ;*R22 Auto Code Conversion


RETURN
*-----------------------------------------------------------------------------------------------------------------
* Populate the DUE frequency
*
POPULATE.DUE.FREQ:

    PROP.TYPE = ''
    LOOP
    WHILE PROP.CNT GT 0 DO
        PROP.TYPE += 1

*ACT.PROP.FREQ =  R.PAYMENT.SCHEDULE<AA.PS.DUE.FREQ,PAY.TYPE,PROP.TYPE>
*YEAR.MONTH.PROP.FREQ = LEFT(ACT.PROP.FREQ,12)
*DEFINED.PROP.FREQ = RIGHT(ACT.PROP.FREQ,5)
*FINAL.PROP.FREQ = YEAR.MONTH.PROP.FREQ:'o':DAY:DEFINED.PROP.FREQ
        FINAL.PROP.FREQ = R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.FREQ,PAY.TYPE>
        R.PAYMENT.SCHEDULE<AA.PS.DUE.FREQ,PAY.TYPE,PROP.TYPE> = FINAL.PROP.FREQ

        PROP.CNT -= 1
    REPEAT

RETURN

*-----------------------------------------------------------------------------------------------------------
POPULATE.END.DATE:
*-----------------------------------------------------------------------------------------------------------
    Y.PAY.TYPES = R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.TYPE>
    Y.PAY.TYPES.CNT = DCOUNT(Y.PAY.TYPES,@VM) ;*R22 Auto Code Conversion

    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.PAY.TYPES.CNT
        IF R.PAYMENT.SCHEDULE<AA.PS.END.DATE,Y.VAR1,1> EQ '' THEN
            R.PAYMENT.SCHEDULE<AA.PS.END.DATE,Y.VAR1,1> = c_aalocAccountDetails<AA.AD.MATURITY.DATE>
        END
        Y.PAY.TYP = Y.PAY.TYPES<1,Y.VAR1>
        CALL CACHE.READ(FN.AA.PAYMENT.TYPE, Y.PAY.TYP, R.PAYMENT.TYPE, PAY.ERR) ;*R22 Auto Code Conversion

        Y.BALOON.PAY = R.PAYMENT.TYPE<AA.PT.LOCAL.REF,POS.BALOON.TYPE>
        IF Y.BALOON.PAY EQ 'YES' THEN
            IF R.PAYMENT.SCHEDULE<AA.PS.START.DATE,Y.VAR1,1> EQ '' THEN
                R.PAYMENT.SCHEDULE<AA.PS.START.DATE,Y.VAR1,1> = c_aalocAccountDetails<AA.AD.MATURITY.DATE>
            END
        END
        LOCATE 'ACCOUNT' IN R.PAYMENT.SCHEDULE<AA.PS.PROPERTY,Y.VAR1,1> SETTING POS.STR THEN
            IF R.PAYMENT.SCHEDULE<AA.PS.START.DATE,Y.VAR1> EQ '' THEN
*                Y.NXSD = AA.ACT.EFF.DATE[1,6]:D.DY
                Y.NXSD = AA.ACT.EFF.DATE
                STRYFREQ = R.PAYMENT.SCHEDULE<AA.PS.PAYMENT.FREQ,Y.VAR1>
                Y.DUM.COMI = COMI
                COMI = Y.NXSD:' ':STRYFREQ
                CALL CFQ
                Y.XNT.DD = COMI[1,8]
                COMI = Y.DUM.COMI
*                R.PAYMENT.SCHEDULE<AA.PS.START.DATE,Y.VAR1,1> = Y.XNT.DD
            END
        END
        Y.VAR1 += 1 ;*R22 Auto Code Conversion

    REPEAT


RETURN
*------------------------------------------------------------------------------------------------------------------
*
*
END
