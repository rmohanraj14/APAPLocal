* @ValidationCode : MjotMTUxNzY0MTMxOkNwMTI1MjoxNjgyNTEwOTI4NDY3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 26 Apr 2023 17:38:48
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
$PACKAGE APAP.REDOCHNLS
SUBROUTINE  REDO.ATH.IN.STLMT.RTN(STLMT.LINES)
*--------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Temenos Application Management
*Program Name      : REDO.ATH.IN.STLMT.RTN
*Date              : 06.12.2010
*-------------------------------------------------------------------------
* Incoming/Outgoing Parameters
*-------------------------------
* In  : --STLMT.LINES--
* Out : --N/A--
*-----------------------------------------------------------------------------
* Revision History:
* -----------------
* Date                   Name                   Reference               Version
* -------                ----                   ----------              --------
*06/12/2010      saktharrasool@temenos.com   ODR-2010-08-0469       Initial Version
* 10-APR-2023     Conversion tool  	 R22 Auto conversion     	VM to @VM, ++ to +=, = to EQ
* 10-APR-2023      Harishvikram C   Manual R22 conversion      CALL routine format modified
*------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ATH.STLMT.MAPPING
    $INSERT I_F.REDO.ATH.SETTLMENT
    $INSERT I_REDO.ATH.STLMT.FILE.PROCESS.COMMON
    $INSERT I_F.ATM.REVERSAL
    $USING APAP.REDOCHNLS

    GOSUB PROCESS

RETURN


*------------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------------
*READING F.REDO.ATH.STLMT.MAPPING APPLICATION WITH INCOMING ARRAY AS STLMT.LINES


    ERROR.MESSAGE=''
    CONT.FLAG='FALSE'
    R.REDO.STLMT.LINE=''
    Y.STL.ID=''
    CALL F.READ(FN.REDO.ATH.STLMT.MAPPING,TC.CODE,R.REDO.ATH.STLMT.MAPPING,F.REDO.ATH.STLMT.MAPPING,ERROR.MES)

    IF R.REDO.ATH.STLMT.MAPPING NE '' THEN
        FLD.NAMES=R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.FIELD.NAME>
        Y.VAR=1
        CNT.FLDS=DCOUNT(FLD.NAMES,@VM)
        LOOP

        WHILE Y.VAR LE CNT.FLDS
            FLD.NAME=R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.FIELD.NAME,Y.VAR>
            STRT.POS= R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.START.POS,Y.VAR>
            END.POS= R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.END.POS,Y.VAR>
            Y.FIELD.VALUE= STLMT.LINES<2>[STRT.POS,END.POS]
            IF R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.VERIFY.IN.RTN,Y.VAR> NE '' AND ERROR.MESSAGE EQ '' THEN
                IN.VERIFY.RTN=R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.VERIFY.IN.RTN,Y.VAR>
                CALL @IN.VERIFY.RTN
            END
            IF CONT.FLAG EQ 'TRUE' THEN
                RETURN
            END

            FIELD.NO=R.REDO.ATH.STLMT.MAPPING<ATH.STL.MAP.FIELD.NO,Y.VAR>

            IF FIELD.NO NE '' THEN
                R.REDO.STLMT.LINE<FIELD.NO> = Y.FIELD.VALUE
            END
            Y.VAR += 1
        REPEAT
    END

    IF ERROR.MESSAGE EQ '' THEN
        CALL APAP.REDOCHNLS.redoAthVerifyTransaction() ;*Manual R22 conversion
    END

    LCK.AMT=R.REDO.STLMT.LINE<ATH.SETT.REQUESTED.AMT.RD>
    LCK.AMT.DEC=TRIM(FIELDS(LCK.AMT,".",2))

    IF LCK.AMT.DEC EQ '' THEN

        LCK.AMT=TRIM(LCK.AMT[1,7],'0','L'):'.':LCK.AMT[8,2]

    END
    R.REDO.STLMT.LINE<ATH.SETT.REQUESTED.AMT.RD>=LCK.AMT

    LCK.AMT=R.REDO.STLMT.LINE<ATH.SETT.COMPLETED.AMT.RD>

    LCK.AMT.DEC=TRIM(FIELDS(LCK.AMT,".",2))

    IF LCK.AMT.DEC EQ '' THEN

        LCK.AMT=TRIM(LCK.AMT[1,7],'0','L'):'.':LCK.AMT[8,2]

    END
    R.REDO.STLMT.LINE<ATH.SETT.COMPLETED.AMT.RD>=LCK.AMT

    CALL APAP.REDOCHNLS.redoAthStatusUpdate() ;*Manual R22 conversion
    R.REDO.STLMT.LINE<ATH.SETT.FILE.DATE>=STLMT.LINES<1>
    R.REDO.STLMT.LINE<ATH.SETT.PROCESS.DATE>=TODAY
    CALL LOAD.COMPANY(ID.COMPANY)
    FULL.FNAME ='F.REDO.ATH.SETTLMENT'
    ID.T  = 'A'
    ID.N ='15'
    ID.CONCATFILE = ''
    COMI = ''
    PGM.TYPE = '.IDA'
    ID.NEW = ''
    V$FUNCTION = 'I'
    ID.NEW.LAST = ''
    CALL GET.NEXT.ID(ID.NEW.LAST,'F')
    Y.ID= COMI
    Y.STL.ID=Y.ID
    CALL APAP.REDOCHNLS.redoAthSettleWrite(Y.ID,R.REDO.STLMT.LINE) ;*Manual R22 conversion

    GOSUB UPDATE.ATM.REVERSAL
RETURN


*------------------------------------------------------------------------------------
UPDATE.ATM.REVERSAL:
*------------------------------------------------------------------------------------

    IF R.ATM.REVERSAL NE '' AND ERROR.MESSAGE NE 'DUP.PROCESSED.TRANS' THEN
        R.ATM.REVERSAL<AT.REV.VISA.STLMT.REF>=Y.STL.ID
        CALL F.WRITE(FN.ATM.REVERSAL,ATM.REVERSAL.ID,R.ATM.REVERSAL)
    END
RETURN


END
