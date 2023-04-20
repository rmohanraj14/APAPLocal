* @ValidationCode : Mjo4NzExODQyNTk6Q3AxMjUyOjE2ODE5NzY1NzUxMDY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2023 13:12:55
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VER.INTRF.UPD
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used to update REDO.INTRF.REP.LINE when we verify the template RE.STAT.REP.LINE.
*------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 11-01-2011        Prabhu.N        PACS00133292          Initial Creation
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1,= to EQ
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.RE.STAT.LINE.CHANGE
    IF V$FUNCTION NE 'V' THEN
        RETURN
    END
    GOSUB INIT
    GOSUB PROCESS
RETURN


*----
INIT:
*----
    FN.RE.STAT.REP.LINE='F.RE.STAT.REP.LINE'
    F.RE.STAT.REP.LINE =''
    CALL OPF(FN.RE.STAT.REP.LINE,F.RE.STAT.REP.LINE)

    FN.REDO.INTRF.REP.LINE='F.REDO.INTRF.REP.LINE'
    F.REDO.INTRF.REP.LINE =''
    CALL OPF(FN.REDO.INTRF.REP.LINE,F.REDO.INTRF.REP.LINE)

RETURN
*-------
PROCESS:
*-------

    Y.REP.NAME=ID.NEW

    Y.SELECT.REP.LINE = 'SSELECT ':FN.RE.STAT.REP.LINE:' WITH @ID LIKE "':"'":Y.REP.NAME:"'":'..."'
    CALL EB.READLIST(Y.SELECT.REP.LINE,Y.SEL.LIST,'',Y.NO.OF.REC,ERR)
    Y.LOOP.CNT=1
    LOOP
    WHILE Y.LOOP.CNT LE Y.NO.OF.REC
        Y.CHK.REP.NAME = FIELD(Y.SEL.LIST<Y.LOOP.CNT>,'.',1)
        IF Y.CHK.REP.NAME EQ Y.REP.NAME THEN
            Y.REP.LINES.ARRAY<-1> = FIELD(Y.SEL.LIST<Y.LOOP.CNT>,'.',2)
        END
        Y.LOOP.CNT += 1
    REPEAT

    Y.LAST.LINE.NO.POS = COUNT(Y.REP.LINES.ARRAY,@FM) + 1
    Y.LAST.LINE.NO     = Y.REP.LINES.ARRAY<Y.LAST.LINE.NO.POS>

    Y.NO.OF.RANGES = COUNT(R.NEW(RE.LCH.OLD.LINE.START),@VM) + 1
    FOR Y.RANGE = 1 TO Y.NO.OF.RANGES
        Y.NEW.LINES.ARRAY=''
        Y.OLD.LINES.ARRAY=''
        Y.OLD.LINE.ST.NO  = R.NEW(RE.LCH.OLD.LINE.START)<1,Y.RANGE>
        Y.OLD.LINE.END.NO = R.NEW(RE.LCH.OLD.LINE.END)<1,Y.RANGE>
        Y.NEW.LINE.ST.NO  = R.NEW(RE.LCH.NEW.LINE.START)<1,Y.RANGE>

        LOCATE Y.OLD.LINE.ST.NO IN Y.REP.LINES.ARRAY<1> SETTING Y.ST.POS ELSE
            NULL
        END
        LOCATE Y.OLD.LINE.END.NO IN Y.REP.LINES.ARRAY<1> SETTING Y.END.POS ELSE
            NULL
        END

        FOR Y.POS = Y.ST.POS TO Y.END.POS
            Y.NEW.LINE.NO = Y.REP.LINES.ARRAY<Y.POS> - Y.OLD.LINE.ST.NO + Y.NEW.LINE.ST.NO
            Y.NEW.LINE.NO = STR('0',(4-LEN(Y.NEW.LINE.NO))):Y.NEW.LINE.NO
            Y.NEW.LINES.ARRAY<-1> = Y.NEW.LINE.NO
            Y.OLD.LINES.ARRAY<-1> = Y.REP.LINES.ARRAY<Y.POS>
        NEXT Y.POS
        GOSUB UPDATE.WRITE
    NEXT Y.RANGE
RETURN
*------------
UPDATE.WRITE:
*------------
    IF Y.OLD.LINES.ARRAY EQ "" THEN
        RETURN
    END

    Y.NO.OF.MODIFIED.LINES = COUNT(Y.OLD.LINES.ARRAY,@FM)+1

    FOR Y.MODIFIED.LINE = 1 TO Y.NO.OF.MODIFIED.LINES

        Y.NEW.LINE.NO = Y.NEW.LINES.ARRAY<Y.MODIFIED.LINE>
        Y.OLD.LINE.NO = Y.OLD.LINES.ARRAY<Y.MODIFIED.LINE>
        Y.ID.OLD.REP.LINE = Y.REP.NAME:'.':Y.OLD.LINE.NO
        Y.ID.NEW.REP.LINE = Y.REP.NAME:'.':Y.NEW.LINE.NO

        CALL F.READ(FN.REDO.INTRF.REP.LINE,Y.ID.OLD.REP.LINE,R.REDO.INTRF.REP.LINE,F.REDO.INTRF.REP.LINE,ERR)

*    WRITE R.REDO.INTRF.REP.LINE ON F.REDO.INTRF.REP.LINE,Y.ID.NEW.REP.LINE ;*Tus Start
        CALL F.WRITE(FN.REDO.INTRF.REP.LINE,Y.ID.NEW.REP.LINE,R.REDO.INTRF.REP.LINE) ; *Tus End

*        DELETE F.REDO.INTRF.REP.LINE, Y.ID.OLD.REP.LINE
    NEXT Y.MODIFIED.LINE
RETURN
END
