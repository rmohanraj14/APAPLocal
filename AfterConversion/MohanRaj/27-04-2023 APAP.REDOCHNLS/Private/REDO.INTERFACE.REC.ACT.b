* @ValidationCode : MjotNTkxNjI4MjU5OkNwMTI1MjoxNjgxMzgwODU3OTE3OklUU1M6LTE6LTE6MjM0MjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 2342
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC)
*------------------------------------------------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Temenos Application Management
*Program Name      : REDO.INTERFACE.REC.ACT
*Developed for     : ODR-2010-03-0021
*Date              : 27.07.2010
*-----------------------------------------------------------------------------------------------------------------
* Description : The is used to write the interface activity and details in local applications REDO.INTERFACE.ACT and REDO.INTERFACE.ACT.DETAILS
*               when an error of any kind exists during each one of interfaces processing
*
*------------------------------------------------------------------------------------------------------------------
* Input/Output:
* -------------
* In  : N/A
* Out : N/A
*------------------------------------------------------------------------------------------------------------------
* Dependencies:
* -------------
* Calls     : N/A
* Called By : N/A
*------------------------------------------------------------------------------------------------------------------
* Revision History:
* -----------------
* Date              Name              Reference                        Version
* -------           ----              ----------                        --------
* 27.07.2010      Sakthi S          ODR-2010-03-0021                   Initial Creation
* 12.10.2010      Sakthi S          ODR-2010-03-0021                   Batch Process Modified
* 16.06.2011      RMONDRAGON        ODR-2010-03-0021                   Fix for PACS00056300: Change to input the records in
*                                                                      REDO.INTERFACE.ACT.DETAILS using as the first part of
*                                                                      the ID the Interface Code (INT.CODE as routine parameter)
*                                                                      instead of the Interface Name parametrized in REDO.INTERFACE.PARAM
* 09.08.2011      RMONDRAGON        ODR-2010-03-0021                   Fix in case INT.CODE parameter is not initialized by
*                                                                      the development uses this routine
* 04.10.2011      Pradeep S         PCAS00132255                       Hard coding of Email directory removed.Parameterized using the
*                                                                      table INTERFACE.CONFIG.PRT
* 10-APR-2023     Conversion tool   R22 Auto conversion       FM TO @FM, VM to @VM, TNO to C$T24.SESSION.NO
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*------------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.PARAM
    $INSERT I_F.REDO.INTERFACE.ACT
    $INSERT I_F.REDO.INTERFACE.ACT.DETAILS
    $INSERT I_F.REDO.INTERFACE.NOTIFY
    $INSERT I_F.REDO.INTERFACE.MON.TYPE
    $INSERT I_F.LOCKING
    $INSERT I_F.REDO.INTERFACE.REFER
    $INSERT I_F.INTERFACE.CONFIG.PRT

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*------------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------------

    FN.REDO.INTERFACE.PARAM = "F.REDO.INTERFACE.PARAM"
    F.REDO.INTERFACE.PARAM = ""
    R.REDO.INTERFACE.PARAM = ""
    Y.REDO.INT.PAR.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.PARAM,F.REDO.INTERFACE.PARAM)

    FN.REDO.INTERFACE.ACT = "F.REDO.INTERFACE.ACT"
    F.REDO.INTERFACE.ACT = ""
    R.REDO.INTERFACE.ACT = ""
    Y.REDO.INT.ACT.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.ACT,F.REDO.INTERFACE.ACT)

    FN.REDO.INTERFACE.ACT.DETAILS = "F.REDO.INTERFACE.ACT.DETAILS"
    F.REDO.INTERFACE.ACT.DETAILS = ""
    R.REDO.INTERFACE.ACT.DETAILS = ""
    Y.REDO.INT.ACT.DETS.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.ACT.DETAILS,F.REDO.INTERFACE.ACT.DETAILS)

    FN.REDO.INTERFACE.NOTIFY = "F.REDO.INTERFACE.NOTIFY"
    F.REDO.INTERFACE.NOTIFY = ""
    R.REDO.INTERFACE.NOTIFY = ""
    Y.REDO.INT.NOTIFY.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.NOTIFY,F.REDO.INTERFACE.NOTIFY)

    FN.REDO.INTERFACE.MON.TYPE = "F.REDO.INTERFACE.MON.TYPE"
    F.REDO.INTERFACE.MON.TYPE = ""
    R.REDO.INTERFACE.MON.TYPE = ""
    Y.REDO.INT.MON.TYPE.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.MON.TYPE,F.REDO.INTERFACE.MON.TYPE)

    FN.REDO.INTERFACE.REFER = 'F.REDO.INTERFACE.REFER'
    F.REDO.INTERFACE.REFER = ''
    R.REDO.INTERFACE.REFER = ''
    Y.REDO.INTERFACE.REFER.ERR = ''
    CALL OPF(FN.REDO.INTERFACE.REFER,F.REDO.INTERFACE.REFER)

*PCAS00132255 - S
    FN.INTERFACE.CONFIG.PRT = 'F.INTERFACE.CONFIG.PRT'
    F.INTERFACE.CONFIG.PRT = ''
    CALL OPF(FN.INTERFACE.CONFIG.PRT,F.INTERFACE.CONFIG.PRT)
*PCAS00132255 - E

*
    FN.LOCKING.C22 = 'F.LOCKING'
    F.LOCKING.C22  = ''
    CALL OPF(FN.LOCKING.C22,F.LOCKING.C22)
    R.LOCKING  = ''
    Y.LOCKING.ERR = ''
*
    USER = ''
    MACHINE = ''
    START.TIME1 = ''
    END.TIME = ''
    STATUS1 = ''
    Y.SEQ.VAL = ''
    Y.RETRY = ''
    Y.RETRY1 = ''
    Y.TODAY.VAR = TODAY
    Y.TIME.VAR = OCONV(TIME(), "MT")
    Y.TIME.VAR1  = Y.TODAY.VAR:" ":Y.TIME.VAR
    Y.TIME.VAR2 =FIELD(Y.TIME.VAR,':',1)
    Y.TIME.VAR3 = FIELD(Y.TIME.VAR,':',2)
    Y.TIME.VAR4 = Y.TIME.VAR2:Y.TIME.VAR3

* PACS00812781 - S
    Y.CURR.SESSION.NO = C$T24.SESSION.NO
    Y.CURR.SESSION.NO = FMT(Y.CURR.SESSION.NO,'5"0"R')
    Y.TODAY.VAR := '.':Y.CURR.SESSION.NO
* PACS00812781 - E
RETURN
*------------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------------

    IF INT.CODE EQ '' THEN
*PRINT "ERROR IN USE OF SUBROUTINE OF REGISTER REDO.INTERFACE.REC.ACT: INTERFACE CODE (FIRST PARAMETER: INT.CODE) NOT INITIALIZED"
        RETURN
    END
    Y.PARAM.ID.VALUE = INT.CODE
*    CALL F.READ(FN.REDO.INTERFACE.PARAM,Y.PARAM.ID.VALUE,R.REDO.INTERFACE.PARAM,F.REDO.INTERFACE.PARAM,Y.REDO.INT.PAR.ERR)
    CALL CACHE.READ(FN.REDO.INTERFACE.PARAM,Y.PARAM.ID.VALUE,R.REDO.INTERFACE.PARAM,Y.REDO.INT.PAR.ERR)
*    Name  = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.NAME>
    Name = INT.CODE
    Process  = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.PROCESS>
    Description  = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.DESCRIPTION>
    IntType = INT.TYPE
    CALL F.READ(FN.REDO.INTERFACE.REFER,Y.TODAY.VAR,R.REDO.INTERFACE.REFER,F.REDO.INTERFACE.REFER,Y.REDO.INTERFACE.REFER.ERR)
    Y.INT.REDO.TOT.REC = R.REDO.INTERFACE.REFER
    CHANGE @VM TO @FM IN Y.INT.REDO.TOT.REC
    LOCATE INT.CODE IN Y.INT.REDO.TOT.REC SETTING Y.INT.REF.POS THEN
        Y.INT.ACT.ID = R.REDO.INTERFACE.REFER<REDO.INT.REF.REFERENCE.NO,Y.INT.REF.POS>
        idAct = Y.INT.ACT.ID
        PROCESS.DATE = TODAY
        CALL F.READ(FN.REDO.INTERFACE.ACT,idAct,R.REDO.INTERFACE.ACT,F.REDO.INTERFACE.ACT,Y.REDO.INT.ACT.ERR)
        Seq = R.REDO.INTERFACE.ACT<REDO.INT.ACT.NEXT.SEQ.DET>
        GOSUB INT.ACT.DETAILS
    END ELSE
        GOSUB INT.ACT
    END
RETURN
*------------------------------------------------------------------------------------
INT.ACT:
*------------------------------------------------------------------------------------
* PACS00812781 - S
*  Y.LOCKING.ID = 'F.REDO.INTERFACE.ACT'
*  CALL F.READU(FN.LOCKING.C22,Y.LOCKING.ID,R.LOCKING,F.LOCKING.C22,Y.LOCKING.ERR,Y.RETRY)
*  IF NOT(Y.LOCKING.ERR) THEN
*    Y.LOCK.CONT.VALUE = R.LOCKING<EB.LOK.CONTENT>
*  END
*  IF Y.LOCK.CONT.VALUE THEN
*    Y.REDO.INT.ACT.ID1 = Y.LOCK.CONT.VALUE
*    GOSUB CHECK.INT.ACT.ID
*    GOSUB LOCK.CONT.WRITE
*  END
    Y.CUR.DATE = TODAY
    CALL JULDATE(Y.CUR.DATE,Y.RET)
    Y.CUR.JUL.DATE = Y.RET[5,3]
    Y.CUR.TWO.YEAR = Y.CUR.DATE[3,2]
    Y.REDO.INT.ACT.PREFIX = 'IN'
    Y.REDO.INT.ACT.ID = Y.REDO.INT.ACT.PREFIX:Y.CUR.TWO.YEAR:Y.CUR.JUL.DATE:Y.CURR.SESSION.NO
* PACS00812781 - E
    R.REDO.INTERFACE.REFER<REDO.INT.REF.INTERFACE.NAME,-1> = INT.CODE
    R.REDO.INTERFACE.REFER<REDO.INT.REF.REFERENCE.NO,-1> = Y.REDO.INT.ACT.ID
*    WRITE R.REDO.INTERFACE.REFER TO F.REDO.INTERFACE.REFER,Y.TODAY.VAR
    CALL LOG.WRITE(FN.REDO.INTERFACE.REFER,Y.TODAY.VAR,R.REDO.INTERFACE.REFER,'')

    idAct = Y.REDO.INT.ACT.ID
    ID.INTERFACE = INT.CODE
    DESCRIPTION = DESC
    PROCESS.DATE = TODAY
    END.TIME = ''
    START.TIME1 = ''
    TOTAL.REC = 0
    SUCCESS.REC = 0
    REJECT.REC = 0
    NEXT.SEQ.DET = 1
    IF IntType EQ "ONLINE" THEN
        START.TIME1 = ''
        STATUS1 = "Inicio"
        USER = ''
        MACHINE = ''
        Seq = 1
    END
    IF IntType EQ "BATCH" THEN
        START.TIME1 = Y.TIME.VAR4
        STATUS1 = "En proceso"
        USER = EX.USER
        MACHINE = EX.PC
        idAct = Y.REDO.INT.ACT.ID
    END
    GOSUB INT.ACT.DETAILS
RETURN
*
*------------------------------------------------------------------------------------
*CHECK.INT.ACT.ID:
*------------------------------------------------------------------------------------
*  Y.CUR.DATE = TODAY
*  CALL JULDATE(Y.CUR.DATE,Y.RET)
*  Y.CUR.JUL.DATE = Y.RET[5,3]
*  Y.CUR.TWO.YEAR = Y.CUR.DATE[3,2]
*  Y.LOCK.CUR.YEAR = Y.REDO.INT.ACT.ID1[3,2]
*  Y.LOCK.JUL.DATE = Y.REDO.INT.ACT.ID1[5,3]
*  Y.REDO.INT.ACT.PREFIX = Y.REDO.INT.ACT.ID1[1,2]
*  Y.REDO.INT.ACT.SEQ.NUM = Y.REDO.INT.ACT.ID1[8,5]
*  IF Y.CUR.TWO.YEAR EQ Y.LOCK.CUR.YEAR THEN
*    Y.REDO.INT.ACT.YEAR = Y.LOCK.CUR.YEAR
*  END ELSE
*    Y.REDO.INT.ACT.YEAR = Y.CUR.TWO.YEAR
*  END
*  IF Y.CUR.JUL.DATE  EQ Y.LOCK.JUL.DATE THEN
*    Y.RED.INT.ACT.JUL.DATE = Y.LOCK.JUL.DATE
*  END ELSE
*    Y.RED.INT.ACT.JUL.DATE = Y.CUR.JUL.DATE
*  END
*  Y.REDO.INT.ACT.ID = Y.REDO.INT.ACT.PREFIX:Y.REDO.INT.ACT.YEAR:Y.RED.INT.ACT.JUL.DATE:Y.REDO.INT.ACT.SEQ.NUM
*----
*  IF INT.TYPE EQ 'BATCH' THEN
*    Y.LOCK.INTERFACE.TODAY.ID = Y.REDO.INT.ACT.ID
*    Y.LOCK.TODAY.INT.NAME = INT.CODE:".":TODAY
*    CALL F.READU(FN.LOCKING.C22,Y.LOCK.TODAY.INT.NAME,R.LOCKING.INT.REC,F.LOCKING.C22,Y.INT.LOCKING.ERR,Y.RETRY3)
*    IF NOT(R.LOCKING.INT.REC) THEN
*      R.LOCKING.INT.REC<EB.LOK.CONTENT> = Y.LOCK.INTERFACE.TODAY.ID
*    END
*        WRITE R.LOCKING TO F.LOCKING.C22,Y.LOCK.TODAY.INT.NAME
*    CALL LOG.WRITE(FN.LOCKING.C22,Y.LOCK.TODAY.INT.NAME,R.LOCKING,'')
*  END
*---
RETURN
*------------------------------------------------------------------------------------
*LOCK.CONT.WRITE:
*------------------------------------------------------------------------------------
*  IF Y.REDO.INT.ACT.SEQ.NUM THEN
*    Y.REDO.INT.ACT.SEQ.NUM += 1
*    Y.REDO.INT.ACT.SEQ.NUM = FMT(Y.REDO.INT.ACT.SEQ.NUM,'5"0"R')
*    Y.REDO.INT.ACT.ID2 = Y.REDO.INT.ACT.PREFIX:Y.REDO.INT.ACT.YEAR:Y.RED.INT.ACT.JUL.DATE:Y.REDO.INT.ACT.SEQ.NUM
*    R.LOCKING<EB.LOK.CONTENT> = Y.REDO.INT.ACT.ID2
*        WRITE R.LOCKING TO F.LOCKING.C22,Y.LOCKING.ID
*    CALL LOG.WRITE(FN.LOCKING.C22,Y.LOCKING.ID,R.LOCKING,'')
*  END
*  RETURN
*------------------------------------------------------------------------------------
INT.ACT.DETAILS:
*------------------------------------------------------------------------------------
    IF IntType EQ "ONLINE" THEN
* PACS00812781 - S
*    Seq = FMT(Seq,'6"0"R')
        Seq = FMT(Y.CURR.SESSION.NO,'6"0"R')
* PACS00812781 - E
        ID  = Name:'.':TODAY:'.':'ONLINE':'.':Seq
        USER = EX.USER
        MACHINE = EX.PC
        GOSUB REDO.INT.FIELDS
    END
    IF IntType EQ "BATCH"  THEN
* PACS00812781 - S
*    Y.DET.SEQ.ID = INT.CODE
*    CALL F.READU(FN.LOCKING.C22,Y.DET.SEQ.ID,R.LOCKING,F.LOCKING.C22,Y.LOCKING.ERR,Y.RETRY1)
*    IF R.LOCKING THEN
*      Seq = R.LOCKING<EB.LOK.CONTENT>
*      IF Seq EQ '1' THEN
*        GOSUB REDO.ACT.DETAILS.ONE
*        GOSUB INT.ACT.DETAILS.WRITE
*      END
*      Y.SEQ.VAL = Seq
*    END
*    Y.SEQ.VAL+=1
*    R.LOCKING<EB.LOK.CONTENT> = Y.SEQ.VAL
*        WRITE R.LOCKING TO F.LOCKING.C22,Y.DET.SEQ.ID
*    CALL LOG.WRITE(FN.LOCKING.C22,Y.DET.SEQ.ID,R.LOCKING,'')
*    Seq = FMT(Seq,'6"0"R')
        Seq = FMT(Y.CURR.SESSION.NO,'6"0"R')
* PACS00812781 - E
        ID = Name:'.':TODAY:'.':Seq
        USER = ''
        MACHINE = ''
        GOSUB REDO.INT.BATCH.FIELDS
    END
RETURN
*------------------------------------------------------------------------------------
REDO.INT.FIELDS:
*------------------------------------------------------------------------------------
    ID.INTERFACE.ACT = idAct
    ID.MON.TYPE = MON.TP
    ORIGIN.TYPE = INFO.OR
    DEST.TYPE = INFO.DE
    RECORD.ID = ID.PROC
    DESCRIPTION = DESC
    REC.CONTENT = REC.CON
    TIME1 = Y.TIME.VAR1
*  Seq+=1
    GOSUB INT.ACT.DETAILS.WRITE
    GOSUB COUNTER.FUNCTION
RETURN
*------------------------------------------------------------------------------------
REDO.INT.BATCH.FIELDS:
*------------------------------------------------------------------------------------
    IF IntType EQ "BATCH" AND Seq EQ "2" THEN
        GOSUB REDO.ACT.DETAILS.TWO
        GOSUB INT.ACT.DETAILS.WRITE
        GOSUB COUNTER.FUNCTION
    END ELSE
        ID.INTERFACE.ACT = idAct
        ID.MON.TYPE = MON.TP
        ORIGIN.TYPE = INFO.OR
        DEST.TYPE = INFO.DE
        RECORD.ID = ID.PROC
        DESCRIPTION = DESC
        REC.CONTENT = REC.CON
        TIME1 = Y.TIME.VAR1
*    Seq+=1
        GOSUB INT.ACT.DETAILS.WRITE
        GOSUB COUNTER.FUNCTION
    END
RETURN
*------------------------------------------------------------------------------------
REDO.ACT.DETAILS.ONE:
*------------------------------------------------------------------------------------
    Seq = FMT(Seq,'6"0"R')
    ID = Name:'.':TODAY:'.':Seq
    ID.INTERFACE.ACT = idAct
    ID.MON.TYPE = "06"
    ORIGIN.TYPE = INFO.OR
    DEST.TYPE = INFO.DE
    RECORD.ID = ''
    DESCRIPTION = "El proceso inicis automaticamente"
    REC.CONTENT = ''
    TIME1 = Y.TIME.VAR1
*  Seq+=1
RETURN
*------------------------------------------------------------------------------------
REDO.ACT.DETAILS.TWO:
*------------------------------------------------------------------------------------
    ID.INTERFACE.ACT = idAct
    ID.MON.TYPE = MON.TP
    ORIGIN.TYPE = INFO.OR
    ORIGIN.TYPE = INFO.DE
    RECORD.ID = ID.PROC
    DESCRIPTION = DESC
    REC.CONTENT = REC.CON
    TIME1 = Y.TIME.VAR1
    IF INT.TYPE NE 'BATCH' THEN
*    Seq+=1
    END
RETURN
*------------------------------------------------------------------------------------
COUNTER.FUNCTION:
*------------------------------------------------------------------------------------
    Y.REDO.INTERFACE.ACT.ID = idAct
    ID.MON.TYPE = MON.TP
    CALL F.READU(FN.REDO.INTERFACE.ACT,Y.REDO.INTERFACE.ACT.ID,R.REDO.INTERFACE.ACT,F.REDO.INTERFACE.ACT,Y.REDO.INT.ACT.ERR,Y.REDO.INT.ACT.RETRY)
    Y.TOTAL.REC = R.REDO.INTERFACE.ACT<REDO.INT.ACT.TOTAL.REC>
    TOTAL.REC = Y.TOTAL.REC + 1
    IF ID.MON.TYPE EQ "01" THEN
        Y.SUCCESS.REC = R.REDO.INTERFACE.ACT<REDO.INT.ACT.SUCCESS.REC>
        Y.REJECT.REC = R.REDO.INTERFACE.ACT<REDO.INT.ACT.REJECT.REC>
        IF Y.REJECT.REC THEN
            REJECT.REC = Y.REJECT.REC
        END ELSE
            REJECT.REC = 0
        END
        SUCCESS.REC = Y.SUCCESS.REC + 1
        NEXT.SEQ.DET = Seq
        GOSUB REDO.INT.ACT.WRITE
        GOSUB GOEND
    END ELSE
        Y.SUCCESS.REC = R.REDO.INTERFACE.ACT<REDO.INT.ACT.SUCCESS.REC>
        IF Y.SUCCESS.REC THEN
            SUCCESS.REC = Y.SUCCESS.REC
        END ELSE
            SUCCESS.REC = 0
        END
        Y.REJECT.REC = R.REDO.INTERFACE.ACT<REDO.INT.ACT.REJECT.REC>
        IF NOT(Y.REJECT.REC) THEN
            REJECT.REC = 1
        END ELSE
            REJECT.REC = Y.REJECT.REC + 1
        END
        Y.REDO.INT.MON.TYPE.ID  = ID.MON.TYPE
        CALL F.READ(FN.REDO.INTERFACE.MON.TYPE,Y.REDO.INT.MON.TYPE.ID,R.REDO.INTERFACE.MON.TYPE,F.REDO.INTERFACE.MON.TYPE,Y.REDO.INT.MON.TYPE.ERR)
        Y.NOTIFY.ENABLE=R.REDO.INTERFACE.MON.TYPE<REDO.INT.MON.TYPE.NOTIFY.ENABLE>
        IF Y.NOTIFY.ENABLE EQ "SI" THEN
            GOSUB NOTIFY.FUNCTION
        END
        IF Y.NOTIFY.ENABLE EQ "NO" THEN
            GOSUB SUB.COUNTER.FUNCTION
        END
    END
    GOSUB REDO.INT.ACT.UPDATE
RETURN

*------------------------------------------------------------------------------------
SUB.COUNTER.FUNCTION:
*------------------------------------------------------------------------------------
    IF IntType EQ "BATCH" THEN
        Y.BAT.NO.VALUE = BAT.NO
        Y.BAT.TOT.VALUE = BAT.TOT
        START.TIME1 = Y.TIME.VAR4
        IF REJECT.REC EQ "0" THEN
            STATUS1 = "Fin sin errores"
            GOSUB REDO.INT.ACT.UPDATE
        END
        IF REJECT.REC GT "0" THEN
            STATUS1 = "Fin con errores"
            GOSUB REDO.INT.ACT.UPDATE
        END

        IF Y.BAT.NO.VALUE LT Y.BAT.TOT.VALUE THEN
            GOSUB GOEND
        END
    END
    IF IntType EQ "ONLINE" THEN
        GOSUB REDO.INT.ACT.UPDATE
    END
RETURN
*------------------------------------------------------------------------------------
REDO.INT.ACT.DETAILS.NEW:
*------------------------------------------------------------------------------------
    Seq = FMT(Seq,'6"0"R')
    ID = Name:'.':TODAY :'.': Seq
    ID.INTERFACE.ACT = idAct
    ID.MON.TYPE = "07"
    ORIGIN.TYPE = INFO.OR
    DEST.TYPE = INFO.DE
    RECORD.ID = ''
    DESCRIPTION = "El proceso termins"
    REC.CONTENT = ''
    TIME1 = Y.TIME.VAR1
    IF IntType NE "BATCH"  THEN
*    Seq+=1
    END
    GOSUB INT.ACT.DETAILS.WRITE
RETURN
*------------------------------------------------------------------------------------
REDO.INT.ACT.UPDATE:
*------------------------------------------------------------------------------------
    NEXT.SEQ.DET = Seq
    GOSUB REDO.INT.ACT.WRITE
    GOSUB GOEND
RETURN
*------------------------------------------------------------------------------------
REDO.INT.ACT.WRITE:
*------------------------------------------------------------------------------------
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.ID.INTERFACE> = INT.CODE
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.DESCRIPTION> = DESC
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.PROCESS.DATE> = PROCESS.DATE
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.START.TIME> = START.TIME1
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.END.TIME> = END.TIME
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.TOTAL.REC> = TOTAL.REC
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.SUCCESS.REC> = SUCCESS.REC
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.REJECT.REC> = REJECT.REC
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.STATUS> = STATUS1
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.USER> = USER
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.MACHINE> = MACHINE
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.NEXT.SEQ.DET> = NEXT.SEQ.DET
*    WRITE R.REDO.INTERFACE.ACT TO F.REDO.INTERFACE.ACT,idAct
    CALL LOG.WRITE(FN.REDO.INTERFACE.ACT,idAct,R.REDO.INTERFACE.ACT,'')

RETURN
*------------------------------------------------------------------------------------
INT.ACT.DETAILS.WRITE:
*------------------------------------------------------------------------------------
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ID.INTERFACE.ACT> = ID.INTERFACE.ACT
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ID.MONITOR.TYPE> = ID.MON.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ORIGIN.ENT> = ORIGIN.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.DEST.ENT> = DEST.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.RECORD.ID> = RECORD.ID
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.DESCRIPTION> = DESCRIPTION
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.REC.CONTENT> = REC.CONTENT
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.TIME> = TIME1
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.USER> = USER
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.MACHINE> = MACHINE
*    WRITE R.REDO.INTERFACE.ACT.DETAILS TO F.REDO.INTERFACE.ACT.DETAILS,ID
    CALL LOG.WRITE(FN.REDO.INTERFACE.ACT.DETAILS,ID,R.REDO.INTERFACE.ACT.DETAILS,'')
RETURN
*------------------------------------------------------------------------------------
NOTIFY.FUNCTION:
*------------------------------------------------------------------------------------
    Y.REDO.INT.NOTIFY.ID=INT.CODE
    CALL F.READ(FN.REDO.INTERFACE.NOTIFY,Y.REDO.INT.NOTIFY.ID,R.REDO.INTERFACE.NOTIFY,F.REDO.INTERFACE.NOTIFY,Y.REDO.INT.NOTIFY.ERR)
    Y.ADDRESS.LIST = R.REDO.INTERFACE.NOTIFY<REDO.INT.MON.TYPE.DEST.ADDRESS>
    IF Y.ADDRESS.LIST THEN
        Y.COUNT.ADD = DCOUNT(Y.ADDRESS.LIST,@VM)
        Y.INIT.CNT = 1
        IF Y.COUNT.ADD EQ Y.INIT.CNT THEN
            Address = R.REDO.INTERFACE.NOTIFY<REDO.INT.MON.TYPE.DEST.ADDRESS>
        END ELSE
            LOOP
                REMOVE Y.ADDRESS.ID FROM Y.ADDRESS.LIST SETTING Y.ADDRESS.POS
            WHILE Y.ADDRESS.ID : Y.ADDRESS.POS
                IF NOT(Address) THEN
                    Address = Y.ADDRESS.ID
                END ELSE
                    Address = Address:",":Y.ADDRESS.ID
                END
            REPEAT
        END
    END
    Param2 = Name
    Param3 = Address
    Param4 = "Error o Fallas":Param2
    IF REC.CON THEN
        Param5 = REC.CON
    END
    ELSE
        Param5=DESC
    END

    Y.FROM = Param2
    Y.FROM.FIRST.COM = FIELD(Param3,',',1,1)
    Y.FROM.COM = FIELD(Y.FROM.FIRST.COM,'@',2,1)
    Y.FROM.MAIL = Y.FROM:"@":Y.FROM.COM
    Y.TO = Param3
    Y.SUBJECT = Param4
    Y.REPORT = Param5
    Y.TIME.MAIL.VAR = OCONV(TIME(), "MT")
    Y.BODY = "Inerfaz:":Y.FROM:@FM:@FM:"Se ha presentado el siguiente error o falla en la interfaz con el siguiente reporte:":@FM:@FM:Y.REPORT:@FM:@FM:"Para mas informacisn de este error o falla refiirase al registro de Log: ":@FM:@FM:"Este error ocurrio en ":TODAY:" con hora ":Y.TIME.MAIL.VAR
    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
    Y.UNIQUE.ID = UNIQUE.TIME
    FILENAME = 'APAP':Y.UNIQUE.ID
*PCAS00132255 - S
    GOSUB GET.MAIL.FOLDER
*FN.HRMS.FILE = "C22_Mail_Folder"
    FN.HRMS.FILE = Y.MAILIN.FOLDER
*PCAS00132255 - E
    F.HRMA.FILE = ""
    CALL OPF(FN.HRMS.FILE,F.HRMA.FILE)
    RECORD = Y.FROM.MAIL:"#":Y.TO:"#":Y.SUBJECT:"#":Y.BODY
*    WRITE RECORD TO F.HRMA.FILE,FILENAME
    CALL LOG.WRITE(FN.HRMS.FILE,FILENAME,RECORD,'')
    GOSUB AFTER.MAIL
RETURN
*------------------------------------------------------------------------------------
AFTER.MAIL:
*------------------------------------------------------------------------------------
*PCAS00132255 - S
*FN.HRMS.ERR.FILE = "C22_Mail_Error"
    FN.HRMS.ERR.FILE = Y.ERROR.FOLDER
*PCAS00132255 - E
    F.HRMA.ERR.FILE = ""
    CALL OPF(FN.HRMS.ERR.FILE,F.HRMA.ERR.FILE)
    R.HRMA.ERR.FILE = ""
    Y.HRMA.FILE.ERR = ""
    CALL F.READ(FN.HRMS.FILE,FILENAME,R.HRMA.FILE,F.HRMA.FILE,Y.HRMA.FILE.ERR)
    IF R.HRMA.ERR.FILE THEN
        Y.SEND.MESSAGE = R.HRMA.ERR.FILE
        Y.SEND.ERR1 = FIELD(Y.SEND.MESSAGE,"#",1,1)
        Y.SEND.ERR2 = FIELD(Y.SEND.MESSAGE,"#",2,1)
        Y.SEND.ERR3 = FIELD(Y.SEND.MESSAGE,"#",3,1)
        Y.SEND.ERR4 = FIELD(Y.SEND.MESSAGE,"#",4,1)

        BEGIN CASE
            CASE Y.SEND.ERR1 EQ ''
                YTEXT1 = "Error in From id"
            CASE Y.SEND.ERR2 EQ ''
                YTEXT1 = "Error in To id"
            CASE Y.SEND.ERR3 EQ ''
                YTEXT1 = "Error in Subject"
            CASE Y.SEND.ERR4 EQ ''
                YTEXT1 = "Error in Body"
            CASE 1
                YTEXT1 = "Error desconocido!"
        END CASE
        Seq = FMT(Seq,'6"0"R')
        IF IntType EQ 'ONLINE' THEN
            ID  = Name:'.':TODAY:'.':'ONLINE':'.':Seq
        END ELSE
            ID = Name : '.' : TODAY :'.':Seq
        END
        ID.INTERFACE.ACT = idAct
        ID.MON.TYPE = "05"
        ORIGIN.TYPE = "Administracisn Bitacoras y Fallas"
        DEST.TYPE = "Help Desk"
        RECORD.ID = ''
        DESCRIPTION = "La Notificacisn por Correo definido para el Tipo de Monitoreo no ha sido enviada por el siguiente problema:":YTEXT1
        REC.CONTENT = ''
        TIME1 = Y.TIME.VAR1
        GOSUB ERROR.INT.ACT.DETAILS
    END
RETURN

*----------------
GET.MAIL.FOLDER:
*----------------
    R.INT.CONFIG = ''
    CALL CACHE.READ(FN.INTERFACE.CONFIG.PRT,"email",R.INT.CONFIG,EMAILL.ERR)
    IF R.INT.CONFIG THEN
        Y.FOLDER.TYPE = R.INT.CONFIG<INTRF.MSG.INT.FLD.NAME>
        Y.FOLDER.NAME = R.INT.CONFIG<INTRF.MSG.INT.FLD.VAL>
        CHANGE @VM TO @FM IN Y.FOLDER.TYPE
        CHANGE @VM TO @FM IN Y.FOLDER.NAME

        LOCATE "EMAIL_FOLDER_PATH" IN Y.FOLDER.TYPE SETTING TYPE.POS THEN
            Y.MAILIN.FOLDER = Y.FOLDER.NAME<TYPE.POS>
        END

        LOCATE "ERROR_FOLDER_PATH" IN Y.FOLDER.TYPE SETTING TYPE.POS THEN
            Y.ERROR.FOLDER = Y.FOLDER.NAME<TYPE.POS>
        END
    END

RETURN

*------------------------------------------------------------------------------------
ERROR.INT.ACT.DETAILS:
*------------------------------------------------------------------------------------
*  Seq+=1
    GOSUB INT.ACT.DETAILS.WRITE
    GOSUB  SUB.COUNTER.FUNCTION
RETURN
*------------------------------------------------------------------------------------
GOEND:

*------------------------------------------------------------------------------------
END
*-----------------------------*END OF SUBROUTINE*------------------------------------
