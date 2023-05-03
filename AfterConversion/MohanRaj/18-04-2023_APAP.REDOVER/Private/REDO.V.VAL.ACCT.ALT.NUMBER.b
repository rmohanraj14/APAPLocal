* @ValidationCode : MjotODQ0NzY3NjA1OkNwMTI1MjoxNjgxODE4NzMxNTE1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 17:22:11
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.VAL.ACCT.ALT.NUMBER
*-----------------------------------------------------------------------------
* Description:
* This routine will be attached to the version ACCOUNT,CARD.NO
* a validation routine
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : S KAVITHA
* PROGRAM NAME :REDO.V.VAL.ACCT.ALT.NUMBER
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 17 OCT 2011      KAVITHA        PACS00142989      INITIAL CREATION
* -----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LATAM.CARD.ORDER
    $INSERT I_F.REDO.CARD.BIN
    $INSERT I_F.ACCOUNT
*----------------------------------------------------------------------------------------
MAIN:
*----------------------------------------------------------------------------------------


    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PROGRAM.END
*----------------------------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------------------------

    FN.LATAM.CARD.ORDER = 'F.LATAM.CARD.ORDER'
    F.LATAM.CARD.ORDER = ''
    CALL OPF(FN.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER)

    FN.REDO.CARD.BIN = 'F.REDO.CARD.BIN'
    F.REDO.CARD.BIN = ''
    CALL OPF(FN.REDO.CARD.BIN,F.REDO.CARD.BIN)
    Y.CARD.ORDER.ID = ''

    CARD.STATUS = ''
    TYPE.OF.CARD = ''
RETURN
*----------------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------------
    ACCT.TYPE = R.NEW(AC.ALT.ACCT.TYPE)
    ACCT.ID = R.NEW(AC.ALT.ACCT.ID)

    CHANGE @VM TO @FM IN ACCT.TYPE
    CHANGE @VM TO @FM IN ACCT.ID

    IF R.OLD(AC.ALT.ACCT.ID)<1,1> NE R.NEW(AC.ALT.ACCT.ID)<1,1> THEN

        AF = AC.ALT.ACCT.ID
        AV = 1
        ETEXT = "AC-INP.NOT.ALLOWED"
        CALL STORE.END.ERROR

    END

    IF R.OLD(AC.ALT.ACCT.ID)<1,2> NE R.NEW(AC.ALT.ACCT.ID)<1,2> THEN

        AF = AC.ALT.ACCT.ID
        AV = 2
        ETEXT = "AC-INP.NOT.ALLOWED"
        CALL STORE.END.ERROR

    END

    LOCATE "T.DEBITO.2" IN ACCT.TYPE SETTING A.TYPE.POS THEN
        GET.DEBIT.ID = ACCT.ID<A.TYPE.POS>
        GOSUB GET.LATAM.ID
    END

    ERROR.FLAG = ''
    STATUS.TO.CHECK = 90
    STATUS.TO.CHECK<-1> = 94

    IF NOT(Y.CARD.ORDER.ID) THEN

        AF = AC.ALT.ACCT.ID
        AV = A.TYPE.POS
        ETEXT = "EB-INVALID.ADD.CARD"
        CALL STORE.END.ERROR

    END ELSE

        IF CARD.ACCT.NO NE ID.NEW THEN

            ERROR.FLAG = 1
        END

        IF TYPE.OF.CARD NE 'ADICIONAL' THEN
            ERROR.FLAG = 1
        END


        LOCATE CARD.STATUS IN STATUS.TO.CHECK SETTING ST.POS ELSE
            ERROR.FLAG = 1
        END

        IF ERROR.FLAG EQ 1 THEN
            AF = AC.ALT.ACCT.ID
            AV = A.TYPE.POS
            ETEXT = "EB-ACTIVE.ADD.CARD"
            CALL STORE.END.ERROR
        END

    END


RETURN
*----------------------------------------------------------------------------------------
GET.LATAM.ID:

    Y.BIN  = GET.DEBIT.ID[1,6]
    CALL F.READ(FN.REDO.CARD.BIN,Y.BIN,R.REDO.CARD.BIN,F.REDO.CARD.BIN,Y.ERR)

    IF R.REDO.CARD.BIN THEN

        Y.Y.CARD.NUMBER.PRI = R.REDO.CARD.BIN<REDO.CARD.BIN.CARD.TYPE>
        Y.COUNT = DCOUNT(Y.Y.CARD.NUMBER.PRI,@VM)

        Y.CNT =1
        LOOP
        WHILE Y.CNT LE Y.COUNT
            Y.Y.CARD.NUMBER.PRIMARY = Y.Y.CARD.NUMBER.PRI<1,Y.CNT>
            Y.PRIMARY = Y.Y.CARD.NUMBER.PRIMARY:'.':GET.DEBIT.ID
            CALL F.READ(FN.LATAM.CARD.ORDER,Y.PRIMARY,R.LATAM.CARD.ORDER.PRI,F.LATAM.CARD.ORDER,LATAM.ERR)
            IF R.LATAM.CARD.ORDER.PRI THEN
                CARD.STATUS = TRIM(R.LATAM.CARD.ORDER.PRI<CARD.IS.CARD.STATUS>)
                TYPE.OF.CARD = R.LATAM.CARD.ORDER.PRI<CARD.IS.TYPE.OF.CARD>
                CARD.ACCT.NO = R.LATAM.CARD.ORDER.PRI<CARD.IS.ACCOUNT>

                Y.CARD.ORDER.ID = Y.PRIMARY
                RETURN
            END
            Y.CNT += 1 ;*R22 Auto code conversion
        REPEAT
    END


RETURN
*-----------------
PROGRAM.END:
*----------------------------------------------------------------------------------------
END
