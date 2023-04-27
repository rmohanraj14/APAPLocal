* @ValidationCode : Mjo0NjAxNzcwNzI6Q3AxMjUyOjE2ODA3NzM5NTg2MjM6SGFyaXNodmlrcmFtQzotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:09:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.DC.ADJ.BIN.VALIDATE
************************************************************
*----------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : PRABHU N
* Program Name : REDO.ATH.DC.ADJ.BIN.VALIDATE
*----------------------------------------------------------

* Description   : subroutine is used to validate debit card number

*Linked with   :
* In Parameter  :ENQ.DATA
* Out Parameter : ENQ.DATA
*-----------------------------------------------------------------------------
*---------------------------------------------------------------------------------
*MODIFICATION:
*---------------------------------------------------------------------------------
*DATE           ODR                   DEVELOPER               VERSION
*--------       ----------------      -------------           --------------------
*22.11.2012     PACS00234392            Prabhu N            INITIAL CREATION
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.LATAM.CARD.ORDER
    $INSERT I_F.REDO.CARD.BIN

    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    LREF.APP    ='FUNDS.TRANSFER'
    LREF.FIELD  ='L.FT.ADD.INFO'
    LREF.POS    =''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
*    R.NEW(FT.DEBIT.VALUE.DATE)=R.NEW(FT.CREDIT.VALUE.DATE)
    FN.REDO.CARD.BIN='F.REDO.CARD.BIN'
    F.REDO.CARD.BIN=''
    CALL OPF(FN.REDO.CARD.BIN,F.REDO.CARD.BIN)

    FN.LATAM.CARD.ORDER='F.LATAM.CARD.ORDER'
    F.LATAM.CARD.ORDER=''
    CALL OPF(FN.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER)

    Y.FIELD.VALUE=R.NEW(FT.LOCAL.REF)<1,LREF.POS>
    Y.FIELD.VALUE=TRIM(Y.FIELD.VALUE)
    Y.FIELD.VALUE=TRIMB(Y.FIELD.VALUE)
    IF NOT(Y.FIELD.VALUE) AND LEN(Y.FIELD.VALUE) EQ 0 THEN
        RETURN
    END
    Y.BIN.NUMBER = Y.FIELD.VALUE[1,6]
    CALL F.READ(FN.REDO.CARD.BIN,Y.BIN.NUMBER,R.REDO.CARD.BIN,F.REDO.CARD.BIN,CARD.BIN.ERR)
    IF R.REDO.CARD.BIN EQ '' THEN
        Y.ERR.MSG.ID='EB-INVALD.DC.NUMBER'
        AF=FT.LOCAL.REF
        AV=LREF.POS
        ETEXT = Y.ERR.MSG.ID
        CALL STORE.END.ERROR
    END
    ELSE
        Y.BIN.OWNER = R.REDO.CARD.BIN<REDO.CARD.BIN.BIN.OWNER>
        IF Y.BIN.OWNER EQ 'APAP' THEN
            Y.CARD.ID = R.REDO.CARD.BIN<REDO.CARD.BIN.CARD.TYPE>
            GOSUB VALIDATE.PROC
        END
        ELSE
            Y.ERR.MSG.ID='EB-INVALD.DC.NUMBER'
            AF=FT.LOCAL.REF
            AV=LREF.POS
            ETEXT = Y.ERR.MSG.ID
            CALL STORE.END.ERROR
        END
    END
RETURN

*---------------
VALIDATE.PROC:
*----------------
    FLAG.CRD.TYP=1
    LOOP
        REMOVE CRD.TYP FROM Y.CARD.ID SETTING POS.CRD
    WHILE CRD.TYP:POS.CRD

        IF FLAG.CRD.TYP THEN
            Y.LATAM.ID = CRD.TYP:'.':Y.FIELD.VALUE
            CALL F.READ(FN.LATAM.CARD.ORDER,Y.LATAM.ID,R.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER,Y.ERR.LCO)
            IF R.LATAM.CARD.ORDER THEN
                Y.CARD.ID=CRD.TYP
                FLAG.CRD.TYP=0
            END
        END
    REPEAT

    IF FLAG.CRD.TYP EQ 1 THEN
        AF=FT.LOCAL.REF
        AV=LREF.POS
        Y.ERR.MSG.ID='EB-INVALD.DC.NUMBER'
        ETEXT = Y.ERR.MSG.ID
        CALL STORE.END.ERROR
    END
RETURN
END
