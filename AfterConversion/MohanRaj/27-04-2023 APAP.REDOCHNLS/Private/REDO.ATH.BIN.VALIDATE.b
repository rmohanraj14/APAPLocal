* @ValidationCode : MjotNzE1MTg0NzIyOkNwMTI1MjoxNjgxMjE1MTYzOTUwOklUU1M6LTE6LTE6MTg0OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 184
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.BIN.VALIDATE
******************************************************************************
*  Company   Name    :Asociacion Popular de Ahorros y Prestamos
*  Developed By      :DHAMU.S
*  Program   Name    :REDO.ATH.BIN.VALIDATE
*********************************************************
*DESCRIPTION: This routine will validate the BIN for settlement process
* When the BIN is not APAP bin or APAP DEBIT Card bin and wrong card number will throw error


*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: REDO.ATH.STLMT.FILE.PROCESS
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*01.12.2010  H GANESH        ODR-2010-08-0469  INITIAL CREATION
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*----------------------------------------------------------------------





    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LATAM.CARD.ORDER
    $INSERT I_F.REDO.CARD.BIN
    $INSERT I_REDO.ATH.STLMT.FILE.PROCESS.COMMON



    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

    Y.BIN.NUMBER = Y.FIELD.VALUE[1,6]
    CARD.NUMBER=TRIMB(Y.FIELD.VALUE)
    Y.FIELD.VALUE=TRIM(CARD.NUMBER)
    CALL F.READ(FN.REDO.CARD.BIN,Y.BIN.NUMBER,R.REDO.CARD.BIN,F.REDO.CARD.BIN,CARD.BIN.ERR)
*
    IF R.REDO.CARD.BIN EQ '' THEN
        CONT.FLAG = 'TRUE'
        RETURN
    END ELSE
        APAP.BIN = R.REDO.CARD.BIN<REDO.CARD.BIN.BIN.OWNER>
        BIN.TYPE = R.REDO.CARD.BIN<REDO.CARD.BIN.BIN.TYPE>
    END
*
    IF APAP.BIN EQ 'APAP' AND BIN.TYPE EQ 'CREDIT' THEN
        CONT.FLAG = 'TRUE'
        RETURN
    END

*
    IF APAP.BIN EQ 'NONAPAP' THEN
        ERROR.MESSAGE = 'CARD.NUM.DOESNT.EXIST'
        RETURN
    END
*
    IF APAP.BIN EQ 'APAP' AND BIN.TYPE EQ 'DEBIT' THEN
        CARD.TYPE.VAL = R.REDO.CARD.BIN<REDO.CARD.BIN.CARD.TYPE>
    END
*
* Updating multivalue field CARD.TYPE in REDO.CARD.BIN PACS00033279
    Y.BREAK.FLAG=1
    LOOP
        REMOVE CRD.TYP FROM CARD.TYPE.VAL SETTING CRD.POS
    WHILE CRD.TYP:CRD.POS
        IF Y.BREAK.FLAG THEN
            R.LATAM.CARD.ORDER=''

            LCO.ID = CRD.TYP:'.':CARD.NUMBER
            CALL F.READ(FN.LATAM.CARD.ORDER,LCO.ID,R.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER,CARD.ORDER.ERR)
            IF R.LATAM.CARD.ORDER THEN
                CARD.TYPE.VAL=CRD.TYP

                Y.BREAK.FLAG=0
            END
        END
    REPEAT
* Updating end multivalue field CARD.TYPE in REDO.CARD.BIN PACS00033279

*
    IF R.LATAM.CARD.ORDER EQ '' THEN
        ERROR.MESSAGE = 'CARD.NUM.DOESNT.EXIST'
    END
*
RETURN
END
