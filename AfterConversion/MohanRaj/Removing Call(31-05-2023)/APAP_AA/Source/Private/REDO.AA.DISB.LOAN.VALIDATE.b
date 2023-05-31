* @ValidationCode : MjotOTEzNjg0NDk6Q3AxMjUyOjE2ODM2OTg0MjE0NTc6SVRTUzotMTotMToxNjc6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 167
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.DISB.LOAN.VALIDATE
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*  This routine is .VALIDATE routine attached to below versions
*
*
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*-----------------------------------------------------------------------------
*   Date               who           Reference            Description
* 04-28-2011          Bharath G         N.45              INITIAL CREATION
* Date                 who                   Reference              
* 29-03-2023          CONVERSION TOOL     R22 AUTO CONVERSTION VM TO @VM AND I TO I.VAR
* 29-03-2023          ANIL KUMAR B       R22 MANUAL CONVERSTION -NO CHANGES
*-----------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.AA.DISB.LOAN
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM

    IF V$FUNCTION EQ 'I' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------------------------
******
INIT:
******
    FN.REDO.BRANCH.INT.ACCT.PARAM = 'F.REDO.BRANCH.INT.ACCT.PARAM'
*F.REDO.BRANCH.INT.ACCT.PARAM = ''
    R.REDO.BRANCH.INT.ACCT.PARAM = ''
*CALL OPF(FN.REDO.BRANCH.INT.ACCT.PARAM,F.REDO.BRANCH.INT.ACCT.PARAM)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    Y.DISB.AMT = ''

RETURN
*-----------------------------------------------------------------------------
********
PROCESS:
********
*
    AF = DISB.LN.MN.DISB.TYPE
    CALL DUP

    AF = DISB.LN.DISB.BRANCH.ID
    CALL DUP

    AF = DISB.LN.BR.DISB.TYPE
    CALL DUP

    Y.CMPNY      = R.NEW(DISB.LN.MAIN.BRANCH.ID)
    Y.AA.ID      = R.NEW(DISB.LN.ARRANGEMENT.ID)

    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ERR)
    IF R.AA.ARRANGEMENT THEN
        Y.CURRENCY = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
        Y.CO.CODE  = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
        Y.STATUS   = R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>
    END
*TUS AA CHnages 20161021
*  IF Y.STATUS EQ 'UNAUTH' OR Y.STATUS EQ 'MATURED' THEN
    IF Y.STATUS EQ 'UNAUTH' OR Y.STATUS EQ 'PENDING.CLOSURE' THEN
*TUS END
        AF = DISB.LN.ARRANGEMENT.ID
        ETEXT = 'EB-ARR.CANNOT.BE.DISBURSED'
        CALL STORE.END.ERROR
        RETURN
    END


*Tus Start
*  CALL F.READ(FN.REDO.BRANCH.INT.ACCT.PARAM,'SYSTEM',R.REDO.BRANCH.INT.ACCT.PARAM,F.REDO.BRANCH.INT.ACCT.PARAM,INT.ERR)
    CALL CACHE.READ(FN.REDO.BRANCH.INT.ACCT.PARAM,'SYSTEM',R.REDO.BRANCH.INT.ACCT.PARAM,INT.ERR)
* Tus End
    IF R.REDO.BRANCH.INT.ACCT.PARAM THEN
        Y.BRANCH.ID = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.COMPANY>
        Y.ACCT.CURR = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.CURRENCY>
        Y.INT.ACCT  = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.BRANCH.INT.ACCT>
        LOCATE Y.CO.CODE IN Y.BRANCH.ID<1,1> SETTING CMPNY.POS THEN
            LOCATE Y.CURRENCY IN Y.ACCT.CURR<1,1,1> SETTING CURR.POS THEN
                R.NEW(DISB.LN.MN.BRANCH.AC) = Y.INT.ACCT<1,CMPNY.POS,CURR.POS>
            END
            ELSE
                AF = DISB.LN.MAIN.BRANCH.ID
                ETEXT = 'EB-MISSING.INT.ACCNT'
                CALL STORE.END.ERROR
            END
        END
        ELSE
            AF = DISB.LN.MAIN.BRANCH.ID
            ETEXT = 'EB-MISSING.INT.ACCNT'
            CALL STORE.END.ERROR
        END
    END
    ELSE
        AF = DISB.LN.MAIN.BRANCH.ID
        ETEXT = 'EB-MISSING.INT.ACCNT'
        CALL STORE.END.ERROR
    END


    Y.BR.DISB.AC = R.NEW(DISB.LN.BR.DISB.AC)
    Y.BR.CMPNY = R.NEW(DISB.LN.DISB.BRANCH.ID)
    LOOP
        REMOVE Y.CMPNY.ID FROM Y.BR.CMPNY SETTING CMPNY.POS
    WHILE Y.CMPNY.ID:CMPNY.POS
        IF R.REDO.BRANCH.INT.ACCT.PARAM THEN
            Y.INTERNAL.AC = ''
            LOCATE Y.CMPNY.ID IN Y.BRANCH.ID<1,1> SETTING CMPNY.POS THEN
                LOCATE Y.CURRENCY IN Y.ACCT.CURR<1,1,1> SETTING CURR.POS THEN
                    Y.INTERNAL.AC = Y.INT.ACCT<1,CMPNY.POS,CURR.POS>
                    GOSUB ASSIGN.INT.ACCNT
                END
                ELSE
                    AF = DISB.LN.DISB.BRANCH.ID
                    ETEXT = 'EB-MISSING.INT.ACCNT'
                    CALL STORE.END.ERROR
                END
            END
            ELSE
                AF = DISB.LN.DISB.BRANCH.ID
                ETEXT = 'EB-MISSING.INT.ACCNT'
                CALL STORE.END.ERROR
            END
        END
        ELSE
            AF = DISB.LN.DISB.BRANCH.ID
            ETEXT = 'EB-MISSING.INT.ACCNT'
            CALL STORE.END.ERROR
        END
    REPEAT

    R.NEW(DISB.LN.LOAN.CCY) = Y.CURRENCY

    Y.MN.TOT.AMT = R.NEW(DISB.LN.MN.DISB.AMT)
    R.NEW(DISB.LN.MN.TOT.AMT) = SUM(Y.MN.TOT.AMT)

    Y.BR.TOT.AMT = R.NEW(DISB.LN.BR.DISB.AMT)

    TOT.BRANCH.AMT = 0
    Y.TOT.BRANCH = DCOUNT(Y.BR.TOT.AMT,@VM)
    FOR I.VAR = 1 TO Y.TOT.BRANCH
        Y.AMT = Y.BR.TOT.AMT<1,I.VAR>
        R.NEW(DISB.LN.BR.TOT.AMT)<1,I.VAR> = SUM(Y.AMT)
        TOT.BRANCH.AMT += SUM(Y.AMT)
    NEXT I.VAR

    R.NEW(DISB.LN.TOT.DISB.AMT) = SUM(Y.MN.TOT.AMT) + TOT.BRANCH.AMT

RETURN
*-----------------------------------------------------------------------------
ASSIGN.INT.ACCNT:
*-----------------------------------------------------------------------------
*
    LOCATE Y.CMPNY.ID IN Y.BR.CMPNY<1,1> SETTING Y.CMP.POS THEN
        R.NEW(DISB.LN.BR.DISB.AC)<1,Y.CMP.POS> = Y.INTERNAL.AC

    END

RETURN
END
