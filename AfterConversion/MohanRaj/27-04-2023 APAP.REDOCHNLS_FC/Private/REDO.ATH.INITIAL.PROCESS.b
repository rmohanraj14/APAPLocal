* @ValidationCode : MjoxMzU2MjI2MDYzOkNwMTI1MjoxNjgxMjE1MTY0MTMyOklUU1M6LTE6LTE6OTY5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 969
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.INITIAL.PROCESS(STLMT.FILE)
*--------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Temenos Application Management
*Program Name      : REDO.ATH.INITIAL.PROCESS
*Date              : 06.12.2010
*-------------------------------------------------------------------------
* Incoming/Outgoing Parameters
*-------------------------------
* In  : --N/A--
* Out : --N/A--
*-----------------------------------------------------------------------------
* Revision History:
* -----------------
* Date                   Name                   Reference               Version
* -------                ----                   ----------              --------
*23/11/2010      saktharrasool@temenos.com   ODR-2010-08-0469       Initial Version

* 10-APR-2023     Conversion tool    R22 Auto conversion       FM TO @FM, ++ to +=
* 10-APR-2023      Harishvikram C   Manual R22 conversion      CALL routine format modified
*------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ATH.PROCESS.INFO
    $INSERT I_REDO.ATH.INITIAL.PROCESS.COMMON

    Y.EO.FILE=''
    GOSUB MAIN.PARA
    PATH.BCK=BATCH.DETAILS<3,1,1>

    MOVE.CMD="mv " : FILE.PATH:"/":FILE.NAME : " " :PATH.BCK : "/BCK." : FILE.NAME
    EXECUTE MOVE.CMD


RETURN
*-------------------------------------------------------------------------
MAIN.PARA:
*-------------------------------------------------------------------------


    LINE.COUNT.PREV=0
    FILE.NAME=FIELD(STLMT.FILE,"*",1)
    FILE.PATH=FIELD(STLMT.FILE,"*",2)

    CALL F.READ(FN.REDO.ATH.PROCESS.INFO,FILE.NAME,R.REDO.ATH.PROCESS.INFO,F.REDO.ATH.PROCESS.INFO,Y.PROC.ERR)
    IF R.REDO.ATH.PROCESS.INFO NE ''  THEN
        Y.STATUS=R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.STATUS>
        IF Y.STATUS NE 'PROCESSED' THEN
            LINE.COUNT.PREV= R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.LAST.LINE.PROCESS>
        END ELSE
            CALL OCOMO(FILE.NAME : " CANNOT PROCESS TWICE")
            MON.TP='03'
            REC.CON =FILE.NAME : " CANNOT BE PROCESSED TWICE"
            DESC = FILE.NAME
            GOSUB LOG.ERROR.C22


            RETURN
        END
    END ELSE
        IF R.REDO.ATH.PROCESS.INFO EQ '' THEN
            R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.STATUS>='PROCESSING'
        END
    END
    LINE.COUNT=0
    OPENSEQ FILE.PATH,FILE.NAME TO F.FILE.PATH ELSE
        CALL OCOMO(FILE.NAME : " FILE NOT AVAILABLE IN PATH " FILE.PATH)
        MON.TP='03'
        REC.CON =FILE.NAME : " FILE NOT AVAILABLE IN PATH " FILE.PATH
        DESC = FILE.NAME
        GOSUB LOG.ERROR.C22
        RETURN
    END


    GOSUB CHECK.DATE.FILE


    CALL F.READ(FN.REDO.ATH.PROCESS.INFO,STLMT.FILE.DATE,R.REDO.ATH.PROCESS.INFO.DATE,F.REDO.ATH.PROCESS.INFO,Y.PROC.ERR)

    IF R.REDO.ATH.PROCESS.INFO.DATE THEN
        CALL OCOMO(FILE.NAME : " TWO FILES WITH SAME BATCH DATE CANNOT BE PROCESSED" )

        MON.TP='03'
        REC.CON = "TWO FILES WITH SAME BATCH DATE CANNOT BE PROCESSED"
        DESC = FILE.NAME
        GOSUB LOG.ERROR.C22

        RETURN
    END

    SEEK F.FILE.PATH,0, 0 ELSE

        CALL OCOMO(FILE.NAME : "FILE CANNOT PROCESS")
        MON.TP='03'
        REC.CON =FILE.NAME : "FILE CANNOT PROCESS"
        DESC = FILE.NAME
        GOSUB LOG.ERROR.C22
    END

    FILE.BRK=1
    STLMT.LINES=''

    LOOP

    WHILE FILE.BRK
        LINE.COUNT += 1
        READSEQ READ.LINE FROM F.FILE.PATH ELSE
            Y.EO.FILE='YES'
            R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.STATUS>='PROCESSED'
            GOSUB WRITE.LINES
            R.REDO.ATH.PROCESS.INFO.DATE<ATH.PROCE.INFO.STATUS>='PROCESSED'
            CALL F.WRITE(FN.REDO.ATH.PROCESS.INFO,STLMT.FILE.DATE,R.REDO.ATH.PROCESS.INFO.DATE)
            FILE.BRK=0
        END
        IF FILE.BRK THEN
            IF LINE.COUNT.PREV NE 0 AND LINE.COUNT LE LINE.COUNT.PREV THEN
                Y.CONTINUE.FLAG=0
            END ELSE
                GOSUB WRITE.LINES
            END
        END
    REPEAT
RETURN
*-------------------------------------------------------------------------
WRITE.LINES:
*-------------------------------------------------------------------------
    IF READ.LINE[1,4] EQ 'PTLF' OR READ.LINE[1,3] EQ 'TLF' THEN
        FILE.DATE=READ.LINE[6,8]
        R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.LAST.LINE.PROCESS>=LINE.COUNT
        WRITE R.REDO.ATH.PROCESS.INFO ON F.REDO.ATH.PROCESS.INFO,FILE.NAME ON ERROR

            CALL OCOMO('FILE.NAME not written to REDO.ATH.STLMT.CNCT.FILE')
        END
*CONTINUE
        RETURN
    END ELSE
        IF READ.LINE[1,2] EQ 'FT' THEN
            WRITE R.REDO.ATH.PROCESS.INFO ON F.REDO.ATH.PROCESS.INFO,FILE.NAME ON ERROR

                CALL OCOMO('FILE.NAME not written to REDO.ATH.STLMT.CNCT.FILE')
            END
*CONTINUE
            RETURN
        END
*IF STLMT.LINE NE '' THEN
        IF NOT(Y.EO.FILE) THEN
            CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
            STM.LINES=FILE.NAME:'*':UNIQUE.TIME
            Y.WRITE.DATA='20':FIELD(FILE.DATE,'/',3):FIELD(FILE.DATE,'/',2):FIELD(FILE.DATE,'/',1):@FM:READ.LINE
            WRITE Y.WRITE.DATA ON F.REDO.ATH.STLMT.CNCT.FILE,STM.LINES ON ERROR

                CALL OCOMO('UNIQUE.KEY not written to REDO.ATH.STLMT.CNCT.FILE')
            END
        END
        R.REDO.ATH.PROCESS.INFO<ATH.PROCE.INFO.LAST.LINE.PROCESS>=LINE.COUNT
        WRITE R.REDO.ATH.PROCESS.INFO ON F.REDO.ATH.PROCESS.INFO,FILE.NAME ON ERROR

            CALL OCOMO('FILE.NAME not written to REDO.ATH.STLMT.CNCT.FILE')
        END
*END
    END
RETURN


CHECK.DATE.FILE:

    READSEQ READ.LINE FROM F.FILE.PATH THEN
        IF READ.LINE[1,3] EQ 'TLF' OR READ.LINE[1,4] EQ 'PTLF' THEN
            STLMT.FILE.DATE=READ.LINE[6,8]
            CHANGE "/" TO "" IN STLMT.FILE.DATE
        END

    END

RETURN

*-----------------------------------------------------------------------------
LOG.ERROR.C22:
*-----------------------------------------------------------------------------
    MON.TP='04'
    INT.CODE = 'ATH001'
    INT.TYPE = 'BATCH'
    BAT.NO = ''
    BAT.TOT = ''
    INFO.OR = ''
    INFO.DE = ''
    ID.PROC = ''
    EX.USER = ''
    EX.PC = ''
    CALL APAP.REDOCHNLS.REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC) ;*Manual R22 conversion

RETURN


END
