* @ValidationCode : MjotNDMwNDkwNzE6Q3AxMjUyOjE2ODEyMTUxNjA3ODg6SVRTUzotMTotMTozNzc6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 377
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.GET.ACCT.LBL
*-----------------------------------------------------------------------------
*Company   Name    :APAP
*Developed By      :Martin Macias
*Program   Name    :AI.REDO.GET.ACCT.LBL
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 10-APR-2023     Conversion tool    R22 Auto conversion       IF condition added
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER
    $INSERT I_F.REDO.STOP.DESCRIPTION

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

    O.DATA = Y.ACCT.LBL

RETURN

*---------------
INITIALISE:
*---------------

    Y.ACCT.NO = O.DATA
    IF NOT(Y.ACCT.NO) THEN
        Y.ACCT.NO = System.getVariable("CURRENT.ACCT.NO")
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - START
            Y.ACCT.NO = ""
        END					;*R22 Auto conversion - END
    END
    Y.ACCT.LBL = 'Cuenta No: '
    Y.TERM.DEP = 'DEPOSIT'

RETURN

*---------------
OPEN.FILES:
*---------------

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AI.REDO.ARCIB.PARAMETER = 'F.AI.REDO.ARCIB.PARAMETER'
    F.AI.REDO.ARCIB.PARAMETER = ''
    CALL OPF(FN.AI.REDO.ARCIB.PARAMETER,F.AI.REDO.ARCIB.PARAMETER)

    FN.REDO.STOP.DESCRIPTION = 'F.REDO.STOP.DESCRIPTION'
    F.REDO.STOP.DESCRIPTION  = ''
    CALL OPF(FN.REDO.STOP.DESCRIPTION,F.REDO.STOP.DESCRIPTION)

    CALL CACHE.READ(FN.REDO.STOP.DESCRIPTION,'SYSTEM',R.REDO.STOP.DESCRIPTION,DESC.ERR)
    Y.LOAN.LBL = R.REDO.STOP.DESCRIPTION<REDO.STOP.LOAN>

RETURN

*---------------
PROCESS:
*---------------

    CALL F.READ(FN.ACCOUNT, Y.ACCT.NO, R.ACCT, F.ACCOUNT, ER.ACC)

    IF R.ACCT<AC.ARRANGEMENT.ID> NE '' THEN
        Y.ACCT.LBL = Y.LOAN.LBL:': '
    END ELSE
        CALL CACHE.READ(FN.AI.REDO.ARCIB.PARAMETER, 'SYSTEM', R.ARC.PARAM, ER.PARAM)

        LOCATE Y.TERM.DEP IN R.ARC.PARAM<AI.PARAM.ACCOUNT.TYPE,1> SETTING POS1 THEN

            Y.CAT.START = R.ARC.PARAM<AI.PARAM.CATEG.START,POS1>
            Y.CAT.END = R.ARC.PARAM<AI.PARAM.CATEG.END,POS1>

            IF R.ACCT<AC.CATEGORY> GE Y.CAT.START AND R.ACCT<AC.CATEGORY> LE Y.CAT.END THEN
                Y.ACCT.LBL = 'Instrumento a Plazo No: '
            END
        END
    END

RETURN
END
