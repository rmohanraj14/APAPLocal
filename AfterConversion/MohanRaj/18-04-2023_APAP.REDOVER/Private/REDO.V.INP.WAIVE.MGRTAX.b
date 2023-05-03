* @ValidationCode : MjoxOTQ2MTI5MTU4OkNwMTI1MjoxNjgxODEyMTUyNjU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:32:32
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
SUBROUTINE REDO.V.INP.WAIVE.MGRTAX
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as the authorisation routine for the Manager versions
*
* This routine is to raise statement and categ entries wheh the field L.FT.WAIVE.TAX
* is set to YES
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date               who           Reference            Description
*   ~~~~               ~~~           ~~~~~~~~~            ~~~~~~~~~~~
* 22-APR-2010     SHANKAR RAJU     ODR-2010-03-0447     Initial Creation
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.USER
    $INSERT I_F.REDO.MANAGER.CHQ.PARAM

    GOSUB INITIALISE

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN

        GOSUB PROCESS.FT
    END

    IF APPLICATION EQ 'TELLER' THEN

        GOSUB PROCESS.TT
    END

RETURN
*-------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
*Initialise the Variables

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER = ''
    R.FUNDS.TRANSFER = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.REDO.MANAGER.CHQ.PARAM = 'F.REDO.MANAGER.CHQ.PARAM'
    F.REDO.MANAGER.CHQ.PARAM = ''
    R.REDO.MANAGER.CHQ.PARAM = ''
    CALL OPF(FN.REDO.MANAGER.CHQ.PARAM,F.REDO.MANAGER.CHQ.PARAM)

    LREF.APPLN = 'FUNDS.TRANSFER'
    LREF.FLDS = 'WAIVE.TAX':@VM:'L.FT.WAI.TAXAMT':@VM:'L.FT.COMM.CODE'
    LREF.POS = ''

    CALL MULTI.GET.LOC.REF(LREF.APPLN,LREF.FLDS,LREF.POS)
    POS.WAIVE.TAX = LREF.POS<1,1>
    POS.WAIVE.AMT = LREF.POS<1,2>
    POS.COMM.CODE = LREF.POS<1,3>

RETURN
*-------------------------------------------------------------------------
PROCESS.FT:
*~~~~~~~~~~
    Y.CREDIT.AC = R.NEW(FT.CREDIT.ACCT.NO)

    CALL CACHE.READ(FN.REDO.MANAGER.CHQ.PARAM,'SYSTEM',R.REDO.MANAGER.CHQ.PARAM,ERR.PAR)
    Y.ALL.AC.NOS = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ACCOUNT>
    Y.ALL.TAX.KEY = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.TAX.KEY>

    LOCATE Y.CREDIT.AC IN Y.ALL.AC.NOS<1,1> SETTING POS3 THEN

        Y.TAX.KEY = Y.ALL.TAX.KEY<1,POS3>

    END


    Y.TR.ALL.COMM.TYPE = R.NEW(FT.COMMISSION.TYPE)

    IF R.NEW(FT.LOCAL.REF)<1,POS.COMM.CODE> EQ 'CREDIT LESS CHARGES' THEN

        R.NEW(FT.COMMISSION.CODE) = 'CREDIT LESS CHARGES'
        RETURN

    END

    IF R.NEW(FT.LOCAL.REF)<1,POS.COMM.CODE> EQ 'WAIVE' AND R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.TAX> NE 'YES' THEN

        R.NEW(FT.COMMISSION.CODE) = 'DEBIT PLUS CHARGES'

        LOCATE Y.TAX.KEY IN Y.TR.ALL.COMM.TYPE<1,1> SETTING POS3 THEN

            TOT.COMM = DCOUNT(Y.TR.ALL.COMM.TYPE,@VM)
            START.LOOP = 1

            LOOP
            WHILE START.LOOP LE TOT.COMM

                IF START.LOOP NE POS3 THEN

                    DEL R.NEW(FT.COMMISSION.TYPE)<1,START.LOOP>
                    DEL R.NEW(FT.COMMISSION.AMT)<1,START.LOOP>
*                    R.NEW(FT.COMMISSION.AMT)<1,START.LOOP> = LCCY:' ':'0.00'

                END

                START.LOOP += 1 ;*R22 Auto code conversion

            REPEAT

        END

    END

    IF R.NEW(FT.LOCAL.REF)<1,POS.COMM.CODE> NE 'WAIVE' AND R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.TAX> EQ 'YES' THEN

        R.NEW(FT.COMMISSION.CODE) = 'DEBIT PLUS CHARGES'

        Y.TR.ALL.TAX.AMOUNT = R.NEW(FT.COMMISSION.AMT)

        LOCATE Y.TAX.KEY IN Y.TR.ALL.COMM.TYPE<1,1> SETTING POS4 THEN

*************************************************************
*            TOT.WAI.AMT = R.NEW(FT.COMMISSION.AMT)<1,POS4> *
*************************************************************

            R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.AMT> = R.NEW(FT.COMMISSION.AMT)<1,POS4>

*********************************************************
*            R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.AMT> = 150 *
*TOT.WAI.AMT                                            *
*********************************************************
            DEL R.NEW(FT.COMMISSION.TYPE)<1,POS4>
            DEL R.NEW(FT.COMMISSION.AMT)<1,POS4>
*            R.NEW(FT.COMMISSION.AMT)<1,POS4> = LCCY:' ':'0.00'

        END

    END

    IF R.NEW(FT.LOCAL.REF)<1,POS.COMM.CODE> EQ 'WAIVE' AND R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.TAX> EQ 'YES' THEN

        LOCATE Y.TAX.KEY IN Y.TR.ALL.COMM.TYPE<1,1> SETTING POS4 THEN

            TEMP.VALUE = LCCY:' ':'0.00'

            IF R.NEW(FT.COMMISSION.AMT)<1,POS4> NE TEMP.VALUE THEN

****************************************************************
*                TOT.WAI.AMT = R.NEW(FT.COMMISSION.AMT)<1,POS4>*
*                R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.AMT> = 150    *
*TOT.WAI.AMT                                                   *
****************************************************************

                R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.AMT> = R.NEW(FT.COMMISSION.AMT)<1,POS4>

            END

        END

        R.NEW(FT.COMMISSION.CODE) = 'WAIVE'
        R.NEW(FT.COMMISSION.AMT) = ''
        R.NEW(FT.COMMISSION.TYPE) = ''
        IF R.NEW(FT.CHARGE.TYPE) EQ '' THEN
            R.NEW(FT.CHARGES.ACCT.NO) = ''
        END
    END

    IF R.NEW(FT.LOCAL.REF)<1,POS.COMM.CODE> NE 'WAIVE' AND R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.TAX> NE 'YES' THEN

        R.NEW(FT.COMMISSION.CODE) = 'DEBIT PLUS CHARGES'

    END

RETURN
*-------------------------------------------------------------------------
PROCESS.TT:

RETURN
*-------------------------------------------------------------------------
END
