* @ValidationCode : MjotMTY2MTcxOTU1NDpDcDEyNTI6MTY4MDE4NDY3MzU1MzpJVFNTOi0xOi0xOjQxNToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 415
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
*
*-----------------------------------------------------------------------------
SUBROUTINE REDO.FC.FILL.AA
*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE AA.ARRANGEMENT.ACTIVITY,AA.NEW.FC
* Attached as     : CHECK.REC.RTN
* Primary Purpose : FILL THE FIELDS .. GETTING THE RCA QUEUE
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*


***
* Error Variables:
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : mgudino - TAM Latin America
* Date            : 11 AGU 2011
* Development by  : btorresalbornoz - TAM Latin America
* Date            : 19 Sept 2011

* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023                                            AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED

*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.REDO.APP.MAPPING
    $INSERT I_GTS.COMMON
    $INSERT I_System

    GOSUB INITIALISE

    IF PROCESS.GOAHEAD THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS.MAIN
    END

RETURN          ;* Program RETURN


*----------------------------------------------------------------------------------------
PROCESS.MAIN:
*==============

* Get the property name in Y.APP.NAME
    Y.APP.NAME = APPLICATION
    Y.POS = INDEX(Y.APP.NAME, ".", 2)
    Y.POS2 = LEN(Y.APP.NAME)
    Y.APP.NAME = SUBSTRINGS(Y.APP.NAME, Y.POS + 1, Y.POS2)

* Open the Queue that has the preview R.NEW
    CALL F.READ(FN.RCA.R.NEW, Y.ARR.ID, R.RCA, F.RCA.R.NEW, Y.ERR)
    IF Y.ERR THEN
* JP20110829 If there is an error => just return
        RETURN
    END

    Y.COLL.CODES =  R.RCA<REDO.FC.SEC.NO.STATE.BR>
    Y.COLL.CODES := @FM: R.RCA<REDO.FC.SEC.NO.STATE.VS>
    Y.COLL.CODES := @FM: R.RCA<REDO.FC.SEC.NO.STATE.TP>
    Y.COLL.CODES := @FM: R.RCA<REDO.FC.SEC.NO.STATE.DI>
    Y.COLL.CODES := @FM: R.RCA<REDO.FC.SEC.NO.STATE.DE>
    Y.COLL.CODES := @FM: R.RCA<REDO.FC.SEC.NO.STATE.FS>
* AVAILABLE AMOUNT
    Y.COLL.AVAIL.AMT =  R.RCA<REDO.FC.AVAIL.COLL.BAL.BR>
    Y.COLL.AVAIL.AMT := @FM: R.RCA<REDO.FC.AVAIL.COLL.BAL.VS>
    Y.COLL.AVAIL.AMT := @FM: R.RCA<REDO.FC.AVAIL.COLL.BAL.TP>
    Y.COLL.AVAIL.AMT := @FM: R.RCA<REDO.FC.AVAIL.COLL.BAL.DI>
    Y.COLL.AVAIL.AMT := @FM: R.RCA<REDO.FC.AVAIL.COLL.BAL.DE>
    Y.COLL.AVAIL.AMT := @FM: R.RCA<REDO.FC.AVAIL.COLL.BAL.FS>
* COLLATERAL AMOUNT
    Y.COLL.AMT =  R.RCA<REDO.FC.SEC.VALUE.BR>
    Y.COLL.AMT := @FM: R.RCA<REDO.FC.SEC.VALUE.VS>
    Y.COLL.AMT := @FM: R.RCA<REDO.FC.SEC.VALUE.TP>
    Y.COLL.AMT := @FM: R.RCA<REDO.FC.SEC.VALUE.DI>
    Y.COLL.AMT := @FM: R.RCA<REDO.FC.SEC.VALUE.DE>
    Y.COLL.AMT := @FM: R.RCA<REDO.FC.SEC.VALUE.FS>
* DESCRIPTION   TAM.BP
    Y.COLL.DESC =  R.RCA<REDO.FC.PROP.DESCR.BR>
    Y.COLL.DESC := @FM: R.RCA<REDO.FC.DESCRIPTION.VS>
    Y.COLL.DESC := @FM: R.RCA<REDO.FC.REMARKS.TP>
    Y.COLL.DESC := @FM: R.RCA<REDO.FC.REMARKS.DI>
    Y.COLL.DESC := @FM: R.RCA<REDO.FC.REMARKS.DE>
    Y.COLL.DESC := @FM: R.RCA<REDO.FC.REMARKS.FS>

    Y.GET.PRODUCT = R.RCA<REDO.FC.PRODUCT>

    Y.AA.PRODUCT='AA-':Y.GET.PRODUCT
    CALL F.READ(FN.REDO.APP.MAPPING, Y.AA.PRODUCT, R.MAPPING, F.REDO.APP.MAPPING, Y.ERR)
    Y.ATTRIBUTE=R.MAPPING<REDO.APP.LINK.TO.RECS>
    Y.ID.MAP = 'AA.':Y.APP.NAME
    LOCATE Y.ID.MAP IN Y.ATTRIBUTE<1,1> SETTING Y.POS.ATT THEN
*  Open Mapping

        CALL F.READ(FN.REDO.APP.MAPPING, Y.ID.MAP, R.MAPPING, F.REDO.APP.MAPPING, Y.ERR)
        IF Y.ERR THEN
* JP20110829 If there is an error => just return
            RETURN
        END

        GOSUB PROCESS.MAPPING

    END
RETURN

*-----------------------------------------------------------------------------------------------
PROCESS.MAPPING:
*==================
    Y.FIELD.FROMS = DCOUNT(R.MAPPING<REDO.APP.FIELD.FROM>, @VM)
    FIELD.POS = 1
    LOOP
    WHILE FIELD.POS LE Y.FIELD.FROMS
        Y.FROM.VALUE = ''
        Y.FROM.VALUE.AMT = ''
        Y.FROM.VALUE.AV.AMT = ''
        Y.FROM.VALUE.DESC = ''
        Y.LOCAL.REF = 'LOCAL.REF'
        Y.APP.FROM   = R.MAPPING<REDO.APP.APP.FROM>
        Y.FIELD.FROM = R.MAPPING<REDO.APP.FIELD.FROM, FIELD.POS>
        Y.FIELD.FROM.ST  = R.MAPPING<REDO.APP.FIELD.FROM, FIELD.POS>
        Y.FIELD.TO = R.MAPPING<REDO.APP.FIELD.TO, FIELD.POS>
        Y.FIELD.TO.TEMP = Y.FIELD.TO
        IF Y.FIELD.FROM EQ Y.FILED.SEC THEN

            GOSUB ITERA.COLATERAL
            GOSUB MAPPING.FIELD
        END ELSE

            GOSUB IS.LOCRT.FLD          ;* PACS00371128 - S/E
        END

        FIELD.POS += 1
    REPEAT

RETURN

IS.LOCRT.FLD:
*===========
*

    Y.LOCAL.F = SUBSTRINGS(Y.FIELD.FROM,1,2)
    IF Y.LOCAL.F EQ 'L.' THEN
        LOC.REF.APPLICATION = Y.APP.FROM
        LOC.REF.FIELDS      = Y.FIELD.FROM
        GOSUB GET.LOCAL.FLD
        Y.FIELD.FROM = LOC.REF.POS<1,1>
        CALL EB.GET.APPL.FIELD(Y.APP.FROM,Y.LOCAL.REF,'',Y.APP.ERR)
        Y.FROM.VALUE = R.RCA<Y.LOCAL.REF,Y.FIELD.FROM>
    END ELSE
        CALL EB.GET.APPL.FIELD(RCA.APPLICATION,Y.FIELD.FROM,'',Y.APP.ERR)
        Y.FROM.VALUE = R.RCA<Y.FIELD.FROM>
    END

    GOSUB MAPPING.FIELD

RETURN

*-----------------------------------------------------------------------------------------------
PROCESS.COLL:
*===========
    Y.COLL.VALUE = 1
    LOOP
    WHILE Y.COLL.VALUE LE NRO.COLLS
        IF Y.COLLATERAL.CODE<1,Y.COLL.VALUE> THEN
            GOSUB GET.FROM.VALUE
        END
        Y.COLL.VALUE += 1
    REPEAT

RETURN

ITERA.COLATERAL:
    Y.COLL.CODE = 1
    LOOP
    WHILE Y.COLL.CODE LE 6
        Y.COLLATERAL.CODE = Y.COLL.CODES<Y.COLL.CODE>
        Y.COLLATERAL.AMT = Y.COLL.AMT<Y.COLL.CODE>
        Y.COLLATERAL.AV.AMT = Y.COLL.AVAIL.AMT<Y.COLL.CODE>
        Y.COLLATERAL.DESC = Y.COLL.DESC<Y.COLL.CODE>
        IF Y.COLLATERAL.CODE THEN
            NRO.COLLS = DCOUNT(Y.COLLATERAL.CODE,@VM) + 1
            GOSUB PROCESS.COLL
        END
        Y.COLL.CODE += 1
    REPEAT
RETURN
*-----------------------------------------------------------------------------------------------
GET.FROM.VALUE:
*=============
    IF (Y.COLL.VALUE EQ 1 AND Y.COLL.CODE EQ 1) THEN
        Y.FROM.VALUE = Y.COLLATERAL.CODE<1,Y.COLL.VALUE>
        Y.FROM.VALUE.AMT = Y.COLLATERAL.AMT<1,Y.COLL.VALUE>
        Y.FROM.VALUE.AV.AMT = Y.COLLATERAL.AV.AMT<1,Y.COLL.VALUE>
        Y.FROM.VALUE.DESC = Y.COLLATERAL.DESC<1,Y.COLL.VALUE>
    END ELSE
        IF Y.FROM.VALUE THEN
            Y.FROM.VALUE := @SM:Y.COLLATERAL.CODE<1,Y.COLL.VALUE>
            Y.FROM.VALUE.AMT := @SM:Y.COLLATERAL.AMT<1,Y.COLL.VALUE>
            Y.FROM.VALUE.AV.AMT := @SM:Y.COLLATERAL.AV.AMT<1,Y.COLL.VALUE>
            Y.FROM.VALUE.DESC := @VM:Y.COLLATERAL.DESC<1,Y.COLL.VALUE>
        END ELSE
            Y.FROM.VALUE = Y.COLLATERAL.CODE<1,Y.COLL.VALUE>
            Y.FROM.VALUE.AMT = Y.COLLATERAL.AMT<1,Y.COLL.VALUE>
            Y.FROM.VALUE.AV.AMT = Y.COLLATERAL.AV.AMT<1,Y.COLL.VALUE>
            Y.FROM.VALUE.DESC = Y.COLLATERAL.DESC<1,Y.COLL.VALUE>
        END
    END

RETURN

*-----------------------------------------------------------------------------------
MAPPING.FIELD:
*===========

    IF NOT(Y.FROM.VALUE) THEN
        RETURN
    END
    IF  Y.FIELD.TO EQ "L.AA.COL.DESC" THEN
        RETURN
    END

    Y.FIELD.TO = Y.FIELD.TO.TEMP
    Y.LOCAL = SUBSTRINGS(Y.FIELD.TO,1,2)
    IF Y.FIELD.TO EQ "ORIGEN.RECURSOS" THEN
        Y.LOCAL = 'L.'
    END

    IF Y.LOCAL EQ 'L.' THEN
        Y.LOCAL.REF = "LOCAL.REF"       ;* PACS00371128 - S/E
        LOC.REF.APPLICATION = APPLICATION
        LOC.REF.FIELDS = Y.FIELD.TO
        GOSUB GET.LOCAL.FLD
        Y.FIELD.TO = LOC.REF.POS<1,1>
        CALL EB.GET.APPL.FIELD(APPLICATION,Y.LOCAL.REF,'',Y.APP.ERR)
        CHANGE @VM TO @SM IN Y.FROM.VALUE
        R.NEW(Y.LOCAL.REF)<1,Y.FIELD.TO> =  Y.FROM.VALUE
    END ELSE

        IF Y.FIELD.TO.TEMP EQ 'LIMIT.REFERENCE' THEN
            CALL EB.GET.APPL.FIELD(APPLICATION,Y.FIELD.TO,'',Y.APP.ERR)
            R.NEW(Y.FIELD.TO) =  FIELD(Y.FROM.VALUE,'.',1)
            Y.FIELD.TO.2='LIMIT.SERIAL'
            CALL EB.GET.APPL.FIELD(APPLICATION,Y.FIELD.TO.2,'',Y.APP.ERR)
            R.NEW(Y.FIELD.TO.2) =  FIELD(Y.FROM.VALUE,'.',2)
        END ELSE
            CALL EB.GET.APPL.FIELD(APPLICATION,Y.FIELD.TO,'',Y.APP.ERR)
            R.NEW(Y.FIELD.TO) =  Y.FROM.VALUE
        END
    END

* ADDITIONAL FIELDS FOR COLLATERAL
    IF Y.FIELD.FROM.ST EQ Y.FILED.SEC THEN
        LOC.REF.APPLICATION = APPLICATION
        LOC.REF.FIELDS = 'L.AA.COL.VAL':@VM:'L.AA.AV.COL.BAL':@VM:'L.AA.COL.DESC'
        GOSUB GET.LOCAL.FLD

        Y.FIELD.TO = LOC.REF.POS<1,1>
        R.NEW(Y.LOCAL.REF)<1,Y.FIELD.TO> = Y.FROM.VALUE.AMT

*        Y.FIELD.TO = LOC.REF.POS<1,2>
*        R.NEW(Y.LOCAL.REF)<1,Y.FIELD.TO> = Y.FROM.VALUE.AV.AMT

        Y.FIELD.TO = LOC.REF.POS<1,3>

        CHANGE @SM TO '-' IN Y.FROM.VALUE.DESC
        CHANGE @VM TO  @SM IN Y.FROM.VALUE.DESC

*       Y.FROM.VALUE.DESC = SUBSTRINGS(Y.FROM.VALUE.DESC, 1, 65)
* AGREE WITH BALA TO CUT A 65 THE DESCRIPTION
        R.NEW(Y.LOCAL.REF)<1,Y.FIELD.TO> = Y.FROM.VALUE.DESC

    END


RETURN

*----------------------------------------------------------------------------------------
INITIALISE:
*============

*JP20110829
    IF (V$FUNCTION NE "I") OR (OFS$SOURCE.ID EQ "TWS") THEN
        PROCESS.GOAHEAD = 0
        RETURN
    END
    E = ''
    Y.ARR.ID = System.getVariable("CURRENT.RCA")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;* AUTO R22 CODE CONVERSION - Start
        Y.ARR.ID = ""
    END ;* AUTO R22 CODE CONVERSION - End

    IF E THEN
        PROCESS.GOAHEAD = 0
        E = ''
        RETURN
    END

    FN.RCA.R.NEW = 'F.RCA.R.NEW'
    F.RCA.R.NEW = ''

    FN.REDO.APP.MAPPING = 'F.REDO.APP.MAPPING'
    F.REDO.APP.MAPPING = ''

    R.RCA = ''
    R.MAPPING = ''
    PROCESS.GOAHEAD = 1
    Y.FIELD.FROMS = ''
    Y.FIELD.FROM = ''
    Y.FIELD.TO = ''
    Y.FILED.SEC = 'SEC.NO.STATE'

    RCA.APPLICATION = 'REDO.CREATE.ARRANGEMENT'

    Y.FROM.VALUE = ''
RETURN

*-----------------------------------------------------------------------------------
OPEN.FILES:
*===========

    CALL OPF(FN.RCA.R.NEW, F.RCA.R.NEW)
    CALL OPF(FN.REDO.APP.MAPPING,F.REDO.APP.MAPPING)

RETURN

GET.LOCAL.FLD:
    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

RETURN

END
