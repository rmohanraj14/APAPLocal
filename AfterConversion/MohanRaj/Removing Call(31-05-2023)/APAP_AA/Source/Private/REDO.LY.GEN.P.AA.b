$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.LY.GEN.P.AA
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL         AUTO R22 CODE CONVERSION        ++ TO +=1,FM TO @FM,SM TO @SM,VM TO @VM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------

    
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
* The functionality is to get information as Customer, AAdvantage Number, Miles generated, Last and First
* Name for AAdvantage Program to generate a cvs file (excel format type) ready to send to AA
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : ENQ.DATA
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date             who           Reference            Description
* 03-MAY-2010    S.Marimuthu    ODR-2009-12-0276      Initial Creation
* 14-NOV-2013    RMONDRAGON     ODR-2009-12-0276      Update
* 03-DEC-2013    RMONDRAGON     ODR-2009-12-0276      Update
* 27-MAY-2014    RMONDRAGON     ODR-2009-12-0276      Update
* 15-OCT-2014    RMONDRAGON     ODR-2009-12-0276      Update to generate the file as service
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.REDO.LY.POINTS
    $INSERT I_F.REDO.LY.POINTS.TOT
    $INSERT I_F.REDO.LY.PROGRAM
    $INSERT I_F.REDO.LY.PROGAERO
    $INSERT I_F.REDO.LY.LOG
    $INSERT I_F.REDO.LY.MFILE.BKP
    $INSERT I_F.REDO.LY.AIR.FILEGEN
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PROGRAM.END

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    LOC.REF.POS = ''
    LOC.REF.APP = 'CUSTOMER'
    LOC.REF.FIELD = 'L.CU.NOM.AIR':@VM:'L.CU.NO.VIA.F' ;*AUTO R22 CODE CONVERSION
    CALL MULTI.GET.LOC.REF(LOC.REF.APP,LOC.REF.FIELD,LOC.REF.POS)
    POS.NOM.AIR = LOC.REF.POS<1,1>
    POS.NO.VIA = LOC.REF.POS<1,2>
    G.DATE = ''
    I.DATE = DATE()
    CALL DIETER.DATE(G.DATE,I.DATE,'')
    CUR.DAY   = TODAY[7,2]
    CUR.MONTH = TODAY[5,2]
    CUR.YEAR  = TODAY[1,4]
    FTIME=OCONV(TIME(),"MTH")

RETURN

*-----------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.LY.POINTS = 'F.REDO.LY.POINTS'
    F.REDO.LY.POINTS = ''
    CALL OPF(FN.REDO.LY.POINTS,F.REDO.LY.POINTS)

    FN.REDO.LY.POINTS.TOT = 'F.REDO.LY.POINTS.TOT'
    F.REDO.LY.POINTS.TOT = ''
    CALL OPF(FN.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT)

    FN.REDO.LY.PROGRAM = 'F.REDO.LY.PROGRAM'
    F.REDO.LY.PROGRAM = ''
    CALL OPF(FN.REDO.LY.PROGRAM,F.REDO.LY.PROGRAM)

    FN.REDO.LY.PROGAERO = 'F.REDO.LY.PROGAERO'
    F.REDO.LY.PROGAERO = ''
    CALL OPF(FN.REDO.LY.PROGAERO,F.REDO.LY.PROGAERO)

    FN.REDO.LY.CUST.NOTRAVREC = 'F.REDO.LY.CUST.NOTRAVREC'
    F.REDO.LY.CUST.NOTRAVREC = ''
    OPEN FN.REDO.LY.CUST.NOTRAVREC TO F.REDO.LY.CUST.NOTRAVREC ELSE
        TEXT = 'Error in opening : ':FN.REDO.LY.CUST.NOTRAVREC
        CALL FATAL.ERROR('REDO.LY.GEN.P.AA')
    END

    FN.REDO.LY.TEMPAA = 'F.REDO.LY.TEMPAA'
    F.REDO.LY.TEMPAA = ''
    OPEN FN.REDO.LY.TEMPAA TO F.REDO.LY.TEMPAA ELSE
        TEXT = 'Error in opening : ':FN.REDO.LY.TEMPAA
        CALL FATAL.ERROR('REDO.LY.GEN.P.AA')
    END

    FN.REDO.LY.LOG = 'F.REDO.LY.LOG'
    F.REDO.LY.LOG = ''
    CALL OPF(FN.REDO.LY.LOG,F.REDO.LY.LOG)

    FN.REDO.LY.MFILE.BKP = 'F.REDO.LY.MFILE.BKP'
    F.REDO.LY.MFILE.BKP = ''
    CALL OPF(FN.REDO.LY.MFILE.BKP,F.REDO.LY.MFILE.BKP)

    FN.REDO.LY.AIR.FILEGEN = 'F.REDO.LY.AIR.FILEGEN'
    F.REDO.LY.AIR.FILEGEN = ''
    CALL OPF(FN.REDO.LY.AIR.FILEGEN,F.REDO.LY.AIR.FILEGEN)

    Y.PATH = ''
    F.PATH = ''

    Y.PROC.UPDATES = 'Y'

    Y.GEN.DATE.SET = ''
    Y.AA.NO.SET = ''
    Y.TOT.MILES.SET = ''
    Y.SEC.NAME.SET = ''
    Y.FIRST.NAME.SET = ''
    NEW.FILE.CONTENT = ''

RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    R.AIR = ''; AIR.ERR = ''
    CALL CACHE.READ(FN.REDO.LY.AIR.FILEGEN,'SYSTEM',R.AIR,AIR.ERR)
    Y.PRGM.ID = R.AIR<REDO.AIRPAR.PROGRAM.ID>
    PREV.PTS.SUB = R.AIR<REDO.AIRPAR.PREV.PTS.SUB>

    IF Y.PRGM.ID EQ '' OR PREV.PTS.SUB EQ '' THEN
        CRT 'PARAMETERS FOR FILE GENERATION ARE NOT DEFINED'
        RETURN
    END

    GOSUB VERIFY.LOG

    IF Y.PRGM.ID THEN
        R.PROGAERO = ''; PROGAERO.ERR = ''

*    CALL F.READ(FN.REDO.LY.PROGAERO,'SYSTEM',R.PROGAERO,F.REDO.LY.PROGAERO,PROGAERO.ERR) ;*Tus Start
        CALL CACHE.READ(FN.REDO.LY.PROGAERO,'SYSTEM',R.PROGAERO,PROGAERO.ERR) ; * Tus End
        IF R.PROGAERO THEN
            Y.PROG.REL = R.PROGAERO<REDO.PA.PROGRAM.ID>
            Y.AIRL.REL = R.PROGAERO<REDO.PA.AIRLINE.ID>
            Y.PATH = R.PROGAERO<REDO.PA.FILE.GEN.PATH>
            CHANGE @VM TO @FM IN Y.PROG.REL ;*AUTO R22 CODE CONVERSION
            CHANGE @VM TO @FM IN Y.AIRL.REL ;*AUTO R22 CODE CONVERSION
            FIND Y.PRGM.ID IN Y.PROG.REL SETTING POS0 THEN
                Y.PROG.AIR = Y.AIRL.REL<POS0>
            END ELSE
                CRT 'PROGRAM-AIRLINE RELATION IS NOT DEFINED'
                RETURN
            END
        END ELSE
            CRT 'PROGRAM-AIRLINE RELATION IS NOT DEFINED'
            RETURN
        END

        IF Y.PATH EQ '' THEN
            CRT 'PATH FOR FILE GENERATION IS NOT DEFINED'
            RETURN
        END

        Y.TOT.CUST = 0
        Y.TOT.ALLCUST = 0
        Y.TOT.ALLCUSTVAL = 0
        CALL F.READ(FN.REDO.LY.PROGRAM,Y.PRGM.ID,R.REC.PRGM,F.REDO.LY.PROGRAM,PRGM.ERR)
        Y.AIRL.PROG = R.REC.PRGM<REDO.PROG.AIRL.PROG>
        Y.POINT.USE = R.REC.PRGM<REDO.PROG.POINT.USE>
        IF Y.AIRL.PROG EQ 'SI' THEN
            SEL.CMD = 'SELECT ':FN.REDO.LY.POINTS:' WITH PROGRAM EQ ':Y.PRGM.ID
            CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECS,PTS.ERR)
            LOOP
                REMOVE Y.PTS.ID FROM SEL.LIST SETTING PTS.POS
            WHILE Y.PTS.ID:PTS.POS
                Y.FIRST.GET.CUS = 'Y'
                GOSUB UPD.AA.MILES
            REPEAT
        END
    END

    Y.TOT.CUS.WR = DCOUNT(NEW.FILE.CONTENT,@VM) ;*AUTO R22 CODE CONVERSION

    Y.TOT.UPD = 'Y'
    GOSUB UPD.ACC.MOV
    IF (Y.TOT.CUS.WR NE 0) THEN
        GOSUB CREATE.CSV
        GOSUB UPD.LOG
    END

RETURN

*-----------------------------------------------------------------------------
VERIFY.LOG:
*-----------------------------------------------------------------------------

    Y.REC.ID = Y.PRGM.ID:'-NEXTGENTIME'

*  READU REC.CONTENT FROM F.REDO.LY.TEMPAA,Y.REC.ID THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.TEMPAA,Y.REC.ID,REC.CONTENT,F.REDO.LY.TEMPAA,REC.CONTENT.ERR,RETRY.VAR)
    IF REC.CONTENT THEN  ;* Tus End
        Y.DATE = FIELD(REC.CONTENT,'-',2)
        IF Y.DATE EQ TODAY THEN
            Y.NO.GEN = FIELD(REC.CONTENT,'-',1)
        END ELSE
            Y.NO.GEN = 1
            REC.CONTENT = ''
            REC.CONTENT = Y.NO.GEN:'-':TODAY

*      WRITE REC.CONTENT TO F.REDO.LY.TEMPAA,Y.REC.ID ;*Tus Start
            CALL F.WRITE(FN.REDO.LY.TEMPAA,Y.REC.ID,REC.CONTENT);*Tus End
        END
    END ELSE
        Y.NO.GEN = 1
        REC.CONTENT = ''
        REC.CONTENT = Y.NO.GEN:'-':TODAY

*    WRITE REC.CONTENT TO F.REDO.LY.TEMPAA,Y.REC.ID ;*Tus Start
        CALL F.WRITE(FN.REDO.LY.TEMPAA,Y.REC.ID,REC.CONTENT);*Tus End
    END

RETURN

*-----------------------------------------------------------------------------
CREATE.CSV:
*-----------------------------------------------------------------------------

    FILE.NAME = Y.PROG.AIR:TODAY[7,2]:TODAY[5,2]:TODAY[1,4]:TIME():'.CSV'

    OPENSEQ Y.PATH,FILE.NAME TO F.PATH ELSE
        CREATE F.PATH ELSE
        END
    END

    IF LNGG EQ 1 THEN
        Y.CUS.WR.LINE = 'GENERATION DATE,FREQUENT FLYER NO.,TOTAL OF MILES,SECOND NAME,FIRST NAME'
    END ELSE
        Y.CUS.WR.LINE = 'FECHA GENERACION,NO. VIAJERO FREQUENTE,TOTAL DE MILLAS,SEGUNDO NOMBRE,PRIMER NOMBRE'
    END

    WRITESEQ Y.CUS.WR.LINE APPEND TO F.PATH ELSE
    END

    CRT 'GENERATING MILES FILE...'
    Y.TOT.CUS.WR = 0
    Y.TOT.CUS.WR = DCOUNT(NEW.FILE.CONTENT,@VM) - 1 ;*AUTO R22 CODE CONVERSION
    Y.CUS.WR = 1
    LOOP
    WHILE Y.CUS.WR LE Y.TOT.CUS.WR
        Y.CUS.WR.LINE = FIELD(NEW.FILE.CONTENT,@VM,Y.CUS.WR) ;*AUTO R22 CODE CONVERSION
        WRITESEQ Y.CUS.WR.LINE APPEND TO F.PATH ELSE
        END
        Y.CUS.WR += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    CRT 'FILE GENERATED'

RETURN

*-----------------------------------------------------------------------------
UPD.AA.MILES:
*-----------------------------------------------------------------------------
* To update AA miles value in the enquiry

    Y.NOTRAVREC = 'N'

*  READU FILE.CONTENT FROM F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT,F.REDO.LY.CUST.NOTRAVREC,FILE.CONTENT.ERR,RETRY.VAR)
    IF FILE.CONTENT THEN  ;* Tus End
        FIND Y.PRGM.ID IN FILE.CONTENT SETTING POS3 THEN
            Y.NOTRAVREC = 'Y'
        END
    END

    CALL F.READ(FN.REDO.LY.POINTS,Y.PTS.ID,R.REC.POINTS,F.REDO.LY.POINTS,PTS.ERR.R)
    Y.PRODUCTS=R.REC.POINTS<REDO.PT.PRODUCT>
    Y.PROGRAMS=R.REC.POINTS<REDO.PT.PROGRAM>
    VAR.MILES=R.REC.POINTS<REDO.PT.QUANTITY>
    VAR.MILES.VAL=R.REC.POINTS<REDO.PT.QTY.VALUE>
    VAR.GEN.DATE=R.REC.POINTS<REDO.PT.GEN.DATE>
    VAR.STATUS=R.REC.POINTS<REDO.PT.STATUS>
    Y.PROC.ALT = 'N'
    Y.TOT.MILES = 0
    Y.TOT.MILESVAL = 0
    Y.TOT.UPD = 'N'
    Y.TOT.PROD = DCOUNT(Y.PRODUCTS,@VM) ;*AUTO R22 CODE CONVERSION
    COUNTER1 = 1
    LOOP
    WHILE COUNTER1 LE Y.TOT.PROD
        Y.PROG.TO.CHK = FIELD(Y.PROGRAMS,@VM,COUNTER1) ;*AUTO R22 CODE CONVERSION
        Y.TOT.PROG = DCOUNT(Y.PROG.TO.CHK,@SM) ;*AUTO R22 CODE CONVERSION
        COUNTER2 = 1
        LOOP
        WHILE COUNTER2 LE Y.TOT.PROG
            Y.PROGRAM.ID = FIELD(Y.PROG.TO.CHK,@SM,COUNTER2) ;*AUTO R22 CODE CONVERSION
            IF Y.PRGM.ID EQ Y.PROGRAM.ID THEN
                GOSUB UPD.AA.MILES2
            END
            COUNTER2 += 1
        REPEAT
        COUNTER1 += 1
    REPEAT

    IF Y.AA.NO NE 'NR' THEN
        Y.REC.COM = Y.GEN.DATE:',':Y.AA.NO:',':Y.TOT.MILES:',':Y.SEC.NAME:',':Y.FIRST.NAME

        Y.NEXT = ''
        GOSUB CHECK.TEMP.REP

        IF Y.NEXT EQ 'N' THEN
            RETURN
        END

        IF Y.REC.COM THEN
            NEW.FILE.CONTENT := Y.REC.COM:@VM ;*AUTO R22 CODE CONVERSION
        END

        GOSUB UPD.VAR.MFILE
        Y.UPD.ACC.MOV = 'N'
        Y.TOT.UPD = 'Y'
        GOSUB UPD.REDO.LY.POINTS.TOT
        GOSUB UPD.SPEC.REC
    END ELSE
        GOSUB CHECK.NOTRAVREC
    END

RETURN

*-------------
UPD.AA.MILES2:
*-------------

    VAR.MILES.TO.CHK = FIELD(VAR.MILES,@VM,COUNTER1) ;*AUTO R22 CODE CONVERSION
    VAR.MILES.VAL.TO.CHK = FIELD(VAR.MILES.VAL,@VM,COUNTER1) ;*AUTO R22 CODE CONVERSION
    VAR.GEN.DATE.TO.CHK = FIELD(VAR.GEN.DATE,@VM,COUNTER1) ;*AUTO R22 CODE CONVERSION
    VAR.STATUS.TO.CHK = FIELD(VAR.STATUS,@VM,COUNTER1) ;*AUTO R22 CODE CONVERSION
    Y.MILES = FIELD(VAR.MILES.TO.CHK,@SM,COUNTER2) ;*AUTO R22 CODE CONVERSION
    Y.MILES.VAL = FIELD(VAR.MILES.VAL.TO.CHK,@SM,COUNTER2) ;*AUTO R22 CODE CONVERSION
    Y.GEN.DATE = FIELD(VAR.GEN.DATE.TO.CHK,@SM,COUNTER2) ;*AUTO R22 CODE CONVERSION
    Y.STATUS = FIELD(VAR.STATUS.TO.CHK,@SM,COUNTER2) ;*AUTO R22 CODE CONVERSION
    IF Y.FIRST.GET.CUS EQ 'Y' THEN
        GOSUB GET.AIR.NO
    END
    IF Y.AA.NO EQ 'NR' AND Y.NOTRAVREC EQ 'Y' THEN
        IF (Y.GEN.DATE LE TODAY) AND (Y.STATUS EQ 'Liberada') THEN
            R.REC.POINTS<REDO.PT.STATUS,COUNTER1,COUNTER2> = 'Pendiente.Someter'
            Y.PROC.ALT = 'Y'
        END
    END
    IF Y.AA.NO NE 'NR' AND Y.NOTRAVREC EQ 'Y' THEN
        IF (Y.GEN.DATE LE TODAY) AND (Y.STATUS EQ 'Liberada' OR Y.STATUS EQ 'Pendiente.Someter') THEN
            Y.TOT.MILES+=Y.MILES
            Y.TOT.ALLCUST+=Y.MILES
            Y.TOT.MILESVAL+=Y.MILES.VAL
            Y.TOT.ALLCUSTVAL+=Y.MILES.VAL
            R.REC.POINTS<REDO.PT.STATUS,COUNTER1,COUNTER2> = 'Sometida.':TODAY
            IF Y.PROC.UPDATES EQ 'Y' THEN
                GOSUB DEL.NOTRAVREC
            END
        END
    END
    IF Y.AA.NO NE 'NR' AND Y.NOTRAVREC EQ 'N' THEN
        IF (Y.GEN.DATE LE TODAY) AND (Y.STATUS EQ 'Liberada' OR Y.STATUS EQ 'Pendiente.Someter') THEN
            Y.TOT.MILES+=Y.MILES
            Y.TOT.ALLCUST+=Y.MILES
            Y.TOT.MILESVAL+=Y.MILES.VAL
            Y.TOT.ALLCUSTVAL+=Y.MILES.VAL
            R.REC.POINTS<REDO.PT.STATUS,COUNTER1,COUNTER2> = 'Sometida.':TODAY
        END
    END

RETURN

*----------
GET.AIR.NO:
*----------

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.PTS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        Y.AA.NO = 'NR'
        Y.FIRST.NAME = R.CUSTOMER<EB.CUS.GIVEN.NAMES>
        Y.SEC.NAME = R.CUSTOMER<EB.CUS.FAMILY.NAME>
        Y.AIR.NAMES = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.NOM.AIR>
        Y.AA.NOS = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.NO.VIA>
        CHANGE @VM TO @FM IN Y.AIR.NAMES ;*AUTO R22 CODE CONVERSION
        CHANGE @VM TO @FM IN Y.AA.NOS ;*AUTO R22 CODE CONVERSION
        FIND Y.PROG.AIR IN Y.AIR.NAMES SETTING POS2 THEN
            Y.AA.NO = Y.AA.NOS<POS2>
            IF Y.AA.NO EQ '' THEN
                Y.AA.NO = 'NR'
            END
        END ELSE
            Y.AA.NO = 'NR'
        END
        Y.FIRST.GET.CUS = 'N'
    END

RETURN

*------------------------------------------------------------------------------
UPD.SPEC.REC:
*---------------------------------------------------------------------------------

    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS,Y.PTS.ID,R.REC.POINTS)

RETURN

*------------------------------------------------------------------------------
CHECK.NOTRAVREC:
*---------------------------------------------------------------------------------


*  READU FILE.CONTENT FROM F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT,F.REDO.LY.CUST.NOTRAVREC,FILE.CONTENT.ERR,RETRY.VAR)
    IF FILE.CONTENT THEN  ;* Tus End
        FIND Y.PRGM.ID IN FILE.CONTENT SETTING POS4 THEN
            RETURN
        END ELSE
            FILE.CONTENT := @FM:Y.PRGM.ID ;*AUTO R22 CODE CONVERSION

*      WRITE FILE.CONTENT TO F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID ;*Tus Start
            CALL F.WRITE(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT);*Tus End
        END
    END ELSE
        FILE.CONTENT = Y.PRGM.ID

*    WRITE FILE.CONTENT TO F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID ;*Tus Start
        CALL F.WRITE(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT);*Tus End
    END

RETURN

*------------------------------------------------------------------------------
DEL.NOTRAVREC:
*---------------------------------------------------------------------------------


*  READU FILE.CONTENT FROM F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT,F.REDO.LY.CUST.NOTRAVREC,FILE.CONTENT.ERR,RETRY.VAR)
    IF FILE.CONTENT THEN  ;* Tus End
        FIND Y.PRGM.ID IN FILE.CONTENT SETTING POS5 THEN
            FILE.CONTENT<POS5> = ''

*      WRITE FILE.CONTENT TO F.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID ;*Tus Start
            CALL F.WRITE(FN.REDO.LY.CUST.NOTRAVREC,Y.PTS.ID,FILE.CONTENT);*Tus End
        END
    END

RETURN

*------------------------------------------------------------------------------
CHECK.TEMP.REP:
*------------------------------------------------------------------------------

    Y.REC.TO.READ = Y.PRGM.ID:'-':Y.PTS.ID

*  READU REC.CONTENT FROM F.REDO.LY.TEMPAA,Y.REC.TO.READ THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.TEMPAA,Y.REC.TO.READ,REC.CONTENT,F.REDO.LY.TEMPAA,REC.CONTENT.ERR,RETRY.VAR)
    IF REC.CONTENT THEN  ;* Tus End
        IF Y.TOT.MILES EQ 0 AND (PREV.PTS.SUB EQ '' OR PREV.PTS.SUB EQ 'NO') THEN
            Y.REC.COM = ''
            RETURN
        END
        IF REC.CONTENT NE Y.REC.COM THEN
            GOSUB UPD.PTS.SUB.REC
            IF PREV.PTS.SUB EQ 'YES' THEN
                Y.REC.COM = NEW.REC.CONTENT
            END
        END ELSE
            IF PREV.PTS.SUB EQ 'YES' THEN
                Y.REC.COM = REC.CONTENT
            END ELSE
                GOSUB UPD.PTS.SUB.REC
            END
        END
    END ELSE
        IF Y.TOT.MILES NE 0 THEN
            REC.CONTENT = Y.REC.COM

*      WRITE REC.CONTENT TO F.REDO.LY.TEMPAA,Y.REC.TO.READ ;*Tus Start
            CALL F.WRITE(FN.REDO.LY.TEMPAA,Y.REC.TO.READ,REC.CONTENT);*Tus End
        END ELSE
            Y.NEXT = 'N'
        END
    END

RETURN

*---------------
UPD.PTS.SUB.REC:
*---------------

    Y.CURR.REC = FIELD(REC.CONTENT,',',3)
    Y.MOD.REC = FIELD(Y.REC.COM,',',3)
    Y.NEW.REC = FIELD(REC.CONTENT,',',3) + FIELD(Y.REC.COM,',',3)
    NEW.REC.CONTENT = FIELD(REC.CONTENT,',',1):',':FIELD(REC.CONTENT,',',2):',':Y.NEW.REC:','
    NEW.REC.CONTENT := FIELD(REC.CONTENT,',',4):',':FIELD(REC.CONTENT,',',5)
    REC.CONTENT = ''
    REC.CONTENT = NEW.REC.CONTENT

*  WRITE REC.CONTENT TO F.REDO.LY.TEMPAA,Y.REC.TO.READ ;*Tus Start
    CALL F.WRITE(FN.REDO.LY.TEMPAA,Y.REC.TO.READ,REC.CONTENT);*Tus End

RETURN

*------------------------------------------------------------------------------
UPD.REDO.LY.POINTS.TOT:
*---------------------------------------------------------------------------------
*Update the REDO.LY.POINTS.TOT local application based on the file generation

    GOSUB UPD.PTS.MMYY
    GOSUB UPD.PTS.PGM.YY
    GOSUB UPD.PTS.YYYY
    GOSUB UPD.PTS.ALL.PGM
    GOSUB UPD.PTS.ALL.PGM.MMYY
    GOSUB UPD.PTS.ALL.PGM.YY
    GOSUB UPD.PTS.ALL.YYYY
    IF Y.POINT.USE EQ 3 THEN
        GOSUB UPD.PTS.BUS
    END
    IF Y.POINT.USE EQ 4 THEN
        GOSUB UPD.PTS.CUS
    END

RETURN

*------------------------------------------------------------------------------
UPD.PTS.MMYY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = Y.PTS.ID:Y.PRGM.ID:CUR.MONTH:CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.PGM.YY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = Y.PTS.ID:Y.PRGM.ID:'ALL':CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.YYYY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = Y.PTS.ID:'ALL':CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.ALL.PGM:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = 'ALL':Y.PRGM.ID
    R.REDO.LY.POINTS.TOT =''
    CALL F.READU(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR,'')
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.ALL.PGM.MMYY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = 'ALL':Y.PRGM.ID:CUR.MONTH:CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READU(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR,'')
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.ALL.PGM.YY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = 'ALL':Y.PRGM.ID:CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READU(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR,'')
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.ALL.YYYY:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = 'ALL':CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READU(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR,'')
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.BUS:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = Y.PTS.ID:'B'
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PTS.CUS:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = Y.PTS.ID:'C'
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.ACC.MOV:
*---------------------------------------------------------------------------------

    TOT.POINTS.ID = 'ALL':Y.PRGM.ID:CUR.DAY:CUR.MONTH:CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READU(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR,'')
    Y.UPD.ACC.MOV = 'Y'
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)

RETURN

*------------------------------------------------------------------------------
UPD.PROCESS:
*---------------------------------------------------------------------------------

    VAR.AVAIL = '' ; VAR.USED = ''
    VAR.AVAIL.VAL = '' ; VAR.USED.VAL = ''
    VAR.USED   =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.USED.POINTS>
    VAR.USED.VAL = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.USED.VALUE>
    IF Y.UPD.ACC.MOV EQ 'N' THEN
        VAR.AVAIL = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS>
        VAR.AVAIL.VAL = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE>
        VAR.AVAIL -= Y.TOT.MILES
        VAR.AVAIL.VAL -= Y.TOT.MILESVAL
        R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS> = VAR.AVAIL
        R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE> = VAR.AVAIL.VAL
        VAR.USED += Y.TOT.MILES
        VAR.USED.VAL += Y.TOT.MILESVAL
    END ELSE
        VAR.USED += Y.TOT.ALLCUST
        VAR.USED.VAL += Y.TOT.ALLCUSTVAL
    END
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.USED.POINTS> = VAR.USED
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.USED.VALUE> = VAR.USED.VAL

RETURN

*--------------------------------------------------------------------------------
ASSIGN.AUDIT:
*-------------------------------------------------------------------------------
* This section updates audit fields of REDO.LY.POINTS table
*----------------------------------------------------------

    CURR.NO = ''
    CUR.TIME = OCONV(TIME(), "MT")
    * CONVERT ':' TO '' IN CUR.TIME
    CHANGE ':' TO '' IN CUR.TIME ;*AUTO R22 CODE CONVERSION
    IF Y.TOT.UPD EQ 'Y' THEN
        CURR.NO = R.REDO.LY.POINTS.TOT<REDO.PT.T.CURR.NO>
    END ELSE
        CURR.NO = R.REC.POINTS<REDO.PT.CURR.NO>
    END
    IF CURR.NO EQ '' THEN
        CURR.NO = 1
    END ELSE
        CURR.NO += 1 ;*AUTO R22 CODE CONVERSION
    END
    IF Y.TOT.UPD EQ 'Y' THEN
        R.REDO.LY.POINTS.TOT<REDO.PT.T.RECORD.STATUS> = ''
        R.REDO.LY.POINTS.TOT<REDO.PT.T.CURR.NO> = CURR.NO
	* R.REDO.LY.POINTS.TOT<REDO.PT.T.INPUTTER> = TNO:'_':OPERATOR
        R.REDO.LY.POINTS.TOT<REDO.PT.T.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
        R.REDO.LY.POINTS.TOT<REDO.PT.T.DATE.TIME> = G.DATE[3,6]:CUR.TIME
	*R.REDO.LY.POINTS.TOT<REDO.PT.T.AUTHORISER> = TNO:'_':OPERATOR
        R.REDO.LY.POINTS.TOT<REDO.PT.T.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
        R.REDO.LY.POINTS.TOT<REDO.PT.T.CO.CODE> = ID.COMPANY
        R.REDO.LY.POINTS.TOT<REDO.PT.T.DEPT.CODE> = 1
    END ELSE
        R.REC.POINTS<REDO.PT.RECORD.STATUS> = ''
        R.REC.POINTS<REDO.PT.CURR.NO> = CURR.NO
	* R.REC.POINTS<REDO.PT.INPUTTER> = TNO:'_':OPERATOR
        R.REC.POINTS<REDO.PT.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
        R.REC.POINTS<REDO.PT.DATE.TIME> = G.DATE[3,6]:CUR.TIME
	*R.REC.POINTS<REDO.PT.AUTHORISER> = TNO:'_':OPERATOR
        R.REC.POINTS<REDO.PT.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
        R.REC.POINTS<REDO.PT.CO.CODE> = ID.COMPANY
        R.REC.POINTS<REDO.PT.DEPT.CODE> = 1
    END

RETURN

*-----------------------------------------------------------------------------
UPD.LOG:
*-----------------------------------------------------------------------------

    LOCK.FLUSH =''
    R.LOCKING= ''
    Y.LOG.ID = Y.PRGM.ID:TODAY[7,2]:TODAY[5,2]:TODAY[1,4]:'-':Y.NO.GEN
    R.LOCKING<REDO.LOG.PROC.DATE> = TODAY
    R.LOCKING<REDO.LOG.PROC.TIME> = FTIME
    R.LOCKING<REDO.LOG.FILE> = FILE.NAME
    R.LOCKING<REDO.LOG.STATUS> = 'File generated with ':Y.TOT.CUS.WR:' customer records'
    GOSUB UPD.MFILE
    CALL LOG.WRITE(FN.REDO.LY.LOG,Y.LOG.ID,R.LOCKING,LOCK.FLUSH)

    Y.REC.ID = Y.PRGM.ID:'-NEXTGENTIME'

*  READU REC.CONTENT FROM F.REDO.LY.TEMPAA,Y.REC.ID THEN ;*Tus Start
    RETRY.VAR = ""
    CALL F.READU(FN.REDO.LY.TEMPAA,Y.REC.ID,REC.CONTENT,F.REDO.LY.TEMPAA,REC.CONTENT.ERR,RETRY.VAR)
    IF REC.CONTENT THEN  ;* Tus End
        Y.NO.GEN = FIELD(REC.CONTENT,'-',1)
        REC.CONTENT = ''
        REC.CONTENT = Y.NO.GEN + 1:'-':TODAY

*    WRITE REC.CONTENT TO F.REDO.LY.TEMPAA,Y.REC.ID ;*Tus Start
        CALL F.WRITE(FN.REDO.LY.TEMPAA,Y.REC.ID,REC.CONTENT);*Tus End
    END

RETURN

*-----------------------------------------------------------------------------
UPD.VAR.MFILE:
*-----------------------------------------------------------------------------

    Y.GEN.DATE.SET := FIELD(Y.REC.COM,',',1):@VM ;*AUTO R22 CODE CONVERSION
    Y.AA.NO.SET := FIELD(Y.REC.COM,',',2):@VM ;*AUTO R22 CODE CONVERSION
    Y.TOT.MILES.SET := FIELD(Y.REC.COM,',',3):@VM ;*AUTO R22 CODE CONVERSION
    Y.SEC.NAME.SET := FIELD(Y.REC.COM,',',4):@VM ;*AUTO R22 CODE CONVERSION
    Y.FIRST.NAME.SET := FIELD(Y.REC.COM,',',5):@VM ;*AUTO R22 CODE CONVERSION

RETURN

*-----------------------------------------------------------------------------
UPD.MFILE:
*-----------------------------------------------------------------------------

    ID.MFILE = FILE.NAME
    R.REDO.LY.MFILE.BKP = ''
    CALL F.READU(FN.REDO.LY.MFILE.BKP,ID.MFILE,R.REDO.LY.MFILE.BKP,F.REDO.LY.MFILE.BKP,MFILE.ERR,'')
    R.REDO.LY.MFILE.BKP<REDO.MFILE.GEN.DATE> = Y.GEN.DATE.SET
    R.REDO.LY.MFILE.BKP<REDO.MFILE.AIRL.NO> = Y.AA.NO.SET
    R.REDO.LY.MFILE.BKP<REDO.MFILE.TOT.MILES> = Y.TOT.MILES.SET
    R.REDO.LY.MFILE.BKP<REDO.MFILE.SEC.NAME> = Y.SEC.NAME.SET
    R.REDO.LY.MFILE.BKP<REDO.MFILE.FIRST.NAME> = Y.FIRST.NAME.SET
    GOSUB ASSIGN.AUDIT.MFILE
    CALL F.WRITE(FN.REDO.LY.MFILE.BKP,ID.MFILE,R.REDO.LY.MFILE.BKP)

RETURN

*-------------------------------------------------------------------------------
ASSIGN.AUDIT.MFILE:
*-------------------------------------------------------------------------------

    CURR.NO = ''
    CUR.TIME = OCONV(TIME(), "MT")
    * CONVERT ':' TO '' IN CUR.TIME
    CHANGE ':' TO '' IN CUR.TIME ;*AUTO R22 CODE CONVERSION
    CURR.NO = R.REDO.LY.MFILE.BKP<REDO.MFILE.CURR.NO>
    IF CURR.NO EQ '' THEN
        CURR.NO = 1
    END ELSE
        CURR.NO += 1 ;*AUTO R22 CODE CONVERSION
    END
    R.REDO.LY.MFILE.BKP<REDO.MFILE.RECORD.STATUS> = ''
    R.REDO.LY.MFILE.BKP<REDO.MFILE.CURR.NO> = CURR.NO
    * R.REDO.LY.MFILE.BKP<REDO.MFILE.INPUTTER> = TNO:'_':OPERATOR
    R.REDO.LY.MFILE.BKP<REDO.MFILE.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.MFILE.BKP<REDO.MFILE.DATE.TIME> = G.DATE[3,6]:CUR.TIME
    *R.REDO.LY.MFILE.BKP<REDO.MFILE.AUTHORISER> = TNO:'_':OPERATOR
    R.REDO.LY.MFILE.BKP<REDO.MFILE.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.MFILE.BKP<REDO.MFILE.CO.CODE> = ID.COMPANY
    R.REDO.LY.MFILE.BKP<REDO.MFILE.DEPT.CODE> = 1

RETURN

*-----------------------------------------------------------------------------
PROGRAM.END:
*-----------------------------------------------------------------------------
END
