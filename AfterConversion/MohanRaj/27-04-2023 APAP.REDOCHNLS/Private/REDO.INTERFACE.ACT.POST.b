* @ValidationCode : MjoxMjMwNzE5MDA2OkNwMTI1MjoxNjgxMzgwODUyOTY2OklUU1M6LTE6LTE6MTE3NDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 1174
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERFACE.ACT.POST(INT.CODE)
*-------------------------------------------------------------------------
* Company Name  :  ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  :  Sakthi Sellappillai
* Program Name  :  REDO.INTERFACE.ACT.POST
* Developed for :  ODR-2010-03-0021
*-------------------------------------------------------------------------
* DESCRIPTION: This Rotuine is used to update the local tables REDO.INTERFACE.ACT,REDO.INTERFACE.ACT.DETAILS at the post level,
* When the call routine REDO.CALL.INTERFACE.REC.ACT called in Multithread Routine to Log the Error and Exception
*----------------------------------------------------------------------------
* Linked with:
* In parameter : None
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*--------------------------------------------------------------------------
*   DATE             WHO                            ODR                     DESCRIPTION
*=============       =================           ===================        ==============
*  13.10.2010        Sakthi Sellappillai           ODR-2010-03-0021         Initial Version
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*--------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.ACT
    $INSERT I_F.REDO.INTERFACE.ACT.DETAILS
    $INSERT I_F.LOCKING
    $INSERT I_F.REDO.INTERFACE.PARAM
    $INSERT I_F.REDO.INTERFACE.REFER

    GOSUB INITIALISE
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------
INITIALISE:
*--------------------------------------------------------------------
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

    FN.REDO.INTERFACE.PARAM = "F.REDO.INTERFACE.PARAM"
    F.REDO.INTERFACE.PARAM = ""
    R.REDO.INTERFACE.PARAM = ""
    Y.REDO.INT.PAR.ERR = ""
    CALL OPF(FN.REDO.INTERFACE.PARAM,F.REDO.INTERFACE.PARAM)

    FN.LOCKING.C22 = 'F.LOCKING'
    F.LOCKING.C22  = ''
    CALL OPF(FN.LOCKING.C22,F.LOCKING.C22)

    FN.REDO.INTERFACE.REFER = 'F.REDO.INTERFACE.REFER'
    F.REDO.INTERFACE.REFER = ''
    CALL OPF(FN.REDO.INTERFACE.REFER,F.REDO.INTERFACE.REFER)
    R.REDO.INTERFACE.REFER.REC = ''
    Y.INTERFACE.REF.ERR1 = ''

    Y.TODAY.VAR = TODAY
    Y.TIME.VAR = OCONV(TIME(), "MT")
    Y.TIME.VAR1  = Y.TODAY.VAR:" ":Y.TIME.VAR
    Y.TIME.VAR2 = FIELD(Y.TIME.VAR,':',1)
    Y.TIME.VAR3 = FIELD(Y.TIME.VAR,':',2)
    Y.TIME.VAR4 = Y.TIME.VAR2:Y.TIME.VAR3
RETURN
*-----------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------
    Y.DET.SEQ.ID = INT.CODE
    CALL F.READU(FN.LOCKING.C22,Y.DET.SEQ.ID,R.LOCKING,F.LOCKING.C22,Y.LOCKING.ERR,Y.LOCK.RETRY4)
    IF R.LOCKING THEN
        Seq  = R.LOCKING<EB.LOK.CONTENT>
    END
    Y.NEXT.SEQ.LOC.VAL = Seq + 1
*
    R.LOCKING<EB.LOK.CONTENT> = Y.NEXT.SEQ.LOC.VAL

*  WRITE R.LOCKING TO F.LOCKING.C22,Y.DET.SEQ.ID ;*Tus Start
    CALL F.WRITE(FN.LOCKING.C22,Y.DET.SEQ.ID,R.LOCKING) ; * Tus End
    Y.INT.LOCK.ID.VAL = Y.DET.SEQ.ID:".":TODAY
    CALL F.READ(FN.LOCKING.C22,Y.INT.LOCK.ID.VAL,R.LOCKING.REC,F.LOCKING.C22,Y.LOCKING.ERR1)
    IF R.LOCKING.REC THEN
        idAct = R.LOCKING.REC<EB.LOK.CONTENT>
    END ELSE
        RETURN

    END
*
    Y.REDO.INTERFACE.ACT.ID = idAct
    CALL F.READ(FN.REDO.INTERFACE.ACT,Y.REDO.INTERFACE.ACT.ID,R.REDO.INTERFACE.ACT,F.REDO.INTERFACE.ACT,Y.REDO.INT.ACT.ERR)
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.NEXT.SEQ.DET> = Y.NEXT.SEQ.LOC.VAL
    R.REDO.INTERFACE.ACT<REDO.INT.ACT.END.TIME>= Y.TIME.VAR4
*  WRITE R.REDO.INTERFACE.ACT TO F.REDO.INTERFACE.ACT,idAct ;*Tus Start
    CALL F.WRITE(FN.REDO.INTERFACE.ACT,idAct,R.REDO.INTERFACE.ACT) ; * Tus End
    Y.PARAM.ID.VALUE = INT.CODE
    CALL F.READ(FN.REDO.INTERFACE.PARAM,Y.PARAM.ID.VALUE,R.REDO.INTERFACE.PARAM,F.REDO.INTERFACE.PARAM,Y.REDO.INT.PAR.ERR)

    Name  = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.NAME>
    Seq = FMT(Seq,'6"0"R')
    ID = Name:'.':TODAY :'.': Seq
    ID.INTERFACE.ACT = idAct
    ID.MON.TYPE = "07"
    ORIGIN.TYPE = "INFO.OR"
    DEST.TYPE = "INFO.DE"
    RECORD.ID = ''
    DESCRIPTION = "El proceso termins"
    REC.CONTENT = ''
    TIME1 = Y.TIME.VAR1
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ID.INTERFACE.ACT> = ID.INTERFACE.ACT
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ID.MONITOR.TYPE> = ID.MON.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.ORIGIN.ENT> = ORIGIN.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.DEST.ENT> = DEST.TYPE
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.RECORD.ID> = RECORD.ID
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.DESCRIPTION> = DESCRIPTION
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.REC.CONTENT> = REC.CONTENT
    R.REDO.INTERFACE.ACT.DETAILS<REDO.INT.ACT.DET.TIME> = TIME1

*  WRITE R.REDO.INTERFACE.ACT.DETAILS TO F.REDO.INTERFACE.ACT.DETAILS,ID ;*Tus Start
    CALL F.WRITE(FN.REDO.INTERFACE.ACT.DETAILS,ID,R.REDO.INTERFACE.ACT.DETAILS) ; * Tus End
RETURN
END
*-------------------------------*END OF SUBROUTINE*-----------------------------
