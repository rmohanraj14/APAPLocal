* @ValidationCode : MjoyMDk2NTcwNzUwOkNwMTI1MjoxNjgxOTczNzY2OTc0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:26:06
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
SUBROUTINE REDO.V.VAL.PSTOP.TYPE
*------------
*DESCRIPTION:
*------------
*This routine is attached as a validation routine to the version TELLER,REDO.CR.CARD.ACCT.TFR
*it will default USD account in ACCOUNT.2if currency is USD and if currency is DOP then it will
*default DOP Account in ACCOUNT.2

*--------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-

*--------------
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-

*------------------
* Revision History:
*------------------
*   Date               who           Reference            Description
* 16-09-2011        Prabhu.N       PACS00125978      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP.TYPE
    $INSERT I_F.REDO.PAYMENT.STOP.ACCOUNT


    GOSUB MAIN.INITIALISE
    GOSUB SEL.LOC.PSTOP

RETURN
*****************
MAIN.INITIALISE:
****************

    FN.PSTOP = 'F.PAYMENT.STOP.TYPE'
    F.PSTOP = ''
    CALL OPF(FN.PSTOP,F.PSTOP)

    FN.AI.REDO.PSTOP = 'F.AI.REDO.LIST.CRM.PRODUCTS'
    F.AI.REDO.PSTOP = ''
*CALL OPF(FN.AI.REDO.PSTOP,F.AI.REDO.PSTOP) ;*Tus S/E
    PSTOP.ID = 'PSTOP.TYPE'
    CALL CACHE.READ(FN.AI.REDO.PSTOP,PSTOP.ID,R.PSTOP.REC,PSTOP.ERR)

RETURN

*******************
SEL.LOC.PSTOP:
*******************

* SEL.CMD = 'SELECT ':FN.PSTOP

* CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,ERR)


    IF R.PSTOP.REC THEN
        LOOP

            REMOVE PSTOP.TYPE.ID FROM R.PSTOP.REC SETTING PSTOP.POS
        WHILE PSTOP.TYPE.ID
            PSTOP.TYPE.ID = FIELD(PSTOP.TYPE.ID,'*',1)
            CALL F.READ(FN.PSTOP,PSTOP.TYPE.ID,PSTOP.REC,F.PSTOP,PS.ERR)
            IF NOT(PS.ERR) THEN

                PSTOP.DESC = PSTOP.REC<AC.PAT.DESCRIPTION>
                CHANGE ' ' TO '' IN  PSTOP.DESC
                PAY.STOP.REASON =  R.NEW(REDO.PS.ACCT.PS.TYPE.NAME.ARCIB)
                CHANGE ' ' TO '' IN PAY.STOP.REASON

                IF PAY.STOP.REASON EQ PSTOP.DESC THEN
                    R.NEW(REDO.PS.ACCT.PAY.REASON)=PSTOP.TYPE.ID
                END

            END
        REPEAT
    END
RETURN

END
