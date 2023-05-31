* @ValidationCode : Mjo5NTEyNzc0MTc6Q3AxMjUyOjE2ODU1MzAwMDc3NjI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:16:47
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
SUBROUTINE REDO.FC.A.AA.ACTIVITY
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This routine will be executed at Auth Level for the Following version of
* AA.ARRANGEMENT.ACTIVITY,AA.APAP.
*------------------------------------------------------------------------------------------
*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE AA.ARRANGEMENT.ACTIVITY
* Attached as     : ROUTINE
* Primary Purpose : Call subroutine in post authorization of AA.ARRANGEMENT.ACTIVITY
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            : 21 Julio 2011
* Amended by      : MGudino - TAM Latin America
* Date            : 24 Agosto 2011
* Amended by      : Juan Pablo armas - TAM Latin America
* Date            : 02 Septiembre 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSTION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSTION         CALL method format changed
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_System
    $USING APAP.REDOFCFI
    $USING APAP.TAM

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS.MAIN
    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS.MAIN:
*=============
*---------------------------------------

*BEGIN / ADDED BY TAM.BP MARCELO G - 25/08/2011
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    TXN.REF.ID.POS = LOC.REF.POS<1,1>
*JP20111214 Amend coding
    Y.TXN.ID = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,TXN.REF.ID.POS>
    IF NOT(Y.TXN.ID) THEN
        Y.TXN.ID = System.getVariable("CURRENT.RCA")
* R22 Auto Conversion start
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN
            Y.TXN.ID = ""
        END
* R22 Auto Conversion End
        R.NEW(AA.ARR.ACT.LOCAL.REF)<1,TXN.REF.ID.POS> = Y.TXN.ID
    END

    Y.ARRANGEMENT.ID = R.NEW(AA.ARR.ACT.ARRANGEMENT)

    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,Y.TXN.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,REDO.CREATE.ARRANGEMENT.ERR)
    IF REDO.CREATE.ARRANGEMENT.ERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.REDO.CREATE.ARRANGEMENT
        CALL STORE.END.ERROR
        RETURN
    END
    Y.IMG.TYPES = R.REDO.CREATE.ARRANGEMENT<REDO.FC.IMG.TYPE>
    Y.IMG.IDS = R.REDO.CREATE.ARRANGEMENT<REDO.FC.IMG.ID>
    Y.COUNT.IMG = DCOUNT(Y.IMG.IDS,@VM)
* Create registers in IM.DOCUMENT.IMAGE and IM.DOCUMENT.UPDATE

    Y.IMAGE =1
    LOOP
    WHILE Y.IMAGE LE Y.COUNT.IMG
        Y.IMG.TYPE = R.REDO.CREATE.ARRANGEMENT<REDO.FC.IMG.TYPE, Y.IMAGE>
        Y.IMG.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.IMG.ID, Y.IMAGE>
*IM.DOCUMENT.IMAGE
        Y.VERSION.NAME = 'IM.DOCUMENT.IMAGE,APAP'
        Y.OFS.BODY =  ',,IMAGE.TYPE=':Y.IMG.TYPE:',IMAGE.APPLICATION=AA.ARRANGEMENT,IMAGE.REFERENCE=':Y.ARRANGEMENT.ID:','
        Y.OFS.BODY := 'SHORT.DESCRIPTION=':Y.IMG.ID:',DESCRIPTION=':Y.TXN.ID:',MULTI.MEDIA.TYPE:1:1=IMAGE'
        GOSUB PROCESS.OFS.MESSAGE
        Y.IMAGE+=1
    REPEAT

*BEGIN / ADD BY BRYAN - 02/09/2011
*
*JPA this is happening ONLY if it is SECURED
    IF R.REDO.CREATE.ARRANGEMENT<REDO.FC.SECURED> EQ 'SI' THEN
        APAP.REDOFCFI.redoFcArrangementAuth();* R22 Manual conversion
        IF R.REDO.CREATE.ARRANGEMENT<REDO.FC.TYPE.OF.SEC.DI> EQ '' ELSE
            APAP.TAM.redoFcSPictoracion();* R22 Manual conversion
        END
    END

*END
*

*JP20110902 Actualiza el estado del template RCA
    R.REDO.CREATE.ARRANGEMENT<REDO.FC.STATUS.TEMPLATE> = 'OK'
    CALL F.WRITE(FN.REDO.CREATE.ARRANGEMENT,Y.TXN.ID,R.REDO.CREATE.ARRANGEMENT)

RETURN
*------------------------
PROCESS.OFS.MESSAGE:
*=========

*BEGIN / ADDED BY TAM.BP MARCELO G - 25/08/2011
    VERSION.NAME = Y.VERSION.NAME
    OFS.USER.PWD = "/"
    OFS.MSG.HEADER = VERSION.NAME:'/I/PROCESS/,':OFS.USER.PWD:'//0'
    OFS.BODY = Y.OFS.BODY
    OFS.MSG = OFS.MSG.HEADER:OFS.BODY

    OFS.SRC<1> = 'RCA'
    OFS.RESP = ''
    TXN.COMMIT = ''

    OFS.STR = OFS.MSG
    OFS.MSG.IDD = ''
    OFS.SRC = 'APAP.B.180.OFS'
    OPTIONS = ''

    CALL OFS.POST.MESSAGE(OFS.STR,OFS.MSG.IDD,OFS.SRC,OPTIONS)
*END MARCELO G - 25/08/2011

RETURN

*------------------------
INITIALISE:
*=========

    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''

    LOC.REF.APPLICATION = 'AA.ARRANGEMENT.ACTIVITY'
    LOC.REF.FIELDS = 'TXN.REF.ID'
    LOC.REF.POS = ''

    PROCESS.GOAHEAD = 1
RETURN

*------------------------
OPEN.FILES:
*=========

    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)
RETURN
*------------
END
